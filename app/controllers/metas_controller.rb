class MetasController < ApplicationController

  # Batch upload metadata fields
  def meta_upload

    error = false
    saved_metas = 0
    uploaded_metas = 0

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
        format.json { render json: "Created #{saved_metas} metadata entries from #{uploaded_metas} uploaded.", status: :created, location: metas_url }
      else
        format.json { render json: error_message, status: :unprocessable_entity }
      end
    end
  end


  # Retrieve all metadata fields
  def index
    @metas = Meta.all

    respond_to do |format|
      format.html
      format.json {render json: { :metadata => @metas } }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through
  def meta_params
    params.permit(metadata: [ :name, :display_name, :units, :datatype, :description, :user_defined, :validation ] )
  end

end
