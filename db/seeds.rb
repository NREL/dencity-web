# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Generate default users and keys

# Populate the climate zone data
m = Edifice.find_or_create_by(:unique_name => "00000")
m.file_osm = File.open('/var/www/rails/bemscape/Gemfile')
m.save

exit

require 'fastercsv'

FasterCSV.foreach('./db/rawdata/cec_climate_and_zips.csv') do |row|
  loc = Location.find_or_create_by(:zipcode => row[0])
  loc.state = 'CA'
  loc.county_name = row[1]
  loc.cec2009_cz = row[2]
  loc.save!
end


# Go through all the buildings and add a lat/long
#edies = Edifice.find(:all)
#edies.each do |edi|
#  puts "adding values to #{edi.unique_name}"
#  edi.coordinates = [-118.40, 33.93]
#  edi.save!
#end


