require 'rails_helper'

describe "Creating a post", type: :request do
  let!(:user) { FactoryBot.create :user }

  before { sign_in user }

  it "creates for current_user with valid params" do
    expect {
      post "/graphql", params: { query: query(title: " title ", content: " <mark>content</mark><h1>test</h1><br><br> ") }
    }.to change { Post.count }.by(1)

    post = Post.last

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      createPost: {
        errors: [],
        post:   {
          id:        post.id.to_s,
          title:     "title",
          content:   "<mark>content</mark>test\r\n<br>",
          createdAt: post.created_at.iso8601,
          updatedAt: post.updated_at.iso8601,
          author:    { email: user.email },
          reactions: [],
          comments:  []
        }
      }
    })
  end

  it "does not create for current_user with invalid params" do
    expect {
      post "/graphql", params: { query: query(title: "title", content: "") }
    }.not_to change { Post.count }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      createPost: {
        errors: ["Content can't be blank", "Content is too short (minimum is 2 characters)"],
        post:   nil
      }
    })
  end

  def query(title:, content:)
    <<~GRAPHQL
      mutation CreatePost {
        createPost(input: {title: "#{title}", content: "#{content}"}) {
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
