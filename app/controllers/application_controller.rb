class ApplicationController < ActionController::Base
  protect_from_forgery

  #filter_parameter_logging :xmlfile, :password
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

  #devise default overrides
  def after_sign_up_path_for(resource)
    root_path
  end
  def after_sign_in_path_for(resource)
    root_path
  end
end
