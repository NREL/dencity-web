class ProvenancesController < ApplicationController
  load_and_authorize_resource param_method: :provenance_params
  before_action :set_provenance, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => [:add_provenance]

  # GET /provenances
  # GET /provenances.json
  def index
    @provenances = Provenance.all
  end

  # GET /provenances/1
  # GET /provenances/1.json
  def show
  end

  # GET /provenances/new
  def new
    @provenance = Provenance.new
  end

  # GET /provenances/1/edit
  def edit
  end

  # POST /provenances
  # POST /provenances.json
  def create
    @provenance = current_user.provenances.new(provenance_params)

    respond_to do |format|
      if @provenance.save
        format.html { redirect_to @provenance, notice: 'Provenance was successfully created.' }
        format.json { render action: 'show', status: :created, location: @provenance }
      else
        format.html { render action: 'new' }
        format.json { render json: @provenance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /provenances/1
  # PATCH/PUT /provenances/1.json
  def update
    respond_to do |format|
      if @provenance.update(provenance_params)
        format.html { redirect_to @provenance, notice: 'Provenance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @provenance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /provenances/1
  # DELETE /provenances/1.json
  def destroy
    @provenance.destroy
    respond_to do |format|
      format.html { redirect_to provenances_url }
      format.json { head :no_content }
    end
  end

  # API
  # POST /api/add_provenance.json
  def add_provenance
    error = false
    error_message = ""

    # Add new provenance
    if params[:provenance]
      clean_params = provenance_params
      @provenance = Provenance.new(clean_params)

      #TODO: right now assigns all to first user. Eventually pass in user credentials
      @provenance.user = User.first

      unless @provenance.save!
        error = true
        error_message += "Could not process provenance"
      end
    end

    respond_to do |format|
      #logger.info("error flag was set to #{error}")
      if !error
        format.json { render json: "Created provenance #{@provenance.id}", status: :created, location: provenances_url }
      else
        format.json { render json: error_message, status: :unprocessable_entity }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provenance
      @provenance = Provenance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def provenance_params
      params.require(:provenance).permit(:name, :display_name, :description, :user_defined_id, :user_created_date, analysis_types: [], analysis_information: {})
      #:sample_method, :run_max, :run_min, :run_mode, :run_all_samples_for_pivots, objective_functions: []
    end
end
