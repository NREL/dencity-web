require 'csv'
require 'rest-client'

namespace :testing do
  namespace :v1 do
    # Test the meta_batch_upload API
    desc 'Batch Post metadata to /api/meta_batch_upload'
    task post_batch_metadata: :environment do
      @user_name = 'nicholas.long@nrel.gov'
      @user_pwd = 'testing123'
      # TODO: allow users to specify which file to import from?
      meta_arr = []
      CSV.foreach("#{Rails.root}/lib/metadata_test.csv", headers: true) do |row|
        # TODO: make this a separate function on meta class?
        json_object = {}
        row.headers.each do |header|
          if header == 'user_defined'
            json_object[header] = row[header] == 'true' || row[header] == 'TRUE' ? true : false
            next
          end
          json_object[header] = row[header]
        end
        meta_arr << json_object
        puts "meta_arr: #{meta_arr.inspect}"
      end

      json_request = JSON.generate('metadata' => meta_arr)
      puts "POST http://localhost:3000/api/v1/meta_batch_upload, parameters: #{json_request}"
      begin
        request = RestClient::Resource.new('http://localhost:3000/api/v1/meta_batch_upload', user: @user_name, password: @user_pwd)
        response = request.post(json_request, content_type: :json, accept: :json)
        puts "Status: #{response.code}"
        puts "SUCCESS: #{response.body}" if response.code == 201
      rescue => e
        puts "ERROR: #{e.response}"
      end
    end

    # Test the meta_upload API (single metadata entry)
    desc 'Post single metadata entry to /api/meta_upload'
    task post_metadata: :environment do
      @user_name = 'nicholas.long@nrel.gov'
      @user_pwd = 'testing123'
      # TODO: allow users to specify which file to import from?
      # Just grab and post the first record in the spreadsheet
      file = CSV.open("#{Rails.root}/lib/metadata_test.csv", 'rb', headers: true)
      row = file.readline
      # TODO: make this a separate function on meta class?
      json_object = {}
      row.headers.each do |header|
        if header == 'user_defined'
          json_object[header] = row[header] == 'true' ? true : false
          next
        end
        json_object[header] = row[header]
      end
      json_request = JSON.generate('meta' => json_object)
      puts "POST http://localhost:3000/api/v1/meta_upload, parameters: #{json_request}"
      begin
        request = RestClient::Resource.new('http://localhost:3000/api/v1/meta_upload', user: @user_name, password: @user_pwd)
        response = request.post(json_request, content_type: :json, accept: :json)
        puts "Status: #{response.code}"
        puts "SUCCESS: #{response.body}" if response.code == 201
      rescue => e
        puts "ERROR: #{e.response}"
      end
    end

    # Test the analysis upload API (authenticated)
    desc 'Post analysis'
    task post_analysis: :environment do
      @user_name = 'nicholas.long@nrel.gov'
      @user_pwd = 'testing123'

      json_object = {}
      json_object['name'] = 'test_analysis'
      json_object['display_name'] = 'Testing Analysis'
      json_object['description'] = 'Testing the add_analysis API'
      json_object['user_defined_id'] = '230948203498203498203948'
      json_object['user_created_date'] = '2014-07-25T15:30:41Z'
      types = []
      types << 'preflight'
      types << 'batch_run'
      json_object['analysis_types'] =  types
      info = {}
      info['sample_method'] = 'individual_variables'
      info['run_max'] = true
      info['run_min'] = true
      info['run_mode'] = true
      info['run_all_samples_for_pivots'] = true
      objs = []
      objs << 'standard_report_legacy.total_energy'
      objs << 'standard_report_legacy.total_source_energy'
      info['objective_functions'] = objs
      json_object['analysis_information'] = info

      measure_defs = []
      measure = {}
      measure['id'] = '8a70fa20-f63e-0131-cbb2-14109fdf0b37'
      measure['version_id'] = '8a711470-f63e-0131-cbb4-14109fdf0b37'
      measure['name'] = 'SetXPathSingleVariable'
      measure['display_name'] = nil
      measure['description'] = nil
      measure['modeler_description'] = nil
      measure['type'] =  'XmlMeasure'
      args = []
      arg = {}
      arg['display_name'] = 'Set XPath'
      arg['display_name_short'] = 'Set XPath'
      arg['name'] = 'xpath'
      arg['description'] = ''
      arg['units'] = ''
      args << arg
      arg = {}
      arg['display_name'] = 'Location'
      arg['display_name_short'] = 'Location'
      arg['name'] = 'location'
      arg['description'] = ''
      arg['units'] = ''
      args << arg
      measure['arguments'] = args
      measure_defs << measure

      measure = {}
      measure['id'] = '8a726030-f63e-0131-cbc9-14109fdf0b37'
      measure['version_id'] = '8a727a60-f63e-0131-cbcb-14109fdf0b37'
      measure['name'] = 'SetBuildingGeometry'
      measure['display_name'] = nil
      measure['description'] = nil
      measure['modeler_description'] = nil
      measure['type'] =  'XmlMeasure'
      args = []
      arg = {}
      arg['display_name'] = 'Aspect Ratio Multiplier'
      arg['display_name_short'] = 'Aspect Ratio Multiplier'
      arg['name'] = 'aspect_ratio_multiplier'
      arg['description'] = ''
      arg['units'] = ''
      args << arg
      arg = {}
      arg['display_name'] = 'Floor Plate Area Multiplier'
      arg['display_name_short'] = 'Floor Plate Area Multiplier'
      arg['name'] = 'floor_plate_area_multiplier'
      arg['description'] = ''
      arg['units'] = ''
      args << arg
      measure['arguments'] = args
      measure_defs << measure

      json_request = JSON.generate('analysis' => json_object, 'measure_definitions' => measure_defs)
      puts "POST http://<user>:<pwd>@<base_url>/api/v1/analysis, parameters: #{json_request}"
      begin
        request = RestClient::Resource.new('http://localhost:3000/api/analysis', user: @user_name, password: @user_pwd)
        response = request.post(json_request, content_type: :json, accept: :json)
        puts "Status: #{response.code}"
        puts "Response: #{response.body}"
        puts "SUCCESS: #{response.body}" if response.code == 201
      rescue => e
        puts "ERROR: #{e.response}"
      end
    end

    # Test the structure upload API (authenticated)
    desc 'Post structure and associated measure_instances'
    task post_structure: :environment do
      @user_name = 'nicholas.long@nrel.gov'
      @user_pwd = 'testing123'

      json_object = []
      json_object << { name: 'infiltration_rate', value: 2.00155 }
      json_object << { name: 'lighting_power_density', value: 3.88565 }
      json_object << { name: 'site_energy_use', value: 0 }
      json_object << { name: 'total_occupancy', value: 88.8 }
      json_object << { name: 'building_area', value: 3134.92 }

      measure_instances = []
      measure = {}
      measure['index'] = 0
      measure['uri'] = 'https://bcl.nrel.gov'
      measure['id'] =  '8a70fa20-f63e-0131-cbb2-14109fdf0b37'
      measure['version_id'] = '8a711470-f63e-0131-cbb4-14109fdf0b37'
      args = {}
      args['location'] = 'AN_BC_Vancouver.718920_CWEC.epw'
      args['xpath'] = '/building/address/weather-file'
      measure['arguments'] = args
      measure_instances << measure
      measure = {}
      measure['index'] = 1
      measure['uri'] = 'https://bcl.nrel.gov'
      measure['id'] =  '8a726030-f63e-0131-cbc9-14109fdf0b37'
      measure['version_id'] = '8a727a60-f63e-0131-cbcb-14109fdf0b37'
      measure['arguments'] = {}
      measure_instances << measure

      analysis = Analysis.where(name: 'test_analysis').first
      analysis_id = analysis.id.to_s

      json_request = JSON.generate('structure' => { 'user_defined_id' => SecureRandom.uuid, 'analysis_id' => analysis_id, 'metadata' =>  json_object }, 'measure_instances' => measure_instances)
      puts "POST http://<user>:<pwd>@<base_url>/api/v1/structure, parameters: #{json_request}"

      begin
        request = RestClient::Resource.new('http://localhost:3000/api/v1/structure', user: @user_name, password: @user_pwd)
        response = request.post(json_request, content_type: :json, accept: :json)
        puts "Status: #{response.code}"
        if response.code == 201
          puts "SUCCESS: #{response.body}"
        else
          fail response.body
        end
      rescue => e
        puts "ERROR: #{e.response}"
      end
    end

    desc 'post file associated with structure'
    task post_file: :environment do
      @user_name = 'nicholas.long@nrel.gov'
      @user_pwd = 'testing123'

      # only works after saving a structure, so get a valid one
      prov = Analysis.where(name: 'test_analysis').first
      structure = prov.structures.first
      structure_id = structure.id.to_s

      file = File.open("#{Rails.root}/lib/metadata_test.csv", 'rb')
      the_file = Base64.strict_encode64(file.read)
      file.close
      # file_data param
      file_data = {}
      file_data['file_name'] = 'testing.csv'
      file_data['file'] = the_file

      json_request = JSON.generate('structure_id' => structure_id, 'file_data' => file_data)
      puts "POST http://<user>:<pwd>@<base_url>/api/v1/related_file, parameters: #{json_request}"

      begin
        request = RestClient::Resource.new('http://localhost:3000/api/v1/related_file', user: @user_name, password: @user_pwd)
        response = request.post(json_request, content_type: :json, accept: :json)
        puts "Status: #{response.code}"
        if response.code == 201
          puts "SUCCESS: #{response.body}"
        else
          fail response.body
        end
      rescue => e
        puts "ERROR: #{e.response}"
        puts e.inspect
      end
    end

    desc 'remove file associated with structure'
    task remove_file: :environment do
      @user_name = 'nicholas.long@nrel.gov'
      @user_pwd = 'testing123'

      # only works after saving a structure, so get a valid one
      prov = Analysis.where(name: 'test_analysis').first
      structure = prov.structures.first
      structure_id = structure.id.to_s

      file_name = 'testing.csv'

      json_request = JSON.generate('structure_id' => structure_id, 'file_name' => file_name)
      puts "POST http://<user>:<pwd>@<base_url>/api/v1/remove_file, parameters: #{json_request}"

      begin
        request = RestClient::Resource.new('http://localhost:3000/api/v1/remove_file', user: @user_name, password: @user_pwd)
        response = request.post(json_request, content_type: :json, accept: :json)
        puts "Status: #{response.code}"
        if response.code == 204 || response.code == 200
          puts "SUCCESS: #{response.body}"
        else
          fail response.body
        end
      rescue => e
        puts "ERROR: #{e.inspect}"
        puts e.inspect
      end
    end

    desc 'test search'
    task search: :environment do
      # test all filters
      filters = []
      # filter = {name: 'building_area', value: 2737.26, operator: '='}
      filter = { name: 'building_area', value: 2737.26, operator: 'lt' }
      filters << filter
      filter = { name: 'building_type', value: ['Community Center'], operator: 'in' }
      filters << filter
      filter = { name: 'floor_to_floor_height', value: '2', operator: 'ne' }
      filters << filter
      filter = { name: 'weather_file', value: '', operator: 'exists' }
      filters << filter
      filter = { name: 'roof_construction_type', value: ['shingle roof'], operator: 'nin' }
      filters << filter

      page = 0
      return_only = %w(building_area building_type roof_construction_type)

      json_request = JSON.generate('filters' => filters, 'page' => page, 'return_only' => return_only)
      puts "POST http://localhost:3000/api/v1/search, parameters: #{json_request}"
      begin
        response = RestClient.post 'http://localhost:3000/api/v1/search', json_request, content_type: :json, accept: :json
        puts "Status: #{response.code}"
        puts "SUCCESS: #{response.body}" if response.code == 200
      rescue => e
        puts "ERROR: #{e.response}"
      end
    end

    desc 'test search_by_arguments'
    task search_by_arguments: :environment do
      analysis_id = '542a01b6042fa5e81c000001'
      measures = []

      measures << { uuid: '567b1f00-1d03-0132-2734-22000a2da8e0', version_id: '567d76b0-1d03-0132-2735-22000a2da8e0', arguments: { value: 'USA_AZ_Phoenix-Sky.Harbor.Intl.AP.722780_TMY3.epw', xpath: '/building/address/weather-file' } }
      measures << { uuid: '56be40f0-1d03-0132-27ce-22000a2da8e0', version_id: '56be96f0-1d03-0132-27cf-22000a2da8e0', arguments: { efficiency: 92.7167407206081, fuel_type: 'electricity' } }

      json_request = JSON.generate('analysis_id' => analysis_id, 'measures' => measures)
      puts "POST http://localhost:3000/api/v1/search_by_arguments, parameters: #{json_request}"
      begin
        response = RestClient.post 'http://localhost:3000/api/v1/search_by_arguments', json_request, content_type: :json, accept: :json
        puts "Status: #{response.code}"
        puts "SUCCESS: #{response.body}" if response.code == 200
      rescue => e
        puts "ERROR: #{e.response}"
      end
    end
  end
  # upload metadata and instance json
  desc 'upload analysis data'
  task upload_analysis: :environment do
    @user_name = 'nicholas.long@nrel.gov'
    @user_pwd = 'testing123'
    analysis_id = nil

    # add metadata
    json_file = MultiJson.load(File.read(File.join(Rails.root, 'spec/files/education/analysis_63e94813-9db3-4f47-a50b-ecb0cc0c6d7c_dencity.json')))
    json_request = JSON.generate(json_file)

    begin
      request = RestClient::Resource.new('http://localhost:3000/api/analysis', user: @user_name, password: @user_pwd)
      response = request.post(json_request, content_type: :json, accept: :json)
      if response.code == 201
        puts "SUCCESS: #{response.body}"
        analysis_id = MultiJson.load(response.body)['analysis']['id']
      end
    rescue => e
      puts "ERROR: #{e.response}"
    end

    if analysis_id
      # add structures
      files = Dir.glob('./lib/data/data_points/*_dencity.json')
      files.each do |file|
        json_file = MultiJson.load(File.read(file))
        json_request = JSON.generate(json_file)
        begin
          request = RestClient::Resource.new("http://localhost:3000/api/structure?analysis_id=#{analysis_id}", user: @user_name, password: @user_pwd)
          response = request.post(json_request, content_type: :json, accept: :json)
          puts "SUCCESS: #{response.body}" if response.code == 201
        rescue => e
          puts "ERROR: #{e.inspect}"
        end
      end
    else
      puts 'ERROR: Cannot post structure without an analysis_id'
    end
  end

  desc 'upload structure only'
  task upload_structures: :environment do
    @user_name = 'nicholas.long@nrel.gov'
    @user_pwd = 'testing123'
    analysis_id = '53daaebb986ffbed940001a7'
    # add structures
    files = Dir.glob('./lib/data/data_points/*_dencity.json')
    files.each do |file|
      json_file = MultiJson.load(File.read(file))
      json_request = JSON.generate(json_file)
      begin
        request = RestClient::Resource.new("http://localhost:3000/api/structure?analysis_id=#{analysis_id}", user: @user_name, password: @user_pwd)
        response = request.post(json_request, content_type: :json, accept: :json)
        puts "SUCCESS: #{response.body}" if response.code == 201
      rescue => e
        puts "ERROR: #{e.inspect}"
      end
    end
  end

  unless Rails.env.production?
    desc 'fix user password, pass in email=<THE_EMAIL>'
    task fix_user_pwd: :environment do
      puts "email is #{ENV['email']}"
      user = User.where(email: ENV['email']).first
      user.password = 'testing123'
      user.save
    end
  end
end
