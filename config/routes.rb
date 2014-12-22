Rails.application.routes.draw do
  root to: 'main#index'

  get '/edit' => 'main#edit'
  post '/edit' => 'main#edit'
  get '/more' => 'main#more'
  post '/more' => 'main#more'

  get '/login' => 'login#login'
  post '/login' => 'login#login'
  get '/logout' => 'login#logout'
  post '/logout' => 'login#logout'

  get '/feed' => 'main#feed', :format => false, :defaults => { format: 'xml' }

  id_requirement     = /\d+/
  action_requirement = /[A-Za-z]\S*/

  get '/login/edit' => 'login#edit'
  post '/login/edit' => 'login#edit'

  resources :playdates, only: [:index, :show, :new, :create, :destroy] do
    collection do
      post :prune
    end
    resources :availabilities, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :players, only: [:index, :new, :create, :edit, :update, :destroy]
end
