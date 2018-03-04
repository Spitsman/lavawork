class ResidentsController < BaseController

  helper_method :resident_facade

  def update
    if resident_facade.resident.update_attributes(resident_params)
      flash[:success] = 'Резидент обновлен'
      redirect_to residents_path
    else
      render action: :edit
    end
  end

  def destroy
    resident_facade.resident.destroy
    redirect_to residents_path
  end

  protected

  def resident_params
    params.fetch(:resident, {}).permit!
  end

  def resident_facade
    @resident_facade ||= ResidentFacade.new(params[:id] ? User.find(params[:id]) : nil)
  end

end
