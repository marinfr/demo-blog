require 'rails_helper'

describe PostsController do
  let!(:user)     { FactoryBot.create :user }
  let!(:user2)    { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user2 }

  before { sign_in user }

  describe "GET index" do
    it "returns all posts" do
      get :index
      expect(assigns(:posts)).to eq [blogpost]
    end

    it "returns posts for current user only" do
      my_post = FactoryBot.create :post, author: user
      get :index, params: { my_posts: true }
      expect(assigns(:posts)).to eq [my_post]
    end
  end

  describe "GET show" do
    it "returns a posts" do
      get :show, params: { id: blogpost.id }
      expect(assigns(:post)).to          eq blogpost
      expect(assigns(:comment).class).to eq Comment
    end

    it "redirects with alert if post not found" do
      get :show, params: { id: blogpost.id + 1 }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq "This post does not exist."
    end
  end

  describe "GET new" do
    it "returns a form for a new post" do
      get :new
      expect(assigns(:post).class).to eq Post
    end
  end

  describe "POST create" do
    it "creates a post for the current_user with valid params and returns json with 'redirect_url' to the post" do
      expect {
        post :create,
          params: { post: { id: blogpost.id - 1, title: " title ", content: " <mark>content</mark><h1>test</h1><br><br> " } },
          format: :json
      }.to change { Post.count }.by(1)

      new_post = user.posts.last
      expect(new_post.title).to   eq "title"
      expect(new_post.content).to eq "<mark>content</mark>test\r\n<br>"
      expect(new_post.id).not_to  eq(blogpost.id - 1)

      expect(flash[:success]).to           eq "Your post has been published!"
      expect(JSON.parse(response.body)).to eq("redirect_url" => post_path(new_post))
    end

    it "does not create a post with invalid params and returns json with validation errors" do
      expect {
        post :create,
          params: { post: { title: "title", content: "c" } },
          format: :json
      }.not_to change { Post.count }

      expect(response).to have_http_status 400
      expect(JSON.parse(response.body)).to eq("errors" => { "content" => ["is too short (minimum is 2 characters)"] })
    end
  end

  describe "PATCH update" do
    it "updates a post for the current_user with valid params and returns empty json" do
      new_post = FactoryBot.create :post, author: user

      expect {
        patch :update,
          format: :json,
          params: {
            id:   new_post.id,
            post: {
              id:      new_post.id - 1,
              title:   " newtitle ",
              content: " <mark>newcontent</mark><h1>test</h1><br><br> "
            }
          }
      }.to change { new_post.reload.title }

      expect(new_post.title).to   eq "newtitle"
      expect(new_post.content).to eq "<mark>newcontent</mark>test\r\n<br>"
      expect(new_post.id).not_to  eq(new_post.id - 1)

      expect(flash[:success]).to           eq "Your post has been updated!"
      expect(JSON.parse(response.body)).to eq({})
    end

    it "does not update a post for the current_user with invalid params and returns json with validation errors" do
      new_post = FactoryBot.create :post, author: user

      expect {
        patch :update,
          format: :json,
          params: { id: new_post.id, post: { title: "newtitle", content: "c" } }
      }.not_to change { new_post.reload.title }

      expect(response).to have_http_status 400
      expect(JSON.parse(response.body)).to eq("errors" => { "content" => ["is too short (minimum is 2 characters)"] })
    end

    it "does not update a post for the current_user with invalid params and returns json with validation errors" do
      new_post = FactoryBot.create :post, author: user

      expect {
        patch :update,
          format: :json,
          params: { id: new_post.id, post: { title: "newtitle", content: "c" } }
      }.not_to change { new_post.reload.title }

      expect(response).to have_http_status 400
      expect(JSON.parse(response.body)).to eq("errors" => { "content" => ["is too short (minimum is 2 characters)"] })
    end

    it "returns an error if no current_user post found" do
      patch :update,
        format: :json,
        params: { id: blogpost.id, post: { title: "newtitle", content: "content" } }

      expect(response).to have_http_status 400
      expect(JSON.parse(response.body)).to eq("redirect_url" => root_path)
      expect(flash[:alert]).to             eq "This post does not exist."
    end
  end

  describe "DELETE destroy" do
    it "deletes a post for the current_user and redirects with a notice" do
      new_post = FactoryBot.create :post, author: user

      expect {
        delete :destroy, params: { id: new_post.id }
      }.to change { Post.count }

      expect(flash[:notice]).to eq "Your post has been removed."
      expect(response).to redirect_to(root_path)
    end

    it "returns an error if no current_user post found" do
      expect {
        delete :destroy, params: { id: blogpost.id }
      }.not_to change { Post.count }

      expect(flash[:alert]).to eq "This post does not exist."
      expect(response).to redirect_to(root_path)
    end
  end
end
