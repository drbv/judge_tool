require "#{Rails.root}/lib/import/access_db_importer"

class Tournament::BaseController < ApplicationController

  @@access_database = nil

  def self.access_database
    @@access_database ||= MS::AccessDbImporter.new
  end

  def access_database
    Tournament::BaseController.access_database
  end
end
