class Input
  include Mongoid::Document
  
  field :climate_zone,   :type => String
  field :building_type,  :type => String
  field :address,        :type => String
  field :north_axis,     :type => Float
  
  field :wwr_north,      :type =>  Float
  field :wwr_south,      :type =>  Float
  field :wwr_east,       :type =>  Float
  field :wwr_west,       :type =>  Float
  
  field :height_north,   :type =>  Float
  field :height_south,   :type =>  Float
  field :height_east,    :type =>  Float
  field :height_west,    :type =>  Float
  
  field :wall_u_factor,  :type =>  Float
  field :attic_u_factor, :type =>  Float
  
  field :lighting_power_density,  :type =>  Float
  #field :exterior_lighting_power,  :type =>  Float
  field :user_id,      :type => Integer
  
  field :created_at, :type=> Time
  
  
  def convert(attribute, from, to)
    if from == 'ft' and to == 'm'      
      factor = 0.3048   
    elsif from == 'ft2' and to == 'm2'
      factor = 0.0929      
    elsif from == 'W/ft2' and to == 'W/m2'
      factor = 10.76      
    elsif from == 'u-IP' and to == 'u-SI'
      factor = 5.678
    end
    
    self[attribute] = self[attribute] * factor
  end
  
  
end
