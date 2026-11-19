Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "calculations#new"
  post "calculate", to: "calculations#create"

  namespace :api do
    namespace :v1 do
      post "inflated_prices", to: "inflated_prices#create"
      get "areas", to: "areas#index"
    end
  end
end
