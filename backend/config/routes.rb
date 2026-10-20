Rails.application.routes.draw do
  # Health check used by Render.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      post "auth/guest", to: "auth#guest"
      post "auth/upgrade", to: "auth#upgrade"

      resource :me, only: :show, controller: :me

      resources :todos do
        collection { delete :clear_completed }
        member { patch :toggle }
      end

      resources :categories, only: %i[index create update destroy]

      namespace :admin do
        resource :stats, only: :show
        resources :users, only: :index
      end
    end
  end
end
