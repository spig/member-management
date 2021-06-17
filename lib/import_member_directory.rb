require 'rubygems'
require 'sqlite3'
require 'fastercsv'
require 'import_raw_members'

MEMBERS_DB = "../db/members.db"
MEMBERS_CSV = "../db/members.csv"

db = SQLite3::Database.new(MEMBERS_DB)

# import the raw csv file
import_raw_members db, MEMBERS_CSV

# determine new unique members
insert_members db

db.close
