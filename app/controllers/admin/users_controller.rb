class Admin::UsersController < Admin::BaseController
  def index
    @users = User.all
  end

  def create
    access_database.import_persons
    redirect_to admin_users_path
  end
end
