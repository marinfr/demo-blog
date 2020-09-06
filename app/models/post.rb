class Post < ApplicationRecord
  has_many :comments
  belongs_to :author, class_name: User.to_s, foreign_key: :user_id

  validates :title,   presence: true, length: { minimum: 2, maximum: 255 }
  validates :content, presence: true, length: { minimum: 2, maximum: 8000 }
end
