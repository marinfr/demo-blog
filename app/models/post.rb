class Post < ApplicationRecord
  belongs_to :author, class_name: User.to_s, foreign_key: :user_id
  has_many :comments, dependent: :destroy
  has_many :reactions, -> { where(resource_type: Reaction::POST) }, foreign_key: :resource_id, dependent: :delete_all

  validates :title,   presence: true, length: { minimum: 2, maximum: 255 }
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
