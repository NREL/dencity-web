# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Generate default users and keys


# Go through all the buildings and add a lat/long
edies = Edifice.find(:all)
edies.each do |edi|
  puts "adding values to #{edi.unique_name}"
  edi.coordinates = [-118.40, 33.93]
  edi.save!
end
