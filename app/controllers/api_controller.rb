class ApiController < ApplicationController
  before_filter :check_auth, except: :search

  respond_to :json

  def structure
    # API
    # POST api/structure.json
    authorize! :structure, :api

    error = false
    error_messages = []
    warnings = []

    # Find or add a new structure
    if params[:metadata]
      # pull out the user create uuid if they have one, otherwise create a new one
      user_uuid = params[:metadata][:user_defined_id] ? params[:metadata][:user_defined_id] : SecureRandom.uuid

      # allow editing of previously uploaded structures, must match user_uuid and user_id  
      @structure = current_user.structures.find_or_create_by(user_defined_id: user_uuid)
      # set the 'date generated' field
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

      # Assign analysis
      if params[:analysis_id] && !params[:analysis_id].blank?
        prov = Analysis.find_by(id: params[:analysis_id], user: @structure.user)
        if prov
          @structure.analysis = prov
        else
          error = true
          error_messages << "No analysis matching user and analysis_id #{params[:analysis_id]}...could not save structure."
        end
      else
        error = true
        error_messages << 'No analysis_id provided...could not save structure.'
      end

      unless error
        unless @structure.save!
          error = true
          error_messages << 'Could not process structure'
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
        if !error
          format.json { render json: { structure: @structure, warnings: warnings }, status: :created, location: structure_url(@structure) }
        else
          format.json { render json: { error: error_messages, structure: @structure }, status: :unprocessable_entity }
        end
      end
    end
  end

  def related_file
    # API
    # POST /api/related_file.json
    # expects structure_id and file params
    # automatic 400 bad request if those params aren't found
    authorize! :analysis, :api

    error = false
    error_messages = []

    clean_params = file_params

    @structure = Structure.find(clean_params[:structure_id])
    basic_path = RELATED_FILES_BASIC_PATH

    # save to file_path:
    if clean_params[:file_data] && clean_params[:file_data][:file_name]
      file_name = clean_params[:file_data][:file_name]
      file_uri = "#{basic_path}#{@structure.id}/#{file_name}"

      Dir.mkdir("#{Rails.root}#{basic_path}") unless Dir.exist?("#{Rails.root}#{basic_path}")
      Dir.mkdir("#{Rails.root}#{basic_path}#{@structure.id}/") unless Dir.exist?("#{Rails.root}#{basic_path}#{@structure.id}/")

      the_file = File.open("#{Rails.root}/#{file_uri}", 'wb') do |f|
        f.write(Base64.strict_decode64(clean_params[:file_data][:file]))
      end

      @rf = RelatedFile.add_from_path(file_uri)

      @structure.related_files << @rf
      @structure.save

    else
      error = true
      error_messages << 'No file data to save.'
    end

    respond_to do |format|
      if !error
        format.json { render json: { related_file: @rf }, status: :created, location: structure_url(@structure) }
      else
        format.json { render json: { error: error_messages, related_file: @rf }, status: :unprocessable_entity }
      end
    end
  end

  def analysis
    # API
    # POST /api/analysis.json
    authorize! :analysis, :api

    error = false
    already_exists = false
    error_messages = []
    warnings = []

    # Add new analysis
    if params[:analysis]
      clean_params = analysis_params

      # check if the analysis name already exists?
      if Analysis.where(name: clean_params[:name]).first
        error = false
        already_exists = true
        warnings << "Analysis already exists with the name #{clean_params[:name]}"
        @analysis = Analysis.where(name: clean_params[:name]).first
      else
        @analysis = Analysis.new(clean_params)
        # add analysis_information (it's a hash and can't make it through the clean_params method)
        if params[:analysis][:analysis_information]
          @analysis.analysis_information = params[:analysis][:analysis_information]
        end

        @analysis.user = current_user

        unless @analysis.save!
          error = true
          error_messages << 'Could not process analysis'
        end
      end
    end

    # Add measure descriptions
    if @analysis && params[:measure_definitions] && !already_exists

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
      if !error
        p_id = @analysis.id.to_s
        j = @analysis.as_json.except('_id')
        j['id'] = p_id
        format.json { render json: { analysis: j, warnings: warnings }, status: :created, location: analyses_url }
      else
        format.json { render json: { error: error_messages }, status: :unprocessable_entity }
      end
    end
  end

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

  def search_params
    params.permit(:page, filters: [:name, :value, :operator], return_only: [])
  end
end
