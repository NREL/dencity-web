class MeasureInstancesController < ApplicationController
  load_and_authorize_resource param_method: :measure_instance_params
  before_action :set_measure_instance, only: [:show, :edit, :update, :destroy]

  # GET /measure_instances
  # GET /measure_instances.json
  def index
    @structure = Structure.find(params[:structure_id])
    @measure_instances = MeasureInstance.where(structure_id: params[:structure_id])

  end

  # GET /measure_instances/1
  # GET /measure_instances/1.json
  def show
  end

  # GET /measure_instances/new
  def new
    @measure_instance = MeasureInstance.new
  end

  # GET /measure_instances/1/edit
  def edit
  end

  # POST /measure_instances
  # POST /measure_instances.json
  def create
    @measure_instance = MeasureInstance.new(measure_instance_params)

    respond_to do |format|
      if @measure_instance.save
        format.html { redirect_to @measure_instance, notice: 'Measure instance was successfully created.' }
        format.json { render action: 'show', status: :created, location: @measure_instance }
      else
        format.html { render action: 'new' }
        format.json { render json: @measure_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /measure_instances/1
  # PATCH/PUT /measure_instances/1.json
  def update
    respond_to do |format|
      if @measure_instance.update(measure_instance_params)
        format.html { redirect_to @measure_instance, notice: 'Measure instance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @measure_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /measure_instances/1
  # DELETE /measure_instances/1.json
  def destroy
    @measure_instance.destroy
    respond_to do |format|
      format.html { redirect_to measure_instances_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measure_instance
      @measure_instance = MeasureInstance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measure_instance_params
      clean_params = params.require(:measure_instance).permit(:uuid, :version_id, :uri, structure_attributes: [:id])
    end
end
