# Structures controller
class StructuresController < ApplicationController


  # GET /structures
  # GET /structures.json
  def index
    @structures = Structure.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @structures }
    end
  end


end
