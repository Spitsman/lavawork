class SettingsController < ApplicationController

  helper_method :resource_settings

  Settings.keys.each do |settings_property|
    define_method settings_property do
      Settings.send("#{settings_property}=", params[:settings][settings_property])

      flash[:notice] = 'Настройки обновлены'
      redirect_to settings_path
    end
  end

  protected

  def resource_settings
    Settings
  end

end
