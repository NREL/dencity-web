class MetasController < ApplicationController
  before_action :set_meta, only: [:show, :edit, :update, :destroy]

  # GET /metas
  # GET /metas.json
  def index
    @metas = Meta.all
    respond_to do |format|
      format.html
      format.json {render json: { :metadata => @metas } }
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

  # POST /api/meta_upload.json
  # Batch upload metadata fields
  def meta_upload

    error = false
    saved_metas = 0

    # Add new metadata
    if params[:metadata]
      clean_params = meta_params
      clean_params[:metadata].each do |meta|
        @meta = Meta.new(meta)
        # TODO: ensure that user_defined is set?
        if @meta.save!
          saved_metas += 1
        else
          error = true
          error_message += "could not proccess #{@meta.errors}"
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

private

  # Use callbacks to share common setup or constraints between actions.
  def set_meta
    @meta = Meta.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def meta_params
    params.permit(metadata: [:name, :display_name, :units, :datatype, :description, :user_defined, :validation])
  end
end
