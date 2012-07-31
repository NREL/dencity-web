# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Generate default users and keys

# Populate the climate zone data
require 'fastercsv'

cnt = 0
FasterCSV.foreach('./db/rawdata/cec_climate_and_zips.csv') do |row|
  cnt += 1
  next if cnt == 1
  
  loc = Location.find_or_create_by(:zipcode => row[0])
  loc.state = 'CA'
  loc.county_name = row[1]
  loc.cec2009_cz = row[2]
  loc.save!
end

cnt = 0
FasterCSV.foreach('./db/rawdata/us_states.csv') do |row|
  cnt += 1
  next if cnt == 1 
  
  state = State.find_or_create_by(:name => row[0])
  state.abbr = row[1]
  state.save!
end

# Go through all the buildings and add a lat/long
#edies = Edifice.find(:all)
#edies.each do |edi|
#  puts "adding values to #{edi.unique_name}"
#  edi.coordinates = [-118.40, 33.93]
#  edi.save!
#end


