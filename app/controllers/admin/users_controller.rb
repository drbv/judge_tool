class Admin::UsersController < Admin::BaseController
  def index
    authorize User
    @users = User.all
    @dance_teams = DanceTeam.all
  end

  def create
    authorize User
    access_database.import_persons
    redirect_to admin_users_path
  end
end
