
module Api::V1
  class ApiController < ApplicationController
  
    # version1 of API
    resource_description do
      api_version "1"
    end

    before_filter :check_auth, except: [:search, :retrieve_analysis]
    respond_to :json

    api :POST, '/search', 'Search for structures'
    formats ['json']
    description 'Search for structures, filter results by metadata.'
    param :filters, Array, of: Hash, desc: 'Hash of filters, listed below:', required: true do
      param :name, String, desc: 'Metadatum name.  Metadatum must already be defined at dencity.org/metadata', required: true
      param :value, String, desc: 'Metadatum value'
      param :operator, String, desc: 'Operator.  Options include: [ =, ne, lt, lte, gt, gte, exists, in, nin].  =: Return if value is equal to specified value.  ne: Return if value is not equal to specified value.  lt: Return if value is less than specified value.  lte: Return if value is less than or equal to specified value
. gt: Return if value is greater than specified value. gte: Return if value is greater than or equal to specified value.  exists: Return if specified metadatum exists in the structure record.  For this operator, value can be undefined.  in: Return if value is in the list of specified values.  nin: Return  if value is not in the list of specified values.', required: true
    end
    param :return_only, Array, of: String, desc: 'If return_only is specified, it restricts the metadata returned with each structure in the result set.  All metadata specified in the return_only parameter as well as the metadata in the filters will be returned, as well as the id of each resource.  If this parameter is not specified, all metadata associated with each structure in the result set will be returned.
