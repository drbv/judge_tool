class Admin::UtilitiesController < Admin::BaseController
  require 'uri'
  require 'net/http'
  def index
    load_variables
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

  def set_ews1_endpoint
    Rails.cache.write :ews1_ip, params[:ip]
    Rails.cache.write :ews1_password, params[:password]
    Rails.cache.write :ews1_tournamentnr, params[:tournamentnr]
    if !params[:use_auto_upload].nil?
      $ews1_use_auto_upload = true
      Rails.cache.write :ews1_use_auto_upload, true
    else
      $ews1_use_auto_upload = false
      Rails.cache.write :ews1_use_auto_upload, false
    end
    check_ews1_endpoint

  end

  def reset_ews1_config_file
    Rails.cache.write :ews1_use_auto_upload, true
    Rails.cache.write :ews1_ip, "0.0.0.0"
    Rails.cache.write :ews1_password, "passwort"
    Rails.cache.write :ews1_tournamentnr, "123456"
    return true
  end

  def check_ews1_endpoint
    load_variables
    if $ews1_use_auto_upload
      uri = URI("http://#{$ews1_ip}:8080/T#{$ews1_tournamentnr}_TDaten.mdb")
      req = Net::HTTP::Get.new(uri)
      req.basic_auth 'ews2', $ews1_password
      begin
      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(req)
      }
      if res.response.kind_of? Net::HTTPSuccess
        flash[:success]=" Verbindung zum TLP/EWS1 vorhanden"
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

  def load_variables
    $ews1_ip = Rails.cache.read(:ews1_ip) || "0.0.0.0"
    $ews1_password = Rails.cache.read(:ews1_password) || "secret"
    $ews1_tournamentnr = Rails.cache.read(:ews1_tournamentnr) || "12345"

    if Rails.cache.read(:ews1_use_auto_upload).nil?
      $ews1_use_auto_upload = true
    else
      $ews1_use_auto_upload =  Rails.cache.read(:ews1_use_auto_upload)
    end
  end

  def create_and_send_debug_file
    load_variables
    export_file_name=$ews1_tournamentnr+"_"+Time.now.strftime("%Y_%m_%d-%H_%M")+"_export.zip"
    create_debug_file=system("zip -r #{export_file_name} tmp/*.mdb tmp/files/ db/judge_tool.sqlite3 log")
    send_file Rails.root.join(Rails.root.join(export_file_name))
  end
end
