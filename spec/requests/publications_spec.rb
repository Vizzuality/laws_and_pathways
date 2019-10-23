require 'rails_helper'

RSpec.describe "Publications", type: :request do
  describe "GET /publications" do
    it "works! (now write some real specs)" do
      get publications_path
      expect(response).to have_http_status(200)
    end
  end
end
