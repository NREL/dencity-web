class StructuresController < ApplicationController
  load_and_authorize_resource param_method: :structure_params
  before_action :set_structure, only: [:show, :edit, :update, :destroy]

  # GET /structures
  # GET /structures.json
  def index
    @structures = Structure.order_by(:created_at.desc).limit(500)
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
