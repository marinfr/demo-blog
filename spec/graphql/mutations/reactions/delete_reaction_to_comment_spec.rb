require 'rails_helper'

describe "Deleting a reaction to a comment", type: :request do
  let!(:user)      { FactoryBot.create :user }
  let!(:user2)     { FactoryBot.create :user }
  let!(:blogpost)  { FactoryBot.create :post, author: user }
  let!(:comment)   { FactoryBot.create :comment, author: user, post: blogpost }
  let!(:reaction)  { FactoryBot.create :reaction, user: user, resource: comment, type: Reaction::LIKE }
  let!(:reaction2) { FactoryBot.create :reaction, user: user2, resource: comment, type: Reaction::HEART }

  before { sign_in user }

  it "removes and returns a reaction" do
    expect {
      post "/graphql", params: { query: query(comment_id: comment.id) }
    }.to change { comment.reactions.reload.size }.by(-1)

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      deleteReactionToComment: {
        reaction: {
          type: reaction.type,
          user: { email: reaction.user.email }
        }
      }
    })
  end

  it "does not return anything if no reactions on post" do
    reaction.destroy!

    post "/graphql", params: { query: query(comment_id: comment.id) }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      deleteReactionToComment: {
        reaction: nil
      }
    })
  end

  it "does not remove a reaction to a post that does not exist" do
    post "/graphql", params: { query: query(comment_id: comment.id + 1) }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { deleteReactionToComment: nil },
      errors: [{
        message:   "Couldn't find Comment with 'id'=#{comment.id + 1}",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(comment_id:)
    <<~GRAPHQL
      mutation DeleteReactionToComment {
        deleteReactionToComment(input: {commentId: #{comment_id}}) {
          reaction {
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
