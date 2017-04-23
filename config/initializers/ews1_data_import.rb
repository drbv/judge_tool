$ews1_ip = Rails.cache.read(:ews1_ip) || "0.0.0.0"
$ews1_password = Rails.cache.read(:ews1_password) || "secret"
$ews1_tournamentnr = Rails.cache.read(:ews1_tournamentnr) || "12345"
$ews1_use_auto_upload = Rails.cache.read(:ews1_use_auto_upload) || true
