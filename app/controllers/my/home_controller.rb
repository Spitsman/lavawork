class My::HomeController < My::BaseController

  helper_method :resident_facade

  protected

  def resident_facade
    @resident_facade ||= ResidentFacade.new(current_user)
  end

end
