require 'rails_helper'

describe Post do
  context "Validations" do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(2).is_at_most(255) }
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(2).is_at_most(8000) }
  end

  context "Post reactions" do
    it "returns all reactions by type" do
      user  = FactoryBot.create :user
      user2 = FactoryBot.create :user
      user3 = FactoryBot.create :user
      post  = FactoryBot.create :post, author: user

      like  = FactoryBot.create :reaction, user: user,  resource: post, type: Reaction::LIKE
      smile = FactoryBot.create :reaction, user: user2, resource: post, type: Reaction::SMILE
      heart = FactoryBot.create :reaction, user: user3, resource: post, type: Reaction::HEART

      expect(post.likes).to  eq [like]
      expect(post.smiles).to eq [smile]
      expect(post.hearts).to eq [heart]
    end
  end
end
