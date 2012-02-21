class InputsController < ApplicationController
  # GET /inputs
  # GET /inputs.xml
  def index
    @inputs = Input.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inputs }
    end
  end

  # GET /inputs/1
  # GET /inputs/1.xml
  def show
    @input = Input.find(params[:id])
    attrs = @input.attributes
    @keys = attrs.keys

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @input }
    end
  end

  # GET /inputs/new
  # GET /inputs/new.xml
  def new
    @input = Input.new
    @building_types = get_building_types()
    @climate_zones = get_climate_zones()

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @input }
    end
  end

  # GET /inputs/1/edit
  def edit
    @input = Input.find(params[:id])
  end

  # POST /inputs
  # POST /inputs.xml
  def create
    @input = Input.new(params[:input])
    @input.created_at = Time.now

    respond_to do |format|
      if @input.save
        format.html { redirect_to(@input, :notice => 'Input was successfully created.') }
        format.xml  { render :xml => @input, :status => :created, :location => @input }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @input.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inputs/1
  # PUT /inputs/1.xml
  def update
    @input = Input.find(params[:id])

    respond_to do |format|
      if @input.update_attributes(params[:input])
        format.html { redirect_to(@input, :notice => 'Input was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @input.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inputs/1
  # DELETE /inputs/1.xml
  def destroy
    @input = Input.find(params[:id])
    @input.destroy

    respond_to do |format|
      format.html { redirect_to(inputs_url) }
      format.xml  { head :ok }
    end
  end
  
  
  private
  def get_climate_zones
    #get climate zones by group
    @climate_zones =
    {
      'ASHRAE 90.1 2004' => [['1A', 'ASHRAE 90.1 2004 Zone 1A'],
                             ['1B', 'ASHRAE 90.1 2004 Zone 1B'],
                             ['2A', 'ASHRAE 90.1 2004 Zone 2A'],
                             ['2B', 'ASHRAE 90.1 2004 Zone 2B'],
                             ['3A', 'ASHRAE 90.1 2004 Zone 3A'],
                             ['3B', 'ASHRAE 90.1 2004 Zone 3B'],
                             ['3C', 'ASHRAE 90.1 2004 Zone 3C'],
                             ['4A', 'ASHRAE 90.1 2004 Zone 4A'],
                             ['4B', 'ASHRAE 90.1 2004 Zone 4B'],
                             ['4C', 'ASHRAE 90.1 2004 Zone 4C'],
                             ['5A', 'ASHRAE 90.1 2004 Zone 5A'],
                             ['5B', 'ASHRAE 90.1 2004 Zone 5B'],
                             ['5C', 'ASHRAE 90.1 2004 Zone 5C'],
                             ['6A', 'ASHRAE 90.1 2004 Zone 6A'],
                             ['6B', 'ASHRAE 90.1 2004 Zone 6B'],
                             ['7', 'ASHRAE 90.1 2004 Zone 7'],
                             ['8', 'ASHRAE 90.1 2004 Zone 8']],
      
      'CEC Title 24 2008' => [['1', 'CEC Title 24 2008 Zone 1'],
                              ['2', 'CEC Title 24 2008 Zone 2'],
                              ['3', 'CEC Title 24 2008 Zone 3'],
                              ['4', 'CEC Title 24 2008 Zone 4'],
                              ['5', 'CEC Title 24 2008 Zone 5'],
                              ['6', 'CEC Title 24 2008 Zone 6'],
                              ['7', 'CEC Title 24 2008 Zone 7'],
                              ['8', 'CEC Title 24 2008 Zone 8'],
                              ['9', 'CEC Title 24 2008 Zone 9'],
                              ['10', 'CEC Title 24 2008 Zone 10'],
                              ['11', 'CEC Title 24 2008 Zone 11'],
                              ['12', 'CEC Title 24 2008 Zone 12'],
                              ['13', 'CEC Title 24 2008 Zone 13'],
                              ['14', 'CEC Title 24 2008 Zone 14'],
                              ['15', 'CEC Title 24 2008 Zone 15'],
                              ['16', 'CEC Title 24 2008 Zone 16']],
    }
    
  end
  
  def get_building_types
    #reference building types
    @building_types = 
      ['Large Office',
       'Medium Office',
       'Small Office',
       'Warehouse',
      'Stand-Alone Retail',
      'Strip Mall',
      'Primary School',
      'Secondary School',
      'Supermarket',
      'Quick Service Restaurant',
      'Full Service Restaurant',
      'Hospital',
      'Outpatient Health Care',
      'Small Hotel',
      'Large Hotel',
      'Midrise Apartment']
    
  end
end
