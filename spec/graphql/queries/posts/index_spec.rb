require 'rails_helper'

describe "Fetching all posts", type: :request do
  it "returns complete posts" do
    user      = FactoryBot.create :user
    user2     = FactoryBot.create :user
    post      = FactoryBot.create :post, author: user
    reaction  = FactoryBot.create :reaction, user: user2, resource: post, type: Reaction::LIKE
    post2     = FactoryBot.create :post, author: user2
    comment   = FactoryBot.create :comment, author: user2, post: post
    reaction2 = FactoryBot.create :reaction, user: user, resource: comment, type: Reaction::HEART

    sign_in user

    post "/graphql", params: { query: query }
    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      posts: [
        {
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
        },
        {
          id:        post2.id.to_s,
          title:     post2.title,
          content:   post2.content,
          createdAt: post2.created_at.iso8601,
          updatedAt: post2.updated_at.iso8601,
          author:    { email: post2.author.email },
          reactions: [],
          comments:  []
        }
      ]
    })
  end

  def query
    <<~GRAPHQL
      query Posts {
        posts {
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
