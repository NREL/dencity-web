require 'csv'
require 'rest-client'

namespace :populate do

  desc "Export metadata"
  task :export_metadata => :environment do
    metas = Metadata.all
    CSV.open("#{Rails.root}/lib/metadata_export.csv", "wb") do |csv|
    csv << [name, display_name, description, units, datatype, user_defined]
       metas.each do |meta|
        csv << [meta.name, meta.display_name, meta.description, meta.unit.machine_name, meta.datatype, meta.user_defined]
      end
     end
  end

  desc "Import metadata from CSV"
  task  :import_metadata => :environment do
    raise "Populating is only intended for sample data in development" unless Rails.env == "development"
    puts "deleting and importing metadata from metadata.csv"
    Meta.delete_all
    # metadata.csv = real data, metadata_test.csv = test data
    CSV.foreach("#{Rails.root}/lib/metadata.csv",{:headers => true, :header_converters => :symbol}) do |r|
      next unless r[:name]

     # check on units match first, don't save if it doesn't match anything
      if r[:unit].nil?
        puts "No unit specified. If no units are applicable, set unit to 'none', metadata #{r[:name]} was not saved"
        next
      else
        units = Unit.where(name: r[:unit])
        if units.count == 0
          puts "No match for unit #{r[:unit]}, metadata #{r[:name]} was not saved"
          next
        elsif !units.first.allowable
          puts "Unit #{r[:unit]} is not allowable, metadata #{r[:name]} was not saved"
          next
        end
      end

      # All the meta get deleted every time, but in the future we should use find_or_create_by in order
      # to not delete user defined data potentially.
      m = Meta.find_or_create_by(name: r[:name])
      m.name = r[:name]
      m.display_name = r[:display_name]
      m.short_name = r[:short_name  ]
      m.description = r[:description]
      m.unit = units.first
      m.datatype = r[:datatype]
      m.user_defined = r[:user_defined] == 'true' ? true : false
      m.save!
    end

  end

  # Import Project Haystack units
  desc 'import units from haystack excel file'
  task :units => :environment do
    require 'roo'

    puts "Deleting and reimporting units"
    Unit.delete_all

    mapping_file = Rails.root.join("lib/project_haystack_units.xlsx")

    puts "opening #{mapping_file}"
    xls = Roo::Spreadsheet.open(mapping_file.to_s)
    units = xls.sheet('haystack_definitions').parse

    row_cnt = 0
    units.each do |row|
      row_cnt += 1
      next if row_cnt <= 1

      puts row.inspect
      unit = Unit.find_or_create_by(:name => row[1])
      unit.type = row[0]
      unit.display_name = row[2]
      unit.symbol = row[3]
      unit.symbol_alt = row[4] unless row[4].nil?
      unit.allowable = row[6] == 'TRUE' || row[6] == 'true' ? true : false
      unit.save!
    end

    # now go through the other sheet and add the "NREL mapped variables"
    maps = xls.sheet('nrel_units').parse
    row_cnt = 0
    maps.each do |row|
      row_cnt += 1
      next if row_cnt <= 1

      unit = Unit.where(:name => row[3])

      if unit.count == 0
        raise("no nrel_unit found in database for machine_name: '#{row[3]}' and map of #{row[0]}")
      elsif unit.count > 1
        raise("found multiple machine names for: '#{row[3]}'")
      else
        unit = unit.first

        if unit.mapped.nil?
          puts "adding #{row[0]} to unit map for #{row[3]}"
          unit.mapped = [row[0]]
        else
          unit.mapped << row[0] unless unit.mapped.include?(row[0])
        end

        unit.save!
      end

    end

    # map a special case of "" to undefined
    u = Unit.where(:name => "undefined").first
    u.mapped << ""
    u.save!
  end

end






