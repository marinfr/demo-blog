require 'rails_helper'

describe "Creating a comment", type: :request do
  let!(:user) { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user }

  before { sign_in user }

  it "creates a comment to a post for current_user with valid params" do
    expect {
      post "/graphql", params: { query: query(post_id: blogpost.id, content: " test<br> ") }
    }.to change { blogpost.comments.reload.size }.by(1)

    comment = Comment.last

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      createComment: {
        errors:  [],
        comment: {
          id:        comment.id.to_s,
          content:   "test",
          createdAt: comment.created_at.iso8601,
          updatedAt: comment.updated_at.iso8601,
          author:    { email: user.email },
          reactions: []
        }
      }
    })
  end

  it "does not create a comment to a post for current_user with invalid params" do
    expect {
      post "/graphql", params: { query: query(post_id: blogpost.id, content: "") }
    }.not_to change { blogpost.comments.reload.size }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      createComment: {
        errors:  ["Content can't be blank", "Content is too short (minimum is 2 characters)"],
        comment: nil
      }
    })
  end

  it "does not create a comment to a post that does not exist for current_user, returns an error" do
    post "/graphql", params: { query: query(post_id: blogpost.id + 1, content: "content") }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { createComment: nil },
      errors: [{
        message:   "Couldn't find Post with 'id'=#{blogpost.id + 1}",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(post_id:, content:)
    <<~GRAPHQL
      mutation CreateComment {
        createComment(input: {postId: #{post_id}, content: "#{content}"}) {
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
