require 'rails_helper'

describe Comment do
  context "Validations" do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(2).is_at_most(8000) }
  end

  context "Comment reactions" do
    it "returns all reactions by type" do
      user    = FactoryBot.create :user
      user2   = FactoryBot.create :user
      user3   = FactoryBot.create :user
      post    = FactoryBot.create :post, author: user
      comment = FactoryBot.create :comment, author: user, post: post

      like  = FactoryBot.create :reaction, user: user,  resource: comment, type: Reaction::LIKE
      smile = FactoryBot.create :reaction, user: user2, resource: comment, type: Reaction::SMILE
      heart = FactoryBot.create :reaction, user: user3, resource: comment, type: Reaction::HEART

      expect(comment.likes).to  eq [like]
      expect(comment.smiles).to eq [smile]
      expect(comment.hearts).to eq [heart]
    end
  end
end
