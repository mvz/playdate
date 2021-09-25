# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "main#index"

  get "/edit" => "main#edit"
  post "/edit" => "main#update"
  get "/more" => "range#new"
  post "/more" => "range#create"

  get "/login" => "session#new"
  post "/login" => "session#create"
  get "/logout" => "session#edit"
  post "/logout" => "session#destroy"

  get "/feed" => "main#feed", :format => false, :defaults => {format: "xml"}

  get "/login/edit" => "login#edit"
  post "/login/edit" => "login#update"

  resources :playdates, only: [:index, :show, :new, :create, :destroy] do
    collection do
      post :prune
    end
    resources :availabilities, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :players, only: [:index, :new, :create, :edit, :update, :destroy]
end
