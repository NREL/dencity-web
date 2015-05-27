require 'csv'
require 'rest-client'

namespace :testing do
  # Test the meta_batch_upload API
  desc 'Batch Post metadata to /api/meta_batch_upload'
  task post_batch_metadata: :environment do
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
    puts "POST http://localhost:3000/api/meta_batch_upload, parameters: #{json_request}"
    begin
      response = RestClient.post 'http://localhost:3000/api/meta_batch_upload', json_request, content_type: :json, accept: :json
      puts "Status: #{response.code}"
      puts "SUCCESS: #{response.body}" if response.code == 201
    rescue => e
      puts "ERROR: #{e.response}"
    end
  end

  # Test the meta_upload API (single metadata entry)
  desc 'Post single metadata entry to /api/meta_upload'
  task post_metadata: :environment do
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
    puts "POST http://localhost:3000/api/meta_upload, parameters: #{json_request}"
    begin
      response = RestClient.post 'http://localhost:3000/api/meta_upload', json_request, content_type: :json, accept: :json
      puts "Status: #{response.code}"
      puts "SUCCESS: #{response.body}" if response.code == 201
    rescue => e
      puts "ERROR: #{e.response}"
    end
  end

  # Test the provenance upload API (authenticated)
  desc 'Post analysis/provenance entry'
  task post_analysis: :environment do
    @user_name = 'nicholas.long@nrel.gov'
    @user_pwd = 'testing123'

    json_object = {}
    json_object['name'] = 'test_provenance'
    json_object['display_name'] = 'Testing Provenance'
    json_object['description'] = 'Testing the add_provenance API'
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

    json_request = JSON.generate('provenance' => json_object, 'measure_definitions' => measure_defs)
    puts "POST http://<user>:<pwd>@<base_url>/api/analysis, parameters: #{json_request}"
    begin
      request = RestClient::Resource.new('http://localhost:3000/api/analysis', user: @user_name, password: @user_pwd)
      response = request.post(json_request, content_type: :json, accept: :json)
      puts "Status: #{response.code}"
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

    json_object = {}
    json_object['building_rotation'] = 0
    json_object['infiltration_rate'] = 2.00155
    json_object['lighting_power_density'] = 3.88565
    json_object['site_energy_use'] = 0
    json_object['total_occupancy'] = 88.8
    json_object['total_building_area'] = 3134.92

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

    prov = Provenance.where(name: 'test_provenance').first
    prov_id = prov.id.to_s

    json_request = JSON.generate('provenance_id' => prov_id, 'structure' => json_object, 'measure_instances' => measure_instances, 'metadata' => { 'user_defined_id' => 'test123' })
    puts "POST http://<user>:<pwd>@<base_url>/api/structure, parameters: #{json_request}"

    begin
      request = RestClient::Resource.new('http://localhost:3000/api/structure', user: @user_name, password: @user_pwd)
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
    prov = Provenance.where(name: 'test_provenance').first
    structure = prov.structures.first
    structure_id = structure.id.to_s

    file = File.open("#{Rails.root}/lib/metadata_test.csv", "rb")
    the_file = Base64.strict_encode64(file.read)
    file.close
    # file_data param
    file_data = {}
    file_data['file_name'] = 'testing.csv'
    file_data['file'] = the_file

    json_request = JSON.generate('structure_id' => structure_id, 'file_data' => file_data)
    puts "POST http://<user.:<pwd>@<base_url>/api/related_file, parameters: #{json_request}"

    begin
      request = RestClient::Resource.new('http://localhost:3000/api/related_file', user: @user_name, password: @user_pwd)
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

  # upload metadata and instance json
  desc 'upload analysis data'
  task upload_analysis: :environment do
    @user_name = 'nicholas.long@nrel.gov'
    @user_pwd = 'testing123'
    provenance_id = nil

    # add metadata
    json_file = MultiJson.load(File.read(File.join(Rails.root,'spec/files/education/analysis_63e94813-9db3-4f47-a50b-ecb0cc0c6d7c_dencity.json')))
    json_request = JSON.generate(json_file)

    begin
      request = RestClient::Resource.new('http://localhost:3000/api/analysis', user: @user_name, password: @user_pwd)
      response = request.post(json_request, content_type: :json, accept: :json)
      if response.code == 201
        puts "SUCCESS: #{response.body}"
        provenance_id = MultiJson.load(response.body)['provenance']['id']
      end
    rescue => e
      puts "ERROR: #{e.response}"
    end

    if provenance_id
      # add structures
      files = Dir.glob('./lib/data/data_points/*_dencity.json')
      files.each do |file|
        json_file = MultiJson.load(File.read(file))
        json_request = JSON.generate(json_file)
        begin
          request = RestClient::Resource.new("http://localhost:3000/api/structure?provenance_id=#{provenance_id}", user: @user_name, password: @user_pwd)
          response = request.post(json_request, content_type: :json, accept: :json)
          puts "SUCCESS: #{response.body}" if response.code == 201
        rescue => e
          puts "ERROR: #{e.inspect}"
        end
      end
    else
      puts 'ERROR: Cannot post structure without a provenance_id'
    end
  end

  desc 'upload structure only'
  task upload_structures: :environment do
    @user_name = 'nicholas.long@nrel.gov'
    @user_pwd = 'testing123'
    provenance_id = '53daaebb986ffbed940001a7'
    # add structures
    files = Dir.glob('./lib/data/data_points/*_dencity.json')
    files.each do |file|
      json_file = MultiJson.load(File.read(file))
      json_request = JSON.generate(json_file)
      begin
        request = RestClient::Resource.new("http://localhost:3000/api/structure?provenance_id=#{provenance_id}", user: @user_name, password: @user_pwd)
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
    puts "POST http://localhost:3000/api/search, parameters: #{json_request}"
    begin
      response = RestClient.post 'http://localhost:3000/api/search', json_request, content_type: :json, accept: :json
      puts "Status: #{response.code}"
      puts "SUCCESS: #{response.body}" if response.code == 200
    rescue => e
      puts "ERROR: #{e.response}"
    end
  end
end
