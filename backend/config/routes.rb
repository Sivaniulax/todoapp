Rails.application.routes.draw do
  # Devise's own controllers are skipped: Api::V1::AuthController answers in
  # JSON instead. This line is still needed for the :user mapping that
  # sign_in, sign_out and current_user rely on.
  devise_for :users, skip: :all

  # Health check used by Render.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"
      post "auth/guest", to: "auth#guest"
      post "auth/upgrade", to: "auth#upgrade"

      resource :me, only: :show, controller: :me

      resources :todos do
        collection do
          delete :clear_completed
          get :trash, action: :trashed
          post :bulk
        end

        member do
          patch :toggle
          patch :trash
          patch :restore
        end
      end

      resources :categories, only: %i[index create update destroy]
      resources :tags, only: %i[index destroy]

      namespace :admin do
        resource :stats, only: :show
        resources :users, only: :index
      end
    end
  end
end
