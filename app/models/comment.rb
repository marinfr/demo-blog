class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: User.to_s, foreign_key: :user_id
  has_many :reactions, -> { where(resource_type: "comment") }, foreign_key: :resource_id, dependent: :destroy

  validates :content, presence: true, length: { minimum: 2, maximum: 8000 }

  def likes
    reactions.select { |reaction| reaction.type == "like" }
  end

  def smiles
    reactions.select { |reaction| reaction.type == "smile" }
  end

  def hearts
    reactions.select { |reaction| reaction.type == "heart" }
  end
end
