require 'rails_helper'

describe "Reacting to a post", type: :request do
  let!(:user)     { FactoryBot.create :user }
  let!(:blogpost) { FactoryBot.create :post, author: user }

  before { sign_in user }

  it "creates a reaction for current_user with valid params" do
    expect {
      post "/graphql", params: { query: query(post_id: blogpost.id, type: Reaction::LIKE) }
    }.to change { blogpost.reactions.reload.size }.by(1)

    reaction = Reaction.last

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      reactToPost: {
        errors:   [],
        reaction: {
          type: Reaction::LIKE,
          user: { email: user.email }
        }
      }
    })
  end

  it "returns a reaction for current_user if it already exists" do
    reaction = FactoryBot.create :reaction, user: user, resource: blogpost, type: Reaction::LIKE

    expect {
      post "/graphql", params: { query: query(post_id: blogpost.id, type: Reaction::LIKE) }
    }.not_to change { blogpost.reactions.reload.size }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      reactToPost: {
        errors:   [],
        reaction: {
          type: reaction.type,
          user: { email: reaction.user.email }
        }
      }
    })
  end

  it "removes previous reactions for current_user" do
    reaction = FactoryBot.create :reaction, user: user, resource: blogpost, type: Reaction::LIKE

    expect {
      post "/graphql", params: { query: query(post_id: blogpost.id, type: Reaction::HEART) }
    }.to change { Reaction.exists?(id: reaction.id) }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      reactToPost: {
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
      post "/graphql", params: { query: query(post_id: blogpost.id, type: "") }
    }.not_to change { blogpost.reactions.reload.size }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      reactToPost: {
        errors:   ["Type can't be blank", "Type has to be either 'like', 'smile' or 'heart'"],
        reaction: nil
      }
    })
  end

  it "does not create a reaction to a post that does not exist" do
    post "/graphql", params: { query: query(post_id: blogpost.id + 1, type: Reaction::LIKE) }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { reactToPost: nil },
      errors: [{
        message:   "Couldn't find Post with 'id'=#{blogpost.id + 1}",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(post_id:, type:)
    <<~GRAPHQL
      mutation ReactToPost {
        reactToPost(input: {postId: #{post_id}, type: "#{type}"}) {
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
