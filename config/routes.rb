PlayDate::Application.routes.draw do
  root :to => "main#index"

  match "/edit" => "main#edit"
  match "/more" => "main#more"

  match "/login" => "login#login"
  match "/logout" => "login#logout"

  match "/feed" => "main#feed"

  id_requirement     = /\d+/
  action_requirement = /[A-Za-z]\S*/

  match '/login/edit' => "login#edit"

  resources :playdates do
    collection do
      get :prune
      post :prune
    end
    resources :availabilities
  end

  resources :players
end
