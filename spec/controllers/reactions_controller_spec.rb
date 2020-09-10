require 'rails_helper'

describe ReactionsController do
  let!(:user)     { FactoryBot.create :user }
  let!(:user2)    { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user2 }
  let!(:reaction) { FactoryBot.create :reaction, user: user2, resource: blogpost, type: Reaction::HEART }

  before { sign_in user }

  describe "POST create" do
    it "creates a reaction to a post and removes the previous one for the same user" do
      FactoryBot.create :reaction, user: user, resource: blogpost, type: Reaction::HEART

      expect(blogpost.reactions.size).to eq 2

      expect {
        post :create,
          params: { resource_id: blogpost.id, resource_type: Reaction::POST, type: Reaction::LIKE },
          format: :json
      }.not_to change { blogpost.reactions.reload.size }

      expect(blogpost.reactions.last.type).to eq Reaction::LIKE
      expect(blogpost.reactions.last.user).to eq user
    end

    it "removes a previously created reaction for the same user" do
      FactoryBot.create :reaction, user: user, resource: blogpost, type: Reaction::HEART

      expect(blogpost.reactions.size).to eq 2

      expect {
        post :create,
          params: { resource_id: blogpost.id, resource_type: Reaction::POST, type: Reaction::HEART },
          format: :json
      }.to change { blogpost.reactions.reload.size }.by(-1)

      expect(blogpost.reactions.last.type).to eq Reaction::HEART
      expect(blogpost.reactions.last.user).to eq user2
    end

    it "raises an error if resource not found" do
      expect {
        post :create,
          params: { resource_id: blogpost.id + 1, resource_type: Reaction::POST, type: Reaction::HEART },
          format: :json
      }.to raise_error { ActiveRecord::RecordNotFound }
    end

    it "exits if invalid resource_type" do
      expect {
        post :create,
          params: { resource_id: user2.id + 1, resource_type: "user", type: Reaction::HEART },
          format: :json
      }.not_to raise_error { ActiveRecord::RecordNotFound }

      expect(response).to have_http_status :bad_request
    end
  end
end
