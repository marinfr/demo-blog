require 'rails_helper'

describe "Deleting a reaction to a post", type: :request do
  let!(:user)      { FactoryBot.create :user }
  let!(:user2)     { FactoryBot.create :user }
  let!(:blogpost)  { FactoryBot.create :post, author: user }
  let!(:reaction)  { FactoryBot.create :reaction, user: user, resource: blogpost, type: Reaction::LIKE }
  let!(:reaction2) { FactoryBot.create :reaction, user: user2, resource: blogpost, type: Reaction::HEART }

  before { sign_in user }

  it "removes and returns a reaction" do
    expect {
      post "/graphql", params: { query: query(post_id: blogpost.id) }
    }.to change { blogpost.reactions.reload.size }.by(-1)

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      deleteReactionToPost: {
        reaction: {
          type: reaction.type,
          user: { email: reaction.user.email }
        }
      }
    })
  end

  it "does not return anything if no reactions on post" do
    reaction.destroy!

    post "/graphql", params: { query: query(post_id: blogpost.id) }

    expect(JSON.parse(response.body, symbolize_names: true)[:data]).to match({
      deleteReactionToPost: {
        reaction: nil
      }
    })
  end

  it "does not remove a reaction to a post that does not exist" do
    post "/graphql", params: { query: query(post_id: blogpost.id + 1) }

    expect(JSON.parse(response.body, symbolize_names: true)).to match({
      data:   { deleteReactionToPost: nil },
      errors: [{
        message:   "Couldn't find Post with 'id'=#{blogpost.id + 1}",
        locations: anything,
        path:      anything
      }]
    })
  end

  def query(post_id:)
    <<~GRAPHQL
      mutation DeleteReactionToPost {
        deleteReactionToPost(input: {postId: #{post_id}}) {
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
