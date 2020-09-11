require 'rails_helper'

describe "Reacting to a comment", type: :request do
  let!(:user)     { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user }
  let!(:comment)  { FactoryBot.create :comment, author: user, post: blogpost }

  before { sign_in user }

  it "creates a reaction for current_user with valid params" do
    expect {
      post "/graphql", params: { query: query(comment_id: comment.id, type: Reaction::LIKE) }
    }.to change { comment.reactions.reload.size }.by(1)

    reaction = Reaction.last

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      reactToComment: {
        errors:   [],
        reaction: {
          type: Reaction::LIKE,
          user: { email: user.email }
        }
      }
    })
  end

  it "returns a reaction for current_user if it already exists" do
    reaction = FactoryBot.create :reaction, user: user, resource: comment, type: Reaction::LIKE

    expect {
      post "/graphql", params: { query: query(comment_id: comment.id, type: Reaction::LIKE) }
    }.not_to change { comment.reactions.reload.size }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      reactToComment: {
        errors:   [],
        reaction: {
          type: reaction.type,
          user: { email: reaction.user.email }
        }
      }
    })
  end

  it "removes previous reactions for current_user" do
    reaction = FactoryBot.create :reaction, user: user, resource: comment, type: Reaction::LIKE

    expect {
      post "/graphql", params: { query: query(comment_id: comment.id, type: Reaction::HEART) }
    }.to change { Reaction.exists?(id: reaction.id) }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      reactToComment: {
        errors:   [],
        reaction: {
          type: Reaction::HEART,
          user: { email: user.email }
        }
      }
    })
  end

  it "does not create a reaction for current_user with invalid params" do
    expect {
      post "/graphql", params: { query: query(comment_id: comment.id, type: "") }
    }.not_to change { comment.reactions.reload.size }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      reactToComment: {
        errors:   ["Type can't be blank", "Type has to be either 'like', 'smile' or 'heart'"],
        reaction: nil
      }
    })
  end

  it "does not create a reaction to a comment that does not exist" do
    post "/graphql", params: { query: query(comment_id: comment.id + 1, type: Reaction::LIKE) }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { reactToComment: nil },
      errors: [{
        message:   "Couldn't find Comment with 'id'=#{comment.id + 1}",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(comment_id:, type:)
    <<~GRAPHQL
      mutation ReactToComment {
        reactToComment(input: {commentId: #{comment_id}, type: "#{type}"}) {
          reaction {
            type
            user {
              email
            }
          }
          errors
        }
      }
    GRAPHQL
  end
end
