class Input
  include Mongoid::Document
  
  field :climate_zone,   :type => String
  field :building_type,  :type => String
  field :north_facade_orientation,  :type => Float
  
  field :wwr_north,  :type =>  Float
  field :wwr_south,  :type =>  Float
  field :wwr_east,  :type =>  Float
  field :wwr_west,  :type =>  Float
  
  field :height_north,  :type =>  Float
  field :height_south,  :type =>  Float
  field :height_east,  :type =>  Float
  field :height_west,  :type =>  Float
  
  field :wall_rvalue,  :type =>  Float
  field :roof_rvalue,  :type =>  Float
  
  field :lighting_power_density,  :type =>  Float
  field :exterior_lighting_power,  :type =>  Float
  field :user_id,      :type => Integer
  
  field :created_at, :type=> Time
  
end
