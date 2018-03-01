class UserSessionsController < ApplicationController

  layout 'auth'

  skip_filter :require_user, except: [:destroy]
  before_action :format_phone, only: :create

  helper_method :resource_session

  def new
  end

  def create
    if resource_session.save
      flash[:notice] = 'Вы вошли'
      redirect_to current_user.admin? ? root_url : my_path
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to sign_in_url
  end

protected

  def format_phone
    return if User.find_by(phone: params[:user_session][:phone]).present?

    current_phone = params[:user_session][:phone].gsub(/\D/, '')
    current_phone[0] = '' if current_phone[0].in?(['7', '8'])
    current_phone[0,2] = '' if current_phone[0,2] == '+7'

    ['+7', '7', '8', ''].each do |prefix|
      phone = prefix + current_phone
      if User.find_by(phone: phone).present?
        params[:user_session][:phone] = phone
        break
      end
    end
  end

  def resource_session
    @resource_session ||= UserSession.new(user_session_params)
  end

  def user_session_params
    params.fetch(:user_session, {}).permit(:phone, :password, :remember_me)
  end

end
