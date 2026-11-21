# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :players
  root to: "main#index"

  get "/edit" => "main#edit"
  post "/edit" => "main#update"
  get "/more" => "range#new"
  post "/more" => "range#create"

  get "/feed" => "main#feed", :format => false, :defaults => { format: "xml" }

  resource :credentials, only: [:edit, :update]

  resources :playdates, only: [:index, :show, :new, :create, :destroy] do
    collection do
      post :prune
    end
    resources :availabilities, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :players, only: [:index, :new, :create, :edit, :update, :destroy]
end
