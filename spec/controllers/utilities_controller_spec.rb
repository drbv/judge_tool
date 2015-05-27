require 'rails_helper'

RSpec.describe UtilitiesController, type: :controller do

  describe "GET #rating_download" do
    it "returns http success" do
      get :rating_download
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #db_upload" do
    it "returns http success" do
      get :db_upload
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #db_reset" do
    it "returns http success" do
      get :db_reset
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
