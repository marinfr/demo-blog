require 'rails_helper'

describe Users::SessionsController do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "POST create" do
    it "creates a session with correct credentials" do
      user = FactoryBot.create :user

      post :create, params: { user: { email: user.email, password: "123456" } }
      expect(response).not_to have_http_status 400
      expect(subject.current_user).to eq user
    end

    it "doesn't create a session and returns json with errors if invalid credentials sent" do
      post :create, params: { user: { email: "wrong", password: "wrong" } }
      expect(response).to have_http_status 400

      expect(JSON.parse(response.body)).to eq(
        "errors" => {
          "password" => ["wrong email or password"]
        }
      )
    end
  end
end
