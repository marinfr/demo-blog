FactoryBot.define do
  factory :user, aliases: [:author] do
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
    transient do
      resource { nil }
    end

    user
    resource_type { resource.class.name.downcase }
    resource_id { resource.id }
  end
end