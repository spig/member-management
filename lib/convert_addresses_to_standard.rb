require 'rubygems'
require 'sqlite3'
require "USPS/zip_lookup"
require "USPS/address"

MEMBERS_DB = "members.db"

db = SQLite3::Database.new(MEMBERS_DB)

db.execute("select printed_address, id from members") do |row|
  address = USPS::Address.new
  address.delivery_address = row[0]
  address.city = "WEST JORDAN"
  address.state = "UT"

  zlu = USPS::ZipLookup.new()
  #zlu.verbose = true

  matches = zlu.std_addr(address)

  if matches != nil && matches.size > 0
    matches.each { |match|
      puts "#{row[0]} => #{match.delivery_address}"
      db.query("update members set printed_address = ?, address = ? where id = ?", match.delivery_address, match.delivery_address, row[1])
    }
  else
    puts "no match for #{row[0]}"
  end
end

def get_printed_name_at_address(db, address)
  db.execute( "select printed_name from members where address = ?", address) do |row|
    return row[0]
  end
end
