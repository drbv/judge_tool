class Admin::UsersController < Admin::BaseController
  def index
    authorize User
    @users = User.all
    @dance_teams = DanceTeam.all
  end

  def create
    authorize User
    if update_database
      access_database.import_persons!
    end
    redirect_to admin_users_path
  end

  def update_database
    begin
      access_database.download_database
      return true
    rescue => ex
      flash[:danger]="Fehler beim importieren <br>Error: #{ex.message}"
      return false
    end
  end

  end
