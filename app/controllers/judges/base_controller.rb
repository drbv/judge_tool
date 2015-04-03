# use this controller as parent for each judge only
class Judges::BaseController < ApplicationController
  http_basic_authenticate_with :name => 'judge', :password => 'dr34D'
  force_ssl unless Rails.env.development?
end
