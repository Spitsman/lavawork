class ResidentsController < ApplicationController

  helper_method :resource_resident, :residents_collection, :decorated_resident, :sent_transactions_collection, :received_transactions_collection

  def index
  end

  def new
  end

  def create
    if resource_resident.save
      flash[:success] = 'Resident created'
      redirect_to residents_path
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if resource_resident.update_attributes(resident_params)
      flash[:success] = 'Resident updated'
      redirect_to residents_path
    else
      render action: :edit
    end
  end

  def destroy
    resource_resident.destroy
    redirect_to residents_path
  end

  protected

  def residents_collection
    @residents_collection ||= Resident.order(:id).decorate
  end

  def resource_resident
    @resource_resident ||= params[:id].present? ? Resident.find(params[:id]) : Resident.new(resident_params)
  end

  def resident_params
    params.fetch(:resident, {}).permit!
  end

  def decorated_resident
    @decorated_resident ||= resource_resident.decorate
  end

  def sent_transactions_collection
    @sent_transactions_collection ||= resource_resident.sent_transactions.ordered.limit(10).decorate
  end

  def received_transactions_collection
    @received_transactions_collection ||= resource_resident.received_transactions.ordered.limit(10).decorate
  end

end
