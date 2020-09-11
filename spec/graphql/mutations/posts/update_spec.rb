require 'rails_helper'

describe "Updating a post", type: :request do
  let!(:user)     { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user }

  before { sign_in user }

  it "updates for current_user with valid params" do
    expect {
      post "/graphql", params: { query: query(id: blogpost.id, title: " newtitle ", content: " <mark>newcontent</mark><h1>test</h1><br><br> ") }
    }.to change { blogpost.reload.title }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      updatePost: {
        errors: [],
        post:   {
          id:        blogpost.id.to_s,
          title:     "newtitle",
          content:   "<mark>newcontent</mark>test\r\n<br>",
          createdAt: blogpost.created_at.iso8601,
          updatedAt: blogpost.updated_at.iso8601,
          author:    { email: user.email },
          reactions: [],
          comments:  []
        }
      }
    })
  end

  it "does not update if no changes" do
    expect {
      post "/graphql", params: { query: query(id: blogpost.id, title: blogpost.title, content: blogpost.content) }
    }.not_to change { blogpost.reload.updated_at }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      updatePost: {
        errors: [],
        post:   {
          id:        blogpost.id.to_s,
          title:     blogpost.title,
          content:   blogpost.content,
          createdAt: blogpost.created_at.iso8601,
          updatedAt: blogpost.updated_at.iso8601,
          author:    { email: user.email },
          reactions: [],
          comments:  []
        }
      }
    })
  end

  it "does not update for current_user with invalid params, returns the post with old params" do
    expect {
      post "/graphql", params: { query: query(id: blogpost.id, title: "title", content: "") }
    }.not_to change { blogpost.reload.content }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      updatePost: {
        errors: ["Content can't be blank", "Content is too short (minimum is 2 characters)"],
        post:   {
          id:        blogpost.id.to_s,
          title:     blogpost.title,
          content:   blogpost.content,
          createdAt: blogpost.created_at.iso8601,
          updatedAt: blogpost.updated_at.iso8601,
          author:    { email: user.email },
          reactions: [],
          comments:  []
        }
      }
    })
  end

  it "does not update if current_user post does not exist, returns an error" do
    post "/graphql", params: { query: query(id: blogpost.id + 1, title: "title", content: "content") }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { updatePost: nil },
      errors: [{
        message:   "Couldn't find Post with 'id'=#{blogpost.id + 1} [WHERE `posts`.`user_id` = ?]",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(id:, title:, content:)
    <<~GRAPHQL
      mutation UpdatePost {
        updatePost(input: {id: #{id}, title: "#{title}", content: "#{content}"}) {
          post {
            id
            title
            content
            createdAt
            updatedAt
            author {
              email
            }
            reactions {
              type
              user {
                email
              }
            }
            comments {
              id
              content
              createdAt
              updatedAt
              author {
                email
              }
              reactions {
                type
                user {
                  email
                }
              }
            }
          }
          errors
        }
      }
    GRAPHQL
  end
end
