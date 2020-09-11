require 'rails_helper'

describe "Deleting a post", type: :request do
  let!(:user)     { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user }

  before { sign_in user }

  it "deletes for current_user, returns old post" do
    expect {
      post "/graphql", params: { query: query(id: blogpost.id) }
    }.to change { Post.count }.by(-1)

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      deletePost: {
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

  it "does not delete if current_user post does not exist, returns an error" do
    post "/graphql", params: { query: query(id: blogpost.id + 1) }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { deletePost: nil },
      errors: [{
        message:   "Couldn't find Post with 'id'=#{blogpost.id + 1} [WHERE `posts`.`user_id` = ?]",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(id:)
    <<~GRAPHQL
      mutation DeletePost {
        deletePost(input: {id: #{id}}) {
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
        }
      }
    GRAPHQL
  end
end
