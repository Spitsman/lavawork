class SettingsController < ApplicationController

  helper_method :resource_settings

  def demurrage
    Settings.update_attribute!('demurrage', params[:settings][:demurrage])
    resource_settings.reload!

    flash[:notice] = 'Настройки обновлены'
    redirect_to settings_path
  end

  def commission
    Settings.update_attribute!('commission', params[:settings][:commission])
    resource_settings.reload!

    flash[:notice] = 'Настройки обновлены'
    redirect_to settings_path
  end

  protected

  def resource_settings
    @resource_settings ||= Settings
  end

end
