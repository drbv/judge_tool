require "#{Rails.root}/lib/import/access_db_importer"

class Admin::BaseController < ApplicationController
  force_ssl unless Rails.env.development?

  @@access_database = nil

  def self.access_database
    @@access_database ||= MS::AccessDbImporter.new
  end

  def access_database
    Admin::BaseController.access_database
  end
end
