class StructuresController < ApplicationController
  load_and_authorize_resource param_method: :structure_params
  before_action :set_structure, only: [:show, :edit, :update, :destroy]

  # GET /structures
  # GET /structures.json
  def index
    @structures = Structure.all
  end

  # GET /structures/1
  # GET /structures/1.json
  def show
  end

  # GET /structures/new
  def new
    @structure = Structure.new
  end

  # GET /structures/1/edit
  def edit
  end

  # POST /structures
  # POST /structures.json
  def create
    @structure = current_user.structures.new(structure_params)

    respond_to do |format|
      if @structure.save
        format.html { redirect_to @structure, notice: 'Structure was successfully created.' }
        format.json { render action: 'show', status: :created, location: @structure }
      else
        format.html { render action: 'new' }
        format.json { render json: @structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /structures/1
  # PATCH/PUT /structures/1.json
  def update
    respond_to do |format|
      if @structure.update(structure_params)
        format.html { redirect_to @structure, notice: 'Structure was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /structures/1
  # DELETE /structures/1.json
  def destroy
    @structure.destroy
    respond_to do |format|
      format.html { redirect_to structures_url }
      format.json { head :no_content }
    end
  end

  # API
  # POST api/add_structure.json
  def add_structure

    #TODO: validate each param against the metas table before accepting it!
    #TODO: add provenance link (must have already uploaded provenance, link by name & user). provenance_name in json file as param
    error = false
    error_message = ""


    # Add new structure
    if params[:structure]

      @structure = Structure.new()
      params[:structure].each do |key, value|
        if Meta.where(:name => key).count > 0
          # add to structure
          @structure[key] = value
        else
          puts "#{key} is not a defined metadata, cannot save this attribute."
        end
      end

      #TODO: right now assigns all to first user. Eventually pass in user credentials
      @structure.user = User.first

      # Assign provenance
      if params[:provenance_name]
        puts "provenance name: #{params[:provenance_name]}"
        provs = Provenance.where(:name => params[:provenance_name], :user => @structure.user)
        if provs.count > 0
          @structure.provenance = provs.first
        end
      end

      unless @structure.save!
        error = true
        error_message += "Could not process structure"
      end

      # Save Measure Instances
      if params[:measure_instances]
        params[:measure_instances].each do |m|
          @measure = MeasureInstance.new()
          #expecting these keys
          @measure.index = m['index']
          @measure.uri = m['uri']
          @measure.uuid = m['id']
          @measure.version_id = m['version_id']
          @measure.arguments = m['arguments']
          @measure.structure = @structure
          @measure.measure_description = MeasureDescription.where(:uuid => m['uuid'], :version_id => m['version_id']).first
          @measure.save!
        end
      end
    end


    respond_to do |format|
      # logger.info("error flag was set to #{error}")
      if !error
        format.json { render json: "Created structure #{@structure.id}", status: :created, location: structure_url(@structure) }
      else
        format.json { render json: error_message, status: :unprocessable_entity }
      end
    end
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_structure
    @structure = Structure.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def structure_params
    params.require(:structure).permit(:name, :other_field, provenance_attributes: [:id], user_attributes: [:id])
  end
end
