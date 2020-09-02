Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    resources :posts
    root to: "posts#index"
  end
end
