require 'csv'
require 'rest-client'

namespace :populate do

  desc "Export metadata"
  task :export_metadata => :environment do
    metas = Metadata.all
    CSV.open("#{Rails.root}/lib/metadata_export.csv", "wb") do |csv|
    csv << [name, display_name, description, units, datatype, user_defined]
       metas.each do |meta|
        csv << [meta.name, meta.display_name, meta.description, meta.units, meta.datatype, meta.user_defined]
      end
     end
  end

  desc "Import metadata from CSV"
  task  :import_metadata => :environment do
    raise "Populating is only intended for sample data in development" unless(Rails.env == "development")

    Meta.delete_all
    puts "importing metadata from metadata.csv"
    CSV.foreach("#{Rails.root}/lib/metadata_test.csv",{:headers => true, :header_converters => :symbol}) do |r|

     # check on units match first, don't save if it doesn't match anything
      unless r[:units].nil?
        units = Unit.where(machine_name: r[:units])
        if units.count == 0
          puts "No match for units #{r[:units]}, metadata #{r[:name]} was not saved"
          next
        end
      end

      m = Meta.new
      m.name = r[:name]
      m.display_name = r[:display_name]
      m.description = r[:description]
      m.units = r[:units]
      m.datatype = r[:datatype]
      m.user_defined = r[:user_defined] == 'true' ? true : false
      m.save!
    end

  end

  # Test the meta_batch_upload API
  desc "Batch Post metadata to /api/meta_batch_upload"
  task :post_batch_metadata => :environment do
    # TODO: allow users to specify which file to import from?
    meta_arr = []
    CSV.foreach("#{Rails.root}/lib/metadata_test.csv", :headers => true) do |row|
      # TODO: make this a separate function on meta class?
      json_object = {}
      row.headers.each do |header|
        if header == 'user_defined'
          json_object[header] = row[header] == 'true' ? true : false
          next
        end
        json_object[header] = row[header]
      end
      meta_arr << json_object
      puts "meta_arr: #{meta_arr.inspect}"
    end

    json_request = JSON.generate({'metadata' => meta_arr})

    begin
      response = RestClient.post "http://localhost:3000/api/meta_batch_upload", json_request, :content_type => :json, :accept => :json
      if response.code == 201
        puts "SUCCESS: #{response.body}"
      end
    rescue => e
      puts "ERROR: #{e.response}"
    end
  end

  #Test the meta_upload API (single metadata entry)
  desc "Post single metadata entry to /api/meta_upload"
  task :post_metadata => :environment do
    # TODO: allow users to specify which file to import from?
    # Just grab and post the first record in the spreadsheet
    file = CSV.open("#{Rails.root}/lib/metadata_test.csv", 'rb', :headers => true)
    row = file.readline()
    # TODO: make this a separate function on meta class?
    json_object = {}
    row.headers.each do |header|
      if header == 'user_defined'
        json_object[header] = row[header] == 'true' ? true : false
        next
      end
      json_object[header] = row[header]
    end
    json_request = JSON.generate({'metadata' => json_object})
    begin
      response = RestClient.post "http://localhost:3000/api/meta_upload", json_request, :content_type => :json, :accept => :json
      if response.code == 201
        puts "SUCCESS: #{response.body}"
      end
    rescue => e
      puts "ERROR: #{e.response}"
    end
  end

  # Import Project Haystack units
  desc 'import units from haystack excel file'
  task :units => :environment do
    require 'roo'

    mapping_file = Rails.root.join("lib/project_haystack_units.xlsx")

    puts "opening #{mapping_file}"
    xls = Roo::Spreadsheet.open(mapping_file.to_s)
    units = xls.sheet('haystack_definitions').parse

    row_cnt = 0
    units.each do |row|
      row_cnt += 1
      next if row_cnt <= 1

      puts row.inspect
      unit = Unit.find_or_create_by(:machine_name => row[1])
      unit.type = row[0]
      unit.name = row[2]
      unit.symbol = row[3]
      unit.symbol_alt = row[4] unless row[4].nil?
      unit.save!
    end

    # now go through the other sheet and add the "NREL mapped variables"
    maps = xls.sheet('nrel_units').parse
    row_cnt = 0
    maps.each do |row|
      row_cnt += 1
      next if row_cnt <= 1

      unit = Unit.where(:machine_name => row[3])

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
    u = Unit.where(:machine_name => "undefined").first
    u.mapped << ""
    u.save!
  end

end






