class My::BaseController < ApplicationController
  before_action do
    redirect_to root_path unless current_user.resident?
  end
end
