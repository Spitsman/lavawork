class UserSessionsController < ApplicationController

  layout 'auth'

  skip_filter :require_user, except: [:destroy]

  helper_method :resource_session

  def new
  end

  def create
    if resource_session.save
      flash[:notice] = 'Вы вошли'
      redirect_to root_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to sign_in_url
  end

protected

  def resource_session
    @resource_session ||= UserSession.new(user_session_params)
  end

  def user_session_params
    params.fetch(:user_session, {}).permit(:login, :password, :remember_me)
  end

end
