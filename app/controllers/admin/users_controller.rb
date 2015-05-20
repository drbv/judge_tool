class Admin::UsersController < Admin::BaseController
  def index
    authorize User
    @users = User.all
    @dance_teams = DanceTeam.all
  end

  def create
    authorize User
    access_database.import_persons!
    redirect_to admin_users_path
  end

  def upload
    uploaded_file = params[:database_file]
    if uploaded_file
      old_file=Dir.glob(Rails.root.join('tmp', '*.mdb')).first
      if old_file.blank? || old_file.split('/').last == uploaded_file.original_filename
        File.open(Rails.root.join('tmp', uploaded_file.original_filename), 'wb') do |file|
          file.write(uploaded_file.read)
        end
      else
        fail()
      end
    end
    redirect_to admin_users_path
  end
end
