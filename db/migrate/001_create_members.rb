class CreateMembers < ActiveRecord::Migration
  def self.up
####### this entire self.up is for documentation - these tables are all created from the import script - sqlite3 specific
#CREATE TABLE members (id integer primary key, full_name varchar(255), printed_name varchar(255), name varchar(255), phone varchar(255), printed_address varchar(255), address varchar(255), created_at datetime, updated_at datetime);
#CREATE TABLE members_raw (family_name varchar(255), phone varchar(255), address varchar(255), address2 varchar(255), address3 varchar(255), address4 varchar(255), name1 varchar(255), name2 varchar(255), name3 varchar(255), name4 varchar(255), name5 varchar(255), name6 varchar(255), name7 varchar(255), name8 varchar(255), name9 varchar(255), name10 varchar(255));
#CREATE UNIQUE INDEX name_address_index on members (name, address);
  end

  def self.down
    drop_table :members
  end
end
