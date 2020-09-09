FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "user#{n}@mail.com"
    end
    password { "123456" }
  end

  factory :post do
    sequence :title do |n|
      "Post #{n} title"
    end
    sequence :content do |n|
      "Post #{n} content"
    end
    author
  end

  factory :comment do
    sequence :content do |n|
      "Comment #{n} content"
    end
    author
    post
  end

  factory :reaction do
    user
    resource_type
    resource_id
  end
end