require 'rails_helper'

describe "Fetching a single posts", type: :request do
  it "returns a complete post" do
    user      = FactoryBot.create :user
    user2     = FactoryBot.create :user
    post      = FactoryBot.create :post, author: user
    reaction  = FactoryBot.create :reaction, user: user2, resource: post, type: Reaction::LIKE
    comment   = FactoryBot.create :comment, author: user2, post: post
    reaction2 = FactoryBot.create :reaction, user: user, resource: comment, type: Reaction::HEART

    sign_in user

    post "/graphql", params: { query: query(post.id) }
    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      post: {
        id:        post.id.to_s,
        title:     post.title,
        content:   post.content,
        createdAt: post.created_at.iso8601,
        updatedAt: post.updated_at.iso8601,
        author:    { email: post.author.email },
        reactions: [{
          type: Reaction::LIKE,
          user: { email: user2.email }
        }],
        comments:  [{
          id:        comment.id.to_s,
          content:   comment.content,
          createdAt: comment.created_at.iso8601,
          updatedAt: comment.updated_at.iso8601,
          author:    { email: user2.email },
          reactions: [{
            type: Reaction::HEART,
            user: { email: user.email }
          }]
        }]
      }
    })
  end

  def query(id)
    <<~GRAPHQL
      query Post {
        post(id: #{id}) {
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
    GRAPHQL
  end
end
