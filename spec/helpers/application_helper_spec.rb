require 'rails_helper'

describe ApplicationHelper do
  describe "#can_manage_resource?" do
    it "returns whether a user can manage a certain resource" do
      user1   = FactoryBot.create :user
      user2   = FactoryBot.create :user
      post    = FactoryBot.create :post, author: user1
      comment = FactoryBot.create :comment, author: user2, post: post

      allow(helper).to receive(:current_user).and_return user1

      expect(helper.can_manage_resource?(post)).to eq true
      expect(helper.can_manage_resource?(comment)).to eq false
    end
  end

  describe "#normalize_content" do
    it "trims a string, removes duplicate newlines and <br> tags" do
      expect(helper.normalize_content(
        "     text\r\n\r\n\r\n\r\n<br><br><br>\r\n\r\ntext     "
      )).to eq "text\r\n\r\n<br>\r\ntext"
    end
  end

  describe "#reaction_class" do
    it "returns whether a reaction is active (selected)" do
      user = FactoryBot.create :user
      post = FactoryBot.create :post, author: user
      FactoryBot.create :reaction, user: user, resource: post, type: Reaction::LIKE

      allow(helper).to receive(:current_user).and_return user

      expect(helper.reaction_class(post.likes)).to eq "active"
      expect(helper.reaction_class(post.hearts)).to eq ""
    end
  end

  describe "#who_reacted" do
    it "compiles a list of users who used a specific type of reaction" do
      user = FactoryBot.create :user
      post = FactoryBot.create :post, author: user

      2.times do
        user = FactoryBot.create :user
        FactoryBot.create :reaction, user: user, resource: post, type: Reaction::LIKE
      end

      7.times do
        user = FactoryBot.create :user
        FactoryBot.create :reaction, user: user, resource: post, type: Reaction::SMILE
      end

      expect(helper.who_reacted(post.likes)).to  eq User.all[1..2].pluck(:email).join("<br>")
      expect(helper.who_reacted(post.smiles)).to eq User.all[3..7].pluck(:email).join("<br>") + "<br>and #{User.all[8..-1].size} more"
      expect(helper.who_reacted(post.hearts)).to eq ""
    end
  end
end
