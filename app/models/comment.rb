class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: User.to_s, foreign_key: :user_id
  has_many :reactions, -> { where(resource_type: Reaction::COMMENT) }, foreign_key: :resource_id, dependent: :destroy

  validates :content, presence: true, length: { minimum: 2, maximum: 8000 }

  def likes
    reactions.select { |reaction| reaction.like? }
  end

  def smiles
    reactions.select { |reaction| reaction.smile? }
  end

  def hearts
    reactions.select { |reaction| reaction.heart? }
  end
end
