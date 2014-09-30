class ApiController < ApplicationController

  before_filter :check_auth

  def structure
    # API
    # POST api/structure.json
    error = false
    error_messages = []
    warnings = []

    # Find or add a new structure
    if params[:metadata]
      # pull out the user create uuid if they have one, otherwise create a new one
      user_uuid = params[:metadata][:user_defined_id] ? params[:metadata][:user_defined_id] : SecureRandom.uuid

      @structure = Structure.find_or_create_by(user_defined_id: user_uuid)
      # set the 'date generated' field
    end

    if params[:structure]
      params[:structure].each do |key, value|
        if Meta.where(:name => key).count > 0
          # add to structure
          @structure[key] = value
        else
          warnings << "#{key} is not a defined metadata, cannot save this attribute."
        end
      end

      @structure.user = current_user

      # Assign provenance
      if params[:provenance_id] && !params[:provenance_id].blank?
        prov = Provenance.find_by(:id => params[:provenance_id], :user => @structure.user)
        if prov
          @structure.provenance = prov
        else
          error = true
          error_messages << "No provenance matching user and provenance_id #{params[:provenance_id]}...could not save structure."
        end
      else
        error = true
        error_messages << 'No provenance_id provided...could not save structure.'
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
            #expecting these keys
            @measure.uri = m['uri']
            @measure.uuid = m['id']
            @measure.version_id = m['version_id']
            @measure.arguments = m['arguments']
            @measure.structure = @structure
            #TODO: user_id too?  duplicates?
            #TODO: warning if this doesn't match a measure description?
            desc = MeasureDescription.where(:uuid => m['id'], :version_id => m['version_id']).first
            @measure.measure_description = desc
            @measure.save!
          end
        end
      end

      respond_to do |format|
        if !error
          format.json { render json: {structure: @structure, warnings: warnings}, status: :created, location: structure_url(@structure) }
        else
          format.json { render json: {error: error_messages, structure: @structure}, status: :unprocessable_entity }
        end
      end
    end
  end

  def analysis
    # API
    # POST /api/analysis.json

    error = false
    already_exists = false
    error_messages = []
    warnings = []

    # Add new provenance
    if params[:provenance]
      clean_params = provenance_params

      # check if the provenance name already exists?
      if Provenance.where(name: clean_params[:name]).first
        error = false
        already_exists = true
        warnings << "Provenance already exists with the name #{clean_params[:name]}"
        @provenance = Provenance.where(name: clean_params[:name]).first
      else
        @provenance = Provenance.new(clean_params)
        # add analysis_information (it's a hash and can't make it through the clean_params method)
        if params[:provenance][:analysis_information]
          @provenance.analysis_information = params[:provenance][:analysis_information]
        end

        @provenance.user = current_user

        unless @provenance.save!
          error = true
          error_messages << "Could not process provenance"
        end
      end
    end

    # Add measure descriptions
    if @provenance && params[:measure_definitions] && !already_exists

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
      #logger.info("error flag was set to #{error}")
      if !error
        p_id = @provenance.id.to_s
        j = @provenance.as_json.except('_id')
        j['id'] = p_id
        format.json { render json: {provenance: j, warnings: warnings}, status: :created, location: provenances_url }
      else
        format.json { render json: {error: error_messages}, status: :unprocessable_entity }
      end
    end
  end

  def check_auth
    authenticate_or_request_with_http_basic do |username, password|

      resource = User.find_by(email: username)
      puts resource.email
      if resource.valid_password?(password)
        sign_in :user, resource
      end
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def provenance_params
    params.require(:provenance).permit(:name, :display_name, :description, :user_defined_id, :user_created_date, analysis_types: [])
    #analysis_information: {:sample_method, :run_max, :run_min, :run_mode, :run_all_samples_for_pivots, objective_functions: [] }
  end
end
