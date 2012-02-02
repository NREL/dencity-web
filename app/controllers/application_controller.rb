class ApplicationController < ActionController::Base
  protect_from_forgery
=begin  
  before_filter :authorize

  protected

  def authorize
    redirect = true
    @is_api = false
    respond_to do |format|
      format.html do
        @is_api = false
      end
      format.xml do
        @apiuser = User.authenticate(params[:api_key])
        if @apiuser.nil?
          render :xml => { :error => :unauthorized }, :status => :unauthorized 
        else
          @is_api = true
        end
      end
    end
  end
=end
 
end
