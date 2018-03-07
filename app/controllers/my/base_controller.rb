class My::BaseController < ApplicationController
  before_action do
    redirect_to root_path unless current_user.resident?
  end

  helper_method :resident_facade

  protected

  def resident_facade
    @resident_facade ||= ResidentFacade.new(current_user)
  end

end
