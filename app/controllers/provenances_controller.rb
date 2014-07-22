class ProvenancesController < ApplicationController
  before_action :set_provenance, only: [:show, :edit, :update, :destroy]

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
    @provenance = Provenance.new(provenance_params)

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provenance
      @provenance = Provenance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def provenance_params
      params[:provenance]
    end
end
