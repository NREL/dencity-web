class MeasureDescriptionsController < ApplicationController
  load_and_authorize_resource param_method: :measure_description_params
  before_action :set_measure_description, only: [:show, :edit, :update, :destroy]

  # GET /measure_descriptions
  # GET /measure_descriptions.json
  def index
    @measure_descriptions = MeasureDescription.all
  end

  # GET /measure_descriptions/1
  # GET /measure_descriptions/1.json
  def show
  end

  # GET /measure_descriptions/new
  def new
    @measure_description = MeasureDescription.new
  end

  # GET /measure_descriptions/1/edit
  def edit
  end

  # POST /measure_descriptions
  # POST /measure_descriptions.json
  def create
    @measure_description = MeasureDescription.new(measure_description_params)

    respond_to do |format|
      if @measure_description.save
        format.html { redirect_to @measure_description, notice: 'Measure description was successfully created.' }
        format.json { render action: 'show', status: :created, location: @measure_description }
      else
        format.html { render action: 'new' }
        format.json { render json: @measure_description.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /measure_descriptions/1
  # PATCH/PUT /measure_descriptions/1.json
  def update
    respond_to do |format|
      if @measure_description.update(measure_description_params)
        format.html { redirect_to @measure_description, notice: 'Measure description was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @measure_description.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /measure_descriptions/1
  # DELETE /measure_descriptions/1.json
  def destroy
    @measure_description.destroy
    respond_to do |format|
      format.html { redirect_to measure_descriptions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measure_description
      @measure_description = MeasureDescription.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measure_description_params
      params[:measure_definitions]
    end
end
