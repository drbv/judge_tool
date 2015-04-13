# use this controller as parent for each judge only
class Judges::BaseController < ApplicationController
  force_ssl unless Rails.env.development?
end
