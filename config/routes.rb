Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions:      "users/sessions"
  }

  authenticate :user do
    if Rails.env.development?
      mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
      post "/graphql", to: "graphql#execute"
    end

    root to: "posts#index"

    get "/my_posts", to: "posts#index", my_posts: true

    resources :posts, except: [:edit] do
      resources :comments,  only: [:create, :update, :destroy]
    end

    resources :reactions, only: [:create]
  end
end
