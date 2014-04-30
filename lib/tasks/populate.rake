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
    CSV.foreach("#{Rails.root}/lib/metadata.csv",{:headers => true, :header_converters => :symbol}) do |r|
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

  # Test the meta_upload API
  desc "Import metadata via POST to /api/meta_upload"
  task :post_metadata => :environment do
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
    end

    json_request = JSON.generate({'metadata' => meta_arr})
    response = RestClient.post "http://localhost:3000/api/meta_upload", json_request, :content_type => :json, :accept => :json

    # expecting code 201 Created
    if response.code == 201
      puts "SUCCESS: #{response.body}"
    else
      puts "ERROR: #{response.code}, #{response.body}"
    end
  end

end





