require_relative '../import/access_db_importer'
require 'pry'
desc 'importing the standard Access Database into this tool'
task import: :environment do
  MS::AccessDbImporter.new.import
end