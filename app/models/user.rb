class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  has_many :posts,     dependent: :destroy
  has_many :comments,  dependent: :destroy
  has_many :reactions, dependent: :destroy
end
