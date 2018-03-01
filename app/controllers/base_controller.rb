class BaseController < ApplicationController

  before_action do
    redirect_to my_path unless current_user.admin?
  end

end
