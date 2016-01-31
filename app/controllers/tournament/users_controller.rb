class Tournament::UsersController < Tournament::BaseController
  def index
    authorize User
    @users = User.all
    @dance_teams = DanceTeam.all
  end

  def create
    authorize User
    access_database.import_persons!
    redirect_to tournament_users_path
  end

  end
