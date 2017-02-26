class Admin::UtilitiesController < Admin::BaseController
  require 'uri'
  require 'net/http'
  def index
    @ip=$ews1_ip
    @password=$ews1_password
    @tournamentnumber=$ews1_tournamentnr
    @use_auto_upload=$ews1_use_auto_upload
  end

  def db_upload
    uploaded_file = params[:database_file]
    if uploaded_file
      old_file=Dir.glob(Rails.root.join('tmp', '*.mdb')).first
      if old_file.blank? || old_file.split('/').last == uploaded_file.original_filename
        File.open(Rails.root.join('tmp', uploaded_file.original_filename), 'wb') do |file|
          file.write(uploaded_file.read)
        end
        flash[:success]="Datenbank importiert"
      else
        flash[:danger]="Datenbank konnte nicht importiert werden </br> Es existiert eine Datenbank von einem anderen Turnier"
      end
    end
    redirect_to admin_utilities_index_path
  end

  def update_ews1_config_file
    ews1_conf_file = "config/ews1.conf"
    ews1_data = YAML.load_file ews1_conf_file
    ews1_data["ews1_ip"] = $ews1_ip
    ews1_data["ews1_password"] = $ews1_password
    ews1_data["ews1_tournamentnr"] = $ews1_tournamentnr
    ews1_data["ews1_use_auto_upload"] = $ews1_use_auto_upload
    File.open(ews1_conf_file, 'w') { |f| YAML.dump(ews1_data, f) }

  end

  def set_ews1_endpoint
    $ews1_ip = params[:ip]
    $ews1_password = params[:password]
    # check if there is an Tournament already
    $ews1_tournamentnr = params[:tournamentnr]

    if !params[:use_auto_upload].nil?
      $ews1_use_auto_upload = true
    else
      $ews1_use_auto_upload = false
    end
    update_ews1_config_file
    check_ews1_endpoint
  end

  def reset_ews1_config_file
    $ews1_ip = "0.0.0.0"
    $ews1_password = "supersecret"
    # check if there is an Tournament already
    $ews1_tournamentnr = "1234567"
    $ews1_use_auto_upload = true
    update_ews1_config_file
    return true
  end

  def check_ews1_endpoint
    uri = URI("http://#{$ews1_ip}:8080/T#{$ews1_tournamentnr}_TDaten.mdb")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth 'ews2', $ews1_password
    begin
    res = Net::HTTP.start(uri.hostname, uri.port) {|http|
      http.request(req)
    }
    if res.response.kind_of? Net::HTTPSuccess
      flash[:success]=" Verbindugn zum ews1 vorhanden"
    elsif res.response.kind_of? Net::HTTPUnauthorized
      flash[:danger]=" Passwort nicht gültig"
    elsif res.response.kind_of? Net::HTTPNotFound
      flash[:warning]=" Turnierdatei konnte nicht gefunden werden"
    elsif res.response.kind_of? Net::HTTPRequestTimeOut
      flash[:danger]=" Verbindungs Timeout"
    else
      flash[:danger]=" Verbindung nicht möglich. Einstellungen / Verbindung prüfen"
    end
    rescue
      flash[:danger]=" Verbindung nicht möglich"
    end
    redirect_to admin_utilities_index_path
  end

  def judge_tool_reset
    delete_mdb=system('rm tmp/*.mdb')
    drop_table=system("RAILS_ENV=#{Rails.env} rake db:drop")
    migrate_table=system("RAILS_ENV=#{Rails.env} rake db:migrate")
    reset_ews1_config_file
    flash[:success]="
</br> Access Datenbank gelöscht/unlinked: #{delete_mdb}
</br> JudgeTool Datenbank gelöscht: #{drop_table}
</br> JudgeTool Datenbank erstellt: #{migrate_table}
</br> ews1 Daten zurückgesetzt: #{reset_ews1_config_file}
</br> Passwort zurückgesetzt! user:admin pin:1234
</br> <h1>Prozess oder Server neustarten</h1>"

    redirect_to admin_utilities_index_path

  end
end
