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
  # upload metadata fields
  def meta_upload

    error = false
    error_message = ""

    # Add new metadata
    if params[:meta]
      clean_params = meta_params
      @meta = Meta.new(clean_params)

      # TODO: ensure that user_defined is set to true if non-admin is using this action

      # check for units machine name match
      if @meta.units.nil?
        error = true
        error_message += "could not save #{@meta.name}, no unit specified. If no units are applicable, set unit to 'none'"
      else
        units = Unit.where(name: @meta.units)
        if units.count == 0
          error = true
          error_message += "could not save #{@meta.name}, no match found for unit #{@meta.units}."
        elsif !units.first.allowable
          puts "could not save #{@meta.name}, unit #{r[:unit]} is not allowable."
          next
        else
          @meta.units = units.first
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

  # POST /api/meta_batch_upload.json
  # Batch upload metadata fields (admin only)
  def meta_batch_upload

    error = false
    error_message = ""
    saved_metas = 0

    # Add new metadata
    if params[:metadata]
      clean_params = meta_batch_params
      clean_params[:metadata].each do |meta|
        @meta = Meta.new(meta)
        # TODO: ensure that user_defined is set?

        # check for units machine name match
        if @meta.unit.nil?
          error = true
          error_message += "could not save #{@meta.name}, no units specified. If no units are applicable, set units to 'none'"
          next
        else
          units = Unit.where(name: @meta.unit)
          if units.count == 0
            error = true
            error_message += "could not save #{@meta.name}, no match found for units #{@meta.unit}."
            next
          elsif !units.first.allowable
            error = true
            error_message += "could not save #{@meta.name}, units #{@meta.unit} are not allowable."
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
private

  # Use callbacks to share common setup or constraints between actions.
  def set_meta
    @meta = Meta.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def meta_batch_params
    params.permit(metadata: [:name, :display_name, :unit, :datatype, :description, :user_defined])
  end
  def meta_params
    params.require(:meta).permit(:name, :display_name, :unit, :datatype, :description, :user_defined)
  end

end