', required: false
    param :page, Integer, desc: 'Search returns a maximum of 100 results per request.  Use this parameter to iterate through the search results. The page parameter is 0-based.', required: false
    error :code => 401, desc: 'Unauthorized'
    error :code => 422, desc: 'Error present in request:  parameters missing or incorrect'
    example %Q(POST http://<base_url>/api/search, parameters: {"filters":[{"name":"aspect_ratio","value":2,"operator":"lt"}], "return_only":["aspect_ratio"], "page":"2"})

    def search
      # expecting 3 parameters:  filters, return_only, page
      # filters is an array of hashes, each containing: name, value, operator
      # operators allowed:  =, ne, gt, gte, lt, lte, in, exists near
      # in and near have an array as the value.  exists has a nil value.
      # return_only is an containing the subset of metadata to return

      # clean params
      clean_params = search_params

      @results_per_page = 100
      @return_only = []
      page = 0

      if params[:filters]
        @filters = params[:filters]

        # Build query
        query = Structure.all
        @filters.each do |filter|
          case filter[:operator]
          when '='
            # equal
            query = query.where(filter[:name].to_sym => filter[:value])
          when 'ne'
            # not equal
            query = query.ne(filter[:name].to_sym => filter[:value])
          # criteria.ne(filter[:name].to_sym => filter[:value])
          when 'lt'
            # less than
            query = query.lt(filter[:name].to_sym => filter[:value])
          when 'lte'
            # less than or equal to
            query = query.lte(filter[:name].to_sym => filter[:value])
          when 'gt'
            # greater than
            query = query.gt(filter[:name].to_sym => filter[:value])
          when 'gte'
            # greater than or equal to
            query = query.gte(filter[:name].to_sym => filter[:value])
          when 'in'
            # value is in the provided list
            # TODD: check that value is an array even if only 1 value is provided
            query = query.in(filter[:name].to_sym => filter[:value])
          when 'nin'
            # value is not in the provided list
            # TODD: check that value is an array even if only 1 value is provided
            query = query.nin(filter[:name].to_sym => filter[:value])
          when 'exists'
            # attribute is defined for the building
            query = query.exists(filter[:name].to_sym => true)
          else
            # not a valid operator
          end
        end

        # add 'only' if it's a non-nil array
        # TODO: always add the filters specified to the return_only list

        if params[:return_only] && params[:return_only].is_a?(Array) && !params[:return_only].empty?
          @return_only = params[:return_only]
          temp_returns = @filters.map { |x| x[:name] }
          @return_only += temp_returns
          # ensure that 'id is always returned?'
          @return_only << 'id'
          @return_only = @return_only.uniq
          query = query.only(@return_only)
        else
          @return_only = nil
        end

        # limit results
        query = query.limit(@results_per_page)

        # get correct page (0-based)
        @page = params[:page] ? params[:page] : 0
        query = query.skip(@page * @results_per_page)

        # query results and total count for json
        @results = query
        @total_results = @results.count
        @total_pages = (@total_results/@results_per_page).ceil

      end
    end

    api :GET, '/retrieve_analysis', 'Retrieve an analysis.'
    formats ['json']
    description 'URL to get an analysis by name and user_id. Uniqueness is enforced; only 1 analysis will match a name and user_id combination.'
    param :name, String, desc: 'The machine name of the analysis', required: true
    param :user_id, String, desc: 'The user_id of the user that uploaded the analysis', required: true
    error :code => 401, desc: 'Unauthorized'
    error :code => 422, desc: 'Error present in request:  parameters missing'
    example %Q(GET http://<user>:<pwd>@<base_url>/api/retrieve_analysis?name="analysis_name"&user_id="123")

     # GET /retrieve_analysis?name=''&user_id=''
    def retrieve_analysis

      clean_params = retrieve_analysis_params
      if clean_params[:name] && clean_params[:user_id]

        @analysis = Analysis.where(name: clean_params[:name], user_id: clean_params[:user_id]).first
      else
        error = true
        error_messages = 'Parameter missing'
      end

      respond_to do |format|
        if !@error
          format.json {render 'analyses/show', location: @analysis}
        else
          format.json { render json: error_message, status: :unprocessable_entity }
        end
     end
     
    end

    api :POST, '/analysis', 'Add or update an analysis'
    formats ['json']
    description 'URL to post an analysis for structure(s).  An analysis_id will be returned if the request is successful, and will be needed to then post a structure.'
    param :analysis, Hash, desc: 'Hash of analysis descriptors, listed below:', required: true do
      param :name, String, desc: 'Machine name of the analysis'
      param :display_name, String, allow_nil: true, desc: 'Analysis display name'
      param :description, String, allow_nil: true, desc: 'Analysis description'
      param :user_defined_id, String, allow_nil: true, desc: 'User-specified unique identifier for the analysis'
      param :user_created_date, String, allow_nil: true,  desc: 'User-specified Date the analysis was run by the user (as opposed to date it was uploaded to DEnCity'
      param :analysis_types, Array, of: String, desc: 'Array of analysis types performed'
      param :analysis_information, Hash, desc: 'Hash of additional information to store about the analysis'   
    end
    param :measure_definitions, Array, desc: 'Array of hashes, each containing the following parameters:', required: true do
      param :id, String, desc: 'ID of the measure definition'
      param :version_id, String, desc: 'Version ID of the measure definition'
      param :display_name, String, allow_nil: true, desc: 'Measure Display Name'
      param :type, String, desc: 'Measure type'
      param :description, String, allow_nil: true, desc: 'Measure Description.'
      param :default_value, String, allow_nil: true, desc: 'Default measure value'
      param :arguments, Array, desc: 'Array of measure arguments. Note: Information specific to the instance of the measure (such as user-defined argument values) is posted via the measure_instances parameter of the structure resource.'
    end 
    error :code => 401, desc: 'Unauthorized'
    error :code => 422, desc: 'Error present in request:  parameters missing or file doesn\'t exists'
    example %Q(POST http://<user>:<pwd>@<base_url>/api/analysis, parameters: {"analysis":{"name":"test_analysis","display_name":"Testing Analysis","description":"Testing the add_analysis API","user_defined_id":<user defined id>,"user_created_date":"2014-07-25T15:30:41Z","analysis_types":["preflight","batch_run"],"analysis_information":{"sample_method":"individual_variables","run_max":true,"run_min":true,"run_mode":true,"run_all_samples_for_pivots":true,"objective_functions":["standard_report_legacy.total_energy","standard_report_legacy.total_source_energy"]}},"measure_definitions":[{"id":"8a70fa20-f63e-0131-cbb2-14109fdf0b37","version_id":"8a711470-f63e-0131-cbb4-14109fdf0b37","name":"SetXPathSingleVariable","display_name":null,"description":null,"modeler_description":null,"type":"XmlMeasure","arguments":[{"display_name":"Set XPath","display_name_short":"Set XPath","name":"xpath","description":"","units":""},{"display_name":"Location","display_name_short":"Location","name":"location","description":"","units":""}]},{"id":"8a726030-f63e-0131-cbc9-14109fdf0b37","version_id":"8a727a60-f63e-0131-cbcb-14109fdf0b37","name":"SetBuildingGeometry","display_name":null,"description":null,"modeler_description":null,"type":"XmlMeasure","arguments":[{"display_name":"Aspect Ratio Multiplier","display_name_short":"Aspect Ratio Multiplier","name":"aspect_ratio_multiplier","description":"","units":""},{"display_name":"Floor Plate Area Multiplier","display_name_short":"Floor Plate Area Multiplier","name":"floor_plate_area_multiplier","description":"","units":""}]}]}
)
    def analysis
      # API
      # POST /api/analysis.json
      authorize! :analysis, :api

      error = false
      error_messages = []
      warnings = []
      created_flag = false

      # Add new analysis
      if params[:analysis]
        clean_params = analysis_params
        logger.info(clean_params)

         # pull out the user create uuid if they have one, otherwise create a new one
        user_uuid = clean_params[:user_defined_id] ? clean_params[:user_defined_id] : SecureRandom.uuid

        # allow updating of previously uploaded analysis, must match user_uuid and user_id  
        @analysis = current_user.analyses.find_or_create_by(user_defined_id: user_uuid) do |a|
          created_flag = true
        end

        clean_params.except(:user_defined_id).each do |key, value|
          @analysis[key] = value
        end

        # add analysis_information (it's a hash and can't make it through the clean_params method)
        if params[:analysis][:analysis_information]
          @analysis.analysis_information = params[:analysis][:analysis_information]
        end

        @analysis.user = current_user

        unless @analysis.save!
          error = true
          error_messages << 'Could not save analysis.'
        end
      else
        # analysis does not belong to user
        error = true
        error_message << "The analysis #{@analysis.id} does not belong to you...cannot update."
        @analysis = nil
      end

      # Add measure descriptions
      if @analysis && params[:measure_definitions]

        params[:measure_definitions].each do |m|
          descs = MeasureDescription.where(uuid: m['id'], version_id: m['version_id'])
          if descs.count > 0
            warnings << "Measure definition already exists for uuid: #{m['id']} and version_id: #{m['version_id']}...could not save duplicate."
          else
            @def = MeasureDescription.new
            puts m.inspect

            @def.uuid = m['id']
            @def.version_id = m['version_id']
            @def.name = m['name']
            @def.display_name = m['display_name']
            @def.type = m['type']
            @def.description = m['description']
            @def.default_value = m['default_value']
            @def.modeler_description = m['modeler_description']
            @def.arguments = m['arguments']
            unless @def.save!
              error = true
              error_message << "Could not save measure definition #{m['id']}"
            end
          end
        end
      end

      respond_to do |format|
        # logger.info("error flag was set to #{error}")
        if error
          format.json { render json: { error: error_messages }, status: :unprocessable_entity }
        else
          p_id = @analysis.id.to_s
          j = @analysis.as_json.except('_id')
          j['id'] = p_id
          if created_flag
            status = :created
          else
            status = :ok
          end
          format.json { render json: { analysis: j, warnings: warnings }, status: status, location: analyses_url }
        end
      end
    end

    # apipie
    api :POST, '/structure', 'Add or update a structure'
    formats ['json']
    description 'Add or update a structure.  Must have previously uploaded an analysis.'
    param :metadata, Hash, desc:  'Metadata for structure', required: false do
      param :user_defined_id, String, allow_nil: true,  desc: 'User-defined unique identifier for the structure'
    end
    param :analysis_id, String, desc: 'Analysis ID this structure belongs to.', required: true
    param :structure, Array, of: Hash, desc: 'Array of hashes containing structure metadata. Each hash should contain the following parameters:', required: true do
      param :name, String, desc: 'Machine name of a metadatum already defined in DEnCity'
      param :value, String, desc: 'Value associated with the metadatum name'
    end
    param :measure_instances, Array, of: Hash, desc: 'Array of measure instance hashes applied to the structure.  Each array element should contain the parameters listed below:', required: false do
      param :uri, String, desc: 'URI of measure instance (from BCL)'
      param :id, String, desc: 'Unique identifier for measure instance'
      param :version_id, String, desc: 'Version identifier for the measure instance'
      param :arguments, Hash, desc: 'Measure instance arguments'
    end
    error :code => 401, desc: 'Unauthorized'
    error :code => 422, desc: 'Error present in request:  parameters missing or incorrect'
    example %Q(POST http://<user>:<pwd>@<base_url>/api/structure, parameters: {"analysis_id":<analysis_id,"structure":{"building_rotation":0,"infiltration_rate":2.00155,"lighting_power_density":3.88565,"site_energy_use":0,"total_occupancy":88.8,"total_building_area":3134.92},"measure_instances":[{"index":0,"uri":"https://bcl.nrel.gov","id":"8a70fa20-f63e-0131-cbb2-14109fdf0b37","version_id":"8a711470-f63e-0131-cbb4-14109fdf0b37","arguments":{"location":"AN_BC_Vancouver.718920_CWEC.epw","xpath":"/building/address/weather-file"}},{"index":1,"uri":"https://bcl.nrel.gov","id":"8a726030-f63e-0131-cbc9-14109fdf0b37","version_id":"8a727a60-f63e-0131-cbcb-14109fdf0b37","arguments":{}}],"metadata":{"user_defined_id":"test123"}})
    
    def structure
      # API
      # POST api/structure.json
      authorize! :structure, :api

      error = false
      error_messages = []
      warnings = []
      created_flag = false

      # Assign analysis
      if params[:analysis_id] && !params[:analysis_id].blank?
        prov = current_user.analyses.find(params[:analysis_id])
        unless prov
          error = true
          error_messages << "No analysis matching user and analysis_id #{params[:analysis_id]}...could not save structure."
        end
      else
        error = true
        error_messages << 'No analysis_id provided...could not save structure.'
      end

      unless error
        # Find or add a new structure
        # pull out the user create uuid if they have one, otherwise create a new one
        logger.info("HEY!  #{params[:metadata]}")
        user_uuid = (params[:metadata] && params[:metadata][:user_defined_id]) ? params[:metadata][:user_defined_id] : SecureRandom.uuid
      
        # allow updating of previously uploaded structures, must match user_uuid and user_id  
        @structure = current_user.structures.find_or_create_by(user_defined_id: user_uuid) do |a|
          created_flag = true
        end
        
        if params[:structure]
          params[:structure].each do |key, value|
            if Meta.where(name: key).count > 0
              # add to structure
              @structure[key] = value
            else
              warnings << "#{key} is not a defined metadata, cannot save this attribute."
            end
          end
          @structure.user = current_user
          @structure.analysis = prov
          unless @structure.save!
            error = true
            error_messages << 'Could not process structure'
          end
        else
          error = true
          error_messages << 'No structure provided.'
        end
      end  

      unless error
        # Save Measure Instances
        if params[:measure_instances]
          params[:measure_instances].each do |m|
            @measure = MeasureInstance.new
            # expecting these keys
            @measure.uri = m['uri']
            @measure.uuid = m['id']
            @measure.version_id = m['version_id']
            @measure.arguments = m['arguments']
            @measure.structure = @structure
            # TODO: user_id too?  duplicates?
            # TODO: warning if this doesn't match a measure description?
            desc = MeasureDescription.where(uuid: m['id'], version_id: m['version_id']).first
            @measure.measure_description = desc
            @measure.save!
          end
        end
      end

      respond_to do |format|
        if error
          format.json { render json: { error: error_messages, structure: @structure}, status: :unprocessable_entity }
        else
          if created_flag
            status = :created
          else
            status = :ok
          end
          format.json { render 'structures/show', :locals => { :warnings => warnings }, status: status, location: structures_url(@structure) }
        end
      end
    end

    # apipie
    api :POST, '/related_file', 'Add a related file to a structure'
    formats ['json']
    param :structure_id, String, desc: 'Structure ID to associate the file with', required: true
    param :file_data, Hash, desc: 'Hash containing 2 keys:', required: true do
      param :file_name, String, desc: 'Name of the file', required: true
      param :file, String, desc: 'Base64-encoded file data', required: true
    end
    error :code => 401, desc: 'Unauthorized'
    error :code => 422, desc: 'Error present in request:  parameters missing or file already exists'
   
    example %Q(POST http://<user>:<pwd>@<base_url>/api/related_file, parameters: {"structure_id":<structure_id>,"file_data":{"file_name":"file.txt","file":"bmFtZSxkaXNwbGF5X25hbWUsZGVzY3JpcHRpb24sdW5pdCxkYXRhdHlwZSx1c2VyX2RlZFsc2UNCg=="}})
    def related_file
      # API
      # POST /api/related_file.json
      # expects structure_id and file params
      # automatic 400 bad request if those params aren't found
      authorize! :related_file, :api

      error = false
      error_messages = []
      clean_params = file_params
      @structure = current_user.structures.find(clean_params[:structure_id])

      if !@structure
        error = true
        error_messages << "Structure #{@structure.id} could not be found."
      else
        basic_path = RELATED_FILES_BASIC_PATH
        # save to file_path:
        if clean_params[:file_data] && clean_params[:file_data][:file_name]
          file_name = clean_params[:file_data][:file_name]
          file = @structure.related_files.find_by_file_name(file_name)
          if file 
            error = true
            error_messages << "File #{file_name} already exists. Delete the file first and reupload."
          else
            file_uri = "#{basic_path}#{@structure.id}/#{file_name}"
            Dir.mkdir("#{Rails.root}#{basic_path}") unless Dir.exist?("#{Rails.root}#{basic_path}")
            Dir.mkdir("#{Rails.root}#{basic_path}#{@structure.id}/") unless Dir.exist?("#{Rails.root}#{basic_path}#{@structure.id}/")

            the_file = File.open("#{Rails.root}/#{file_uri}", 'wb') do |f|
              f.write(Base64.strict_decode64(clean_params[:file_data][:file]))
            end
            @rf = RelatedFile.add_from_path(file_uri)
            @structure.related_files << @rf
            @structure.save
          end
        else
          error = true
          error_messages << 'No file data to save.'
        end
      end
      respond_to do |format|
        if error
          format.json { render json: { error: error_messages, related_file: @rf }, status: :unprocessable_entity }
        else
          format.json { render json: { related_file: @rf }, status: :created, location: structure_url(@structure) }
        end
      end
    end

    # apipie
    api :POST, '/remove_file', 'Remove a related file from a structure'
    formats ['json']
    param :structure_id, String, desc: 'Structure ID the file belongs to.', required: true
    param :file_name, String, desc: 'Name of the file to remove', required: true 
    error :code => 401, desc: 'Unauthorized'
    error :code => 422, desc: 'Error present in request:  parameters missing or file doesn\'t exists'
    
    example %Q(POST http://<user>:<pwd>@<base_url>/api/related_file, parameters: {"structure_id":<structure_id>,"file_data":{"file_name":"file.txt","file":"bmFtZSxkaXNwbGF5X25hbWUsZGVzY3JpcHRpb24sdW5pdCxkYXRhdHlwZSx1c2VyX2RlZFsc2UNCg=="}})
    def remove_file
      authorize! :remove_file, :api

      error = false
      error_messages = []
      clean_params = remove_file_params
      @structure = current_user.structures.find(clean_params[:structure_id])

      if !@structure
        error = true
        error_messages << "Structure #{@structure.id} could not be found."
      else

        basic_path = RELATED_FILES_BASIC_PATH
        if clean_params[:file_name]
          file_name = clean_params[:file_name]
          file = @structure.related_files.find_by_file_name(file_name)

          if file
            # delete the file from disk
            if Rails.application.config.storage_type == :local_file
              logger.info(" FILE!! #{file.inspect}")
              File.delete("#{Rails.root}/#{file.uri}")
            else
              # TODO delete from s3
            end
            # delete from structure
            @structure.related_files.delete(file)
          else
            error = true
            error_messages << "No file named #{file_name} to delete."
          end

        else
          error = true
          error_messages << 'No file_name specified.'
        end 
      end

      respond_to do |format|
        if error
          format.json { render json: { error: error_messages }, status: :unprocessable_entity }
        else
          format.json { render json: {}, status: :no_content}
        end
      end
    end

    # apipie
    api :POST, '/meta_upload', 'Add one metadatum'
    formats ['json']
    description 'Add a new metadatum.  Metadata are the parameters that describe structures.'
    param :meta, Hash, desc:  'Metadatum', required: true do
      param :name, String, desc: 'Metadatum machine name'
      param :display_name, String, allow_nil: true, desc: 'Metadatum display name'
      param :short_name, String, allow_nil: true,  desc: 'Metadatum short name'
      param :unit, String, desc: 'Metadatum Units.  Must choose from Project Haystack units already defined at dencity.org/units'
      param :datatype, String, desc: 'Metadatum datatype. Select from string, double, integer, '
      param :description, String, desc: 'Metadatum description'
      param :user_defined, String, desc: 'True if unit is added by user, false if unit is added by admin.'
    end
    error :code => 401, desc: 'Unauthorized'
    error :code => 422, desc: 'Error present in request:  parameters missing or incorrect'
    example %Q(POST http://<user>:<pwd>@<base_url>/api/meta_upload, parameters: {"meta":{"name":"total_electricity","display_name":"Total Electricity","short_name":"Total Elec","description":"Total electricity usage","unit":"megajoules_per_square_meter", "datatype":"double","user_defined":false}}
)
   # POST /api/meta_upload.json
    # upload metadata fields
    def meta_upload
      error = false
      error_message = ''

      # Add new metadata
      if params[:meta]
        clean_params = meta_params
        logger.info("clean_params: #{clean_params}")
        @meta = Meta.new(clean_params)

        # TODO: ensure that user_defined is set to true if non-admin is using this action

        # check for units machine name match
        if clean_params[:unit].nil?
          error = true
          error_message += "could not save #{@meta.name}, no unit specified. If no units are applicable, set unit to 'none'"
        else
          units = Unit.where(name: clean_params[:unit])
          if units.count == 0
            error = true
            error_message += "could not save #{@meta.name}, no match found for unit #{@meta.unit}."
          elsif !units.first.allowable
            puts "could not save #{@meta.name}, unit #{clean_params[:unit]} is not allowable."
          else
            @meta.unit = units.first
          end
        end
        unless error
          unless @meta.save!
            error = true
            error_message += "could not proccess #{@meta.errors}."
          end
        end
      end

      respond_to do |format|
        logger.info("error flag was set to #{error}")
        if !error
          format.json { render json: "Created #{@meta.name}", status: :created, location: metas_url }
        else
          format.json { render json: error_message, status: :unprocessable_entity }
        end
      end
    end

    #apipie
    api :POST, '/meta_batch_upload', 'Add multiple metadata'
    formats ['json']
    description 'Add multiple metadata.  Metadata are the parameters that describe structures.'
    param :metadata, Array, desc:  'Array of metadata hashes', required: true do
      param :name, String, desc: 'Metadatum machine name'
      param :display_name, String, allow_nil: true, desc: 'Metadatum display name'
      param :short_name, String, allow_nil: true, desc: 'Metadatum short name'
      param :unit, String, desc: 'Metadatum Units.  Must choose from Project Haystack units already defined at dencity.org/units'
      param :datatype, String, desc: 'Metadatum datatype. Select from string, double, integer, '
      param :description, String, desc: 'Metadatum description'
      param :user_defined, String, desc: 'True if unit is added by user, false if unit is added by admin.'
    end
    error :code => 401, desc: 'Unauthorized'
    error :code => 422, desc: 'Error present in request:  parameters missing or incorrect'
    example %Q(POST http://<user>:<pwd>@<base_url>/api/meta_batch_upload, parameters: {"metadata":[{"name":"total_electricity","display_name":"Total Electricity","short_name":"Total Elec"," description":" Total electricity usage","unit":"megajoules_per_square_meter","datatype":"double","user_defined":false},{"name":"total_natural_gas","display_name":"Total Natural Gas","short_name":" Total Gas"," description":" Total gas usage","unit":"megajoules_per_square_meter","datatype":"double","user_defined":false}]}
)
    # POST /api/meta_batch_upload.json
    # Batch upload metadata fields (admin only)
    def meta_batch_upload
      error = false
      error_message = ''
      saved_metas = 0

      # Add new metadata
      if params[:metadata]
        clean_params = meta_batch_params
        clean_params[:metadata].each do |meta|
          @meta = Meta.new(meta)
          # TODO: ensure that user_defined is set?

          # check for units machine name match
          if meta[:unit].nil?
            error = true
            error_message += "could not save #{@meta.name}, no units specified. If no units are applicable, set units to 'none'"
            next
          else
            units = Unit.where(name: meta[:unit])
            if units.count == 0
              error = true
              error_message += "could not save #{@meta.name}, no match found for units #{meta[:unit]}."
              next
            elsif !units.first.allowable
              error = true
              error_message += "could not save #{@meta.name}, units #{meta[:unit]} are not allowable."
              next
            else
              @meta.unit = units.first
            end
          end
          if @meta.save!
            saved_metas += 1
          else
            error = true
            error_message += "could not proccess #{@meta.errors}."
          end
        end
      end

      respond_to do |format|
        logger.info("error flag was set to #{error}")
        if !error
          format.json { render json: "Created #{saved_metas} metadata entries from #{clean_params[:metadata].count} uploaded.", status: :created, location: metas_url }
        else
          format.json { render json: error_message, status: :unprocessable_entity }
        end
      end
    end

    def check_auth
      authenticate_or_request_with_http_basic do |username, password|
        resource = User.find_by(email: username)
        puts resource.email
        sign_in :user, resource if resource.valid_password?(password)
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def analysis_params
      params.require(:analysis).permit(:name, :display_name, :description, :user_defined_id, :user_created_date, analysis_types: [])
      # analysis_information: {:sample_method, :run_max, :run_min, :run_mode, :run_all_samples_for_pivots, objective_functions: [] }
    end

    def file_params
      params.require(:structure_id)
      params.permit(:structure_id, file_data: [:file_name, :file])
    end

    def remove_file_params
      params.require(:structure_id)
      params.permit(:structure_id, :file_name)
    end

    def search_params
      params.permit(:page, filters: [:name, :value, :operator], return_only: [])
    end

    def meta_batch_params
      params.permit(metadata: [:name, :display_name, :short_name, :unit, :datatype, :description, :user_defined])
    end

    def meta_params
      params.require(:meta).permit(:name, :display_name, :short_name, :unit, :datatype, :description, :user_defined)
    end

    def retrieve_analysis_params
      params.permit(:name, :user_id)
    end
  end
end