class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: User.to_s, foreign_key: :user_id

  validates :content, presence: true, length: { minimum: 2, maximum: 8000 }
end
