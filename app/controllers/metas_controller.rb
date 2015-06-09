class MetasController < ApplicationController
  load_and_authorize_resource param_method: :meta_params
  before_action :set_meta, only: [:show, :edit, :update, :destroy]

  # GET /metas
  # GET /metas.json
  def index
    @metas = Meta.all.order(display_name: :asc)
    respond_to do |format|
      format.html
      format.json { render json: { metadata: @metas } }
    end
  end

  # GET /metas/1
  # GET /metas/1.json
  def show
  end

  # GET /metas/new
  def new
    @meta = Meta.new
  end

  # GET /metas/1/edit
  def edit
  end

  # POST /metas
  # POST /metas.json
  def create
    @meta = Meta.new(meta_params)

    respond_to do |format|
      if @meta.save
        format.html { redirect_to @meta, notice: 'Metas was successfully created.' }
        format.json { render action: 'show', status: :created, location: @meta }
      else
        format.html { render action: 'new' }
        format.json { render json: @meta.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /metas/1
  # PATCH/PUT /metas/1.json
  def update
    respond_to do |format|
      if @meta.update(meta_params)
        format.html { redirect_to @meta, notice: 'Metas was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @meta.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metas/1
  # DELETE /metas/1.json
  def destroy
    @meta.destroy
    respond_to do |format|
      format.html { redirect_to metas_index_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_meta
    @meta = Meta.find(params[:id])
  end

  def meta_params
    params.require(:meta).permit(:name, :display_name, :short_name, :unit, :datatype, :description, :user_defined)
  end
end
