class User
  include Mongoid::Document
  field :username, :type => String
  field :api_key, :type => String
end
