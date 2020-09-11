require 'rails_helper'

describe "Creating a comment", type: :request do
  let!(:user)     { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user }
  let!(:comment)  { FactoryBot.create :comment, author: user, post: blogpost }

  before { sign_in user }

  it "updates for current_user with valid params" do
    expect {
      post "/graphql", params: { query: query(id: comment.id, content: " newtest<br> ") }
    }.to change { comment.reload.content }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      updateComment: {
        errors:  [],
        comment: {
          id:        comment.id.to_s,
          content:   "newtest",
          createdAt: comment.created_at.iso8601,
          updatedAt: comment.updated_at.iso8601,
          author:    { email: user.email },
          reactions: []
        }
      }
    })
  end

  it "does not update for current_user with invalid params, returns the comment with old params" do
    expect {
      post "/graphql", params: { query: query(id: comment.id, content: "") }
    }.not_to change { comment.reload.content }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      updateComment: {
        errors:  ["Content can't be blank", "Content is too short (minimum is 2 characters)"],
        comment: {
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

  it "does not update if no changes" do
    expect {
      post "/graphql", params: { query: query(id: comment.id, content: comment.content) }
    }.not_to change { comment.reload.updated_at }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      updateComment: {
        errors:  [],
        comment: {
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

  it "does not update a comment that does not exist for current_user, returns errors" do
    post "/graphql", params: { query: query(id: comment.id + 1, content: "content") }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { updateComment: nil },
      errors: [{
        message:   "Couldn't find Comment with 'id'=#{comment.id + 1} [WHERE `comments`.`user_id` = ?]",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(id:, content:)
    <<~GRAPHQL
      mutation UpdateComment {
        updateComment(input: {id: #{id}, content: "#{content}"}) {
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
          errors
        }
      }
    GRAPHQL
  end
end
