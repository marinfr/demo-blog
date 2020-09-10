require 'rails_helper'

describe Reaction do
  context "Validations" do
    it { should validate_presence_of(:resource_type) }
    it { should validate_inclusion_of(:resource_type).in_array(Reaction::RESOURCE_TYPES) }
    it { should validate_presence_of(:type) }
    it {
      should validate_inclusion_of(:type)
        .in_array(Reaction::REACTION_TYPES)
        .with_message("has to be either 'like', 'smile' or 'heart'")
    }
  end

  describe "#remove_previous_reaction_for_user" do
    it "removes all reactions of the user to the same resource" do
      user = FactoryBot.create :user
      post = FactoryBot.create :post, author: user
      FactoryBot.create :reaction, user: user, resource: post, type: Reaction::HEART

      expect { post.reactions.create(type: Reaction::LIKE, user: user) }.not_to change { post.reactions.reload.count }
      expect(post.reactions.first.type).to eq Reaction::LIKE
    end
  end

  context "Reaction types" do
    it "returns whether a reaction is of a certain type" do
      user    = FactoryBot.create :user
      post    = FactoryBot.create :post, author: user
      comment = FactoryBot.create :comment, author: user, post: post

      like  = FactoryBot.create :reaction, user: user, resource: post,    type: Reaction::LIKE
      heart = FactoryBot.create :reaction, user: user, resource: comment, type: Reaction::HEART

      expect(like.like?).to   be true
      expect(like.heart?).to  be false
      expect(heart.like?).to  be false
      expect(heart.heart?).to be true
    end
  end
end
