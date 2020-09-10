require 'rails_helper'

describe CommentsController do
  let!(:user)     { FactoryBot.create :user }
  let!(:user2)    { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user }

  before { sign_in user }

  describe "POST create" do
    it "creates a comment for current_user on a post" do
      expect {
        post :create, params: { post_id: blogpost.id, comment: { content: " test<br> " } }, format: :json
      }.to change { blogpost.comments.reload.size }.by(1)

      expect(JSON.parse(response.body)).to eq({})
      expect(Comment.last.author).to       eq user
      expect(Comment.last.content).to      eq "test"
    end

    it "does not create a comment for current_user on a post with invalid params" do
      expect {
        post :create, params: { post_id: blogpost.id, comment: { content: "c" } }, format: :json
      }.not_to change { blogpost.comments.reload.size }

      expect(JSON.parse(response.body)).to eq("errors" => { "content" => ["is too short (minimum is 2 characters)"] })
      expect(response).to have_http_status 400
    end

    it "does not create a comment for current_user on a post that does not exist" do
      post :create, params: { post_id: blogpost.id + 1, comment: { content: "content" } }, format: :json

      expect(JSON.parse(response.body)).to eq("redirect_url" => root_path)
      expect(flash[:alert]).to             eq "This post does not exist."
      expect(response).to have_http_status 400
    end
  end

  describe "PATCH update" do
    it "updates a comment for current_user on a post" do
      comment = FactoryBot.create :comment, author: user, post: blogpost

      expect {
        patch :update, params: { post_id: blogpost.id, id: comment.id, comment: { content: " newtest<br> " } }, format: :json
      }.to change { comment.reload.content }

      expect(JSON.parse(response.body)).to eq({})
      expect(comment.content).to           eq "newtest"
    end

    it "does not update a comment for current_user on a post with invalid params" do
      comment = FactoryBot.create :comment, author: user, post: blogpost

      expect {
        patch :update, params: { post_id: blogpost.id, id: comment.id, comment: { content: "c" } }, format: :json
      }.not_to change { comment.reload.content }

      expect(JSON.parse(response.body)).to eq("errors" => { "content" => ["is too short (minimum is 2 characters)"] })
      expect(response).to have_http_status 400
    end

    it "does not update a comment for current_user on a post that does not exist" do
      patch :update, params: { post_id: blogpost.id + 1, id: 123, comment: { content: "content" } }, format: :json

      expect(JSON.parse(response.body)).to eq("redirect_url" => root_path)
      expect(flash[:alert]).to             eq "This post does not exist."
      expect(response).to have_http_status 400
    end

    it "does not update a comment that does not belong to current_user on a post" do
      comment = FactoryBot.create :comment, post: blogpost, author: user2

      expect {
        patch :update, params: { post_id: blogpost.id, id: comment.id, comment: { content: "new_content" } }, format: :json
      }.not_to change { comment.reload.content }

      expect(JSON.parse(response.body)).to eq({})
      expect(flash[:alert]).to             eq "This comment does not exist."
    end
  end

  describe "DELETE destroy" do
    it "deletes a comment for current_user on a post" do
      comment = FactoryBot.create :comment, author: user, post: blogpost

      expect {
        delete :destroy, params: { post_id: blogpost.id, id: comment.id }
      }.to change { blogpost.comments.reload.size }.by(-1)

      expect(response).to redirect_to(post_path(blogpost))
      expect(flash[:notice]).to            eq "Your comment has been destroyed."
    end

    it "does not delete a comment for current_user on a post that does not exist" do
      delete :destroy, params: { post_id: blogpost.id + 1, id: 123 }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq "This post does not exist."
    end

    it "does not delete a comment that does not belong to current_user on a post" do
      comment = FactoryBot.create :comment, author: user2, post: blogpost

      expect {
        delete :destroy, params: { post_id: blogpost.id, id: comment.id }
      }.not_to change { blogpost.comments.reload.size }

      expect(response).to redirect_to(post_path(blogpost))
      expect(flash[:alert]).to eq "This comment does not exist."
    end
  end
end
