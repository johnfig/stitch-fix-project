Rails.application.routes.draw do
  root to: "clearance_batches#index"
  resources :clearance_batches, only: [:index, :show, :create]
  resources :items, only: [:index]
end
