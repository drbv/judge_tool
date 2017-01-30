class Admin::UsersController < Admin::BaseController
  def index
    authorize User
    @users = User.all
    @dance_teams = DanceTeam.all
  end

  def create
    authorize User
    begin
    access_database.import_persons!
    rescue Exception=>e
      flash[:danger]="#{e}"

    end
    redirect_to admin_users_path
  end

  end
