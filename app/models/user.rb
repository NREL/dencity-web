class User
  include Mongoid::Document
  field :username, :type => String
  field :email, :type => String
  field :api_key, :type => String
  
  # Indexes

  # Relationships
  references_many :edifices
  
  #has_many :edifices
  
  # Class Methods
  def generate_api_key!
    self.update_attribute(:api_key, secure_digest(Time.now, (1..10).map{ rand.to_s }))
  end
  
  def self.authenticate(api_key)
    user = nil
    user = User.where("api_key" => api_key).first
    if user.nil?
      logger.info("Invalid API Key: does not match any registered users")
    else
      logger.info("API Key belongs to USER: #{user.username}")
    end
    return user    
  end
  
  protected
 
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))
    end
 

end
