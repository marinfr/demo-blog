require 'rails_helper'

describe "Fetching a single comment", type: :request do
  it "returns a complete comment" do
    user     = FactoryBot.create :user
    user2    = FactoryBot.create :user
    post     = FactoryBot.create :post, author: user
    comment  = FactoryBot.create :comment, author: user2, post: post
    reaction = FactoryBot.create :reaction, user: user, resource: comment, type: Reaction::HEART

    sign_in user

    post "/graphql", params: { query: query(comment.id) }
    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      comment: {
        id:        comment.id.to_s,
        content:   comment.content,
        createdAt: comment.created_at.iso8601,
        updatedAt: comment.updated_at.iso8601,
        author:    { email: user2.email },
        reactions: [{
          type: Reaction::HEART,
          user: { email: user.email }
        }]
      }
    })
  end

  def query(id)
    <<~GRAPHQL
      query Comment {
        comment(id: #{id}) {
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
    GRAPHQL
  end
end
