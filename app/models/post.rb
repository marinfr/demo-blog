class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :reactions, -> { where(resource_type: "post") }, foreign_key: :resource_id, dependent: :destroy
  belongs_to :author, class_name: User.to_s, foreign_key: :user_id

  validates :title,   presence: true, length: { minimum: 2, maximum: 255 }
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
