require 'rails_helper'

describe "Deleting a comment", type: :request do
  let!(:user)     { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user }
  let!(:comment)  { FactoryBot.create :comment, author: user, post: blogpost }

  before { sign_in user }

  it "deletes for current_user, returns old comment" do
    expect {
      post "/graphql", params: { query: query(id: comment.id) }
    }.to change { Comment.count }.by(-1)

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      deleteComment: {
        comment:   {
          id:        comment.id.to_s,
          content:   comment.content,
          createdAt: comment.created_at.iso8601,
          updatedAt: comment.updated_at.iso8601,
          author:    { email: user.email },
          reactions: []
        }
      }
    })
  end

  it "does not delete if current_user comment does not exist, returns an error" do
    post "/graphql", params: { query: query(id: comment.id + 1) }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { deleteComment: nil },
      errors: [{
        message:   "Couldn't find Comment with 'id'=#{comment.id + 1} [WHERE `comments`.`user_id` = ?]",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(id:)
    <<~GRAPHQL
      mutation DeleteComment {
        deleteComment(input: {id: #{id}}) {
          comment {
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
