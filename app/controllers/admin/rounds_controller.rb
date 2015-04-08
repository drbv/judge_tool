class Admin::RoundsController < Admin::BaseController
  def index
    authorize Round, :admin_index?
  end
end
