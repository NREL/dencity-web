class AnalysesController < ApplicationController
  #require 'will_paginate/array'
  load_and_authorize_resource
  before_action :set_analysis, only: [:show, :edit, :update, :destroy, :buildings]
  # skip_before_filter :verify_authenticity_token, only: [:add_analysis]

  # GET /analyses
  # GET /analyses.json
  def index
    @analyses = Analysis.all
  end

  # GET analyses/buildings
  def buildings
    params[:per_page] ||= 100
    params[:page] ||= 1
    @search = Structure.solr_search do
      with(:analysis_id, params[:id])
      paginate page: params[:page], per_page: params[:per_page]
    end
   end

  # GET /analyses/1
  # GET /analyses/1.json
  def show
  end

   # GET /analyses/new
  def new
    @analyses = Analysis.new
  end

  # GET /analyses/1/edit
  def edit
  end

  # POST /analyses
  # POST /analyses.json
  def create
    @analysis = current_user.analyses.new(analysis_params)

    respond_to do |format|
      if @analysis.save
        format.html { redirect_to @analysis, notice: 'Analysis was successfully created.' }
        format.json { render action: 'show', status: :created, location: @analysis }
      else
        format.html { render action: 'new' }
        format.json { render json: @analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /analyses/1
  # PATCH/PUT /analyses/1.json
  def update
    respond_to do |format|
      if @analysis.update(analysis_params)
        format.html { redirect_to @analysis, notice: 'Analysis was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analyses/1
  # DELETE /analyses/1.json
  def destroy
    @analysis.destroy
    respond_to do |format|
      format.html { redirect_to analyses_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_analysis
    @analysis = Analysis.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def analysis_params
    params.require(:analysis).permit(:name, :display_name, :description, :user_defined_id, :user_created_date, :user_id, analysis_types: [])
    # analysis_information: {:sample_method, :run_max, :run_min, :run_mode, :run_all_samples_for_pivots, objective_functions: [] }
  end
end
