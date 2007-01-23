ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog',
  #	:action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "main"
  map.connect 'edit', :controller => "main", :action => 'edit'

  map.connect 'login', :controller => "login", :action => 'login'
  map.connect 'logout', :controller => "login", :action => 'logout'

  map.connect 'feed', :controller => "main", :action => 'feed'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
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

  map.connect 'players/:action', :controller => "players", :action => 'list',
    :requirements => { :action => action_requirement }
  map.connect 'players/:id/:action', :controller => "players", :action => 'show',
    :requirements => { :id => id_requirement, :action => action_requirement }

end
