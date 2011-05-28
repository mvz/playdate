PlayDate::Application.routes.draw do |map|
  map.root :controller => "main"

  map.connect 'edit', :controller => "main", :action => 'edit'
  map.connect 'more', :controller => "main", :action => 'more'

  map.connect 'login', :controller => "login", :action => 'login'
  map.connect 'logout', :controller => "login", :action => 'logout'

  map.connect 'feed', :controller => "main", :action => 'feed'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  id_requirement     = /\d+/
  action_requirement = /[A-Za-z]\S*/

  map.connect 'login/:action', :controller => "login",
    :action => 'login', :requirements => { :action => action_requirement }

  # Availabilities are only admin'ed through a specific playdate.
  map.connect 'playdates/:playdate_id/availabilities/:action',
    :controller => 'availabilities', :action => 'list',
    :requirements => { :playdate_id => id_requirement, :action => action_requirement }
  map.connect 'playdates/:playdate_id/availabilities/:availability_id/:action',
    :controller => 'availabilities', :action => 'show',
    :requirements => { :playdate_id => id_requirement, :availability_id => id_requirement, :action => action_requirement }

  map.connect 'playdates/:action', :controller => "playdates",
    :action => 'list', :requirements => { :action => action_requirement }
  map.connect 'playdates/:id/:action', :controller => "playdates", :action => 'show',
    :requirements => { :id => id_requirement, :action => action_requirement }

  map.resources :players
  map.connect 'players/:action', :controller => "players", :action => 'list',
    :requirements => { :action => action_requirement }
  map.connect 'players/:id/:action', :controller => "players", :action => 'show',
    :requirements => { :id => id_requirement, :action => action_requirement }
end
