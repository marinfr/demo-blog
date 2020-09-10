require 'rails_helper'

describe Users::RegistrationsController do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "POST create" do
    it "creates a user with valid credentials and returns json with redirect_url" do
      post :create, params: { user: { email: "user@mail.com", password: "123456" } }

      expect(JSON.parse(response.body)).to eq("redirect_url" => root_path)
      expect(User.last.email).to eq "user@mail.com"
    end

    it "doesn't create a user and returns json with errors if invalid params sent" do
      post :create, params: { user: { email: "user", password: "12345" } }

      expect(JSON.parse(response.body)).to eq(
        "errors" => {
          "email"    => ["is invalid"],
          "password" => ["is too short (minimum is 6 characters)"]
        }
      )
      expect(User.count).to eq 0
    end
  end
end
