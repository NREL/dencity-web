class ApiKeysController < ApplicationController
  #devise
  before_filter :authenticate_user!
  #cancan
  before_filter { unauthorized! if cannot? :manage, :apikey }

  def create
    if !params[:user].nil?
      @user = User.find(params[:user])
      @user.reset_authentication_token!
      if !params[:came_from].nil? and params[:came_from] == 'user_edit'
        redirpath = edit_user_path(@user)
      else
        #default path
        redirpath = edit_user_registration_path
      end
      redirect_to(redirpath, :notice => 'API Key was generated.')
    else
      #ERROR
      flash[:error] = "Error: No user was selected"
      redirect_to(root_path)
    end
  end

  def destroy
    if !params[:user].nil?
      @user = User.find(params[:user])
      @user[:authentication_token] = nil
      @user.save
      if !params[:came_from].nil? and params[:came_from] == 'user_edit'
        redirpath = edit_user_path(@user)
      else
        #default path
        redirpath = edit_user_registration_path
      end
      redirect_to(redirpath, :notice => 'API Key was deleted.')
    else
      #ERROR
      flash[:error] = "Error: No user was selected"
      redirect_to(root_path)
    end

  end

end
