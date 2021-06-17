require "USPS/zip_lookup"
require "USPS/address"

def import_raw_members db, members_csv
  db.query("delete from members_raw") {}
  
  # family_name, phone, address, address2, address3, address4, name1, name2, name3, name4, name5, name6, name7, name8, name9, name10
  stmt = db.prepare("insert into members_raw values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
  FasterCSV.foreach(members_csv, {:headers => true, :return_headers => false, :skip_blanks => true}) do |row|
    stmt.execute(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15]) {}
  end
  stmt.close
end

def insert_members db

  db.execute("update members set keep = 0 where 1=1")

  member_insert_statements = []
  db.execute( "select family_name, phone, address, name1, name2, name3, name4, name5, name6, name7, name8, name9, name10 from members_raw" ) do |row|
    # update all the records where name is the same and add in the current raw address to re-normalize the data
    db.execute("update members set address = ?, keep = 1 where name = ?", row[2], row[0])

    full_name = row[0]
    printed_name = row[0].split(/,/)[0]
    (3..12).each do |num|
      # set the separator to "and" if the full_name has a couple listed
      separator = ", "
      separator = " and " if (num == 4 and full_name.match /\sand\s/)

      full_name += ", #{row[num]}" if row[num] # ignore the separator for the full name field
      printed_name += "#{separator}#{row[num].split(/\s/)[0]}" if row[num]
    end
    printed_address = row[2]

    process_next_row = false
    # check if we already have this family in our database
    puts "checking #{row[0]} with address #{row[2]}"
    db.execute("select count(*) from members where address = ? and name = ?", row[2], row[0]) do |checkrow|
      if checkrow[0] != '0'
        puts "already have #{row[0]}"
        # update the record to be 'keep'
        db.execute("update members set keep = 1 where address = ? and name = ?", row[2], row[0])
        process_next_row = true
      end
    end

    next if process_next_row

    address = USPS::Address.new
    address.delivery_address = printed_address
    address.city = "WEST JORDAN"
    address.state = "UT"

    zlu = USPS::ZipLookup.new()
    #zlu.verbose = true

    matches = zlu.std_addr(address)

    if matches != nil && matches.size > 0
#        printf "\n%d matches:\n", matches.size
      matches.each { |match|
        print "-" * 39, "\n"
#          print match.to_dump
        printed_address = match.delivery_address
        puts printed_address
#         print "\n"
      }
      
#        print "-" * 39, "\n"
    else
      print "No matches for #{printed_name} (#{printed_address})!\n"
    end

    member_insert_statements << {:full_name => full_name,
      :printed_name => printed_name,
      :name => row[0],
      :phone => row[1],
      :printed_address => printed_address,
      :address => row[2]}
  end

  time_now = Time.now
  member_insert_statements.each do |m|
    db.execute("insert into members (full_name, printed_name, name, phone, printed_address, address, created_at, updated_at, keep, new) values (?,?,?,?,?,?,?,?,1,1)", m[:full_name], m[:printed_name], m[:name], m[:phone], m[:printed_address], m[:address], time_now, time_now) {}
  end

end

def get_printed_name_at_address(db, address)
  db.execute( "select printed_name from members where address = ?", address) do |row|
    return row[0]
  end
end
