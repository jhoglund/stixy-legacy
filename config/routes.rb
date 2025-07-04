ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Resource routes MUST come first to avoid being caught by catch-all routes  
  map.connect 'resources/:type/:browser.:mime', :controller => "resources", :action => "generate"
  map.connect 'resources/:type/:version/:browser.:mime', :controller => "resources", :action => "generate"
  
  # Custom upload routes for documents and photos (MUST come before resource routes)
  map.connect 'widgets/documents/upload', :controller => "/widgets/document", :action => "upload"
  map.connect 'widgets/documents/after_upload', :controller => "/widgets/document", :action => "after_upload"
  map.connect 'widgets/documents/metadata', :controller => "/widgets/document", :action => "metadata"
  map.connect 'widgets/photos/upload', :controller => "/widgets/photo", :action => "upload"
  map.connect 'widgets/photos/after_upload', :controller => "/widgets/photo", :action => "after_upload"
  map.connect 'widgets/photos/metadata', :controller => "/widgets/photo", :action => "metadata"
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html  
  map.resources :documents, :path_prefix => "/widgets", :controller => "/widgets/document"
  map.resources :photos, :path_prefix => "/widgets", :controller => "/widgets/photo"
  map.resources :avatars, :controller => "setting"
  
  # Since some sites and bots are still refering to this url
  map.connect "signup", :controller => "public", :action => "signup"
  map.connect "beta_signup", :controller => "public", :action => "signup"
  map.connect "public/beta_signup", :controller => "public", :action => "signup"
  map.connect "launch_signup", :controller => "public", :action => "signup"
  map.connect "public/launch_signup", :controller => "public", :action => "signup"
  
  map.board 'board/:id', :controller => "board", :action => "index", :requirements => { :id => /\d+/ }
  map.widget 'board/:id/widget/:widget_id/:flag', :controller => "board", :action => "index", :flag => :view, :requirements => { :id => /\d+/, :widget_id => /\d+/ }
  map.connect 'guest/:id', :controller => "guest", :action => "index", :requirements => { :id => /\d+/ }
  map.connect 'widgets/photo/photo/:id', :controller => "widgets/photo", :action => "photo", :id => /.*/
  map.connect 'dev/:id', :controller => "public", :action => "development"
  map.connect 'api/calendar/address/', :controller => "calendar", :action => "ical_address"
  map.calendar_subscription 'api/calendar/subscription/:privatekey', :controller => "api/calendar/ical", :action => "index"
  map.connect 'api/calendar/ical/:action', :controller => "api/calendar/ical"
  map.calendar 'calendar', :controller => "calendar"
  map.calendar_entry 'calendar/:entry_id', :controller => "calendar", :action => "index", :requirements => { :entry_id => /\d+/ }
  
  # Beta routes
  # if defined? PRIVATE_BETA and PRIVATE_BETA
  #   map.signin "signin", :controller => "public", :action => "signin_beta"
  #   map.forgot_password "forgot_password", :controller => "public", :action => "forgot_password_beta"
  #   map.contact_us "contact_us", :controller => "public", :action => "contact_us_beta"
  #   map.terms_of_service "terms_of_service", :controller => "public", :action => "terms_of_service_beta"
  #   map.privacy_policy "privacy_policy", :controller => "public", :action => "privacy_policy_beta"
  #   map.help "help", :controller => "public", :action => "help_beta"
  #   map.how_stixy_works "how_stixy_works", :controller => "public", :action => "how_stixy_works_beta"
  #   map.this_is_stixy "this_is_stixy", :controller => "public", :action => "this_is_stixy_beta"
  #   map.signup "signup", :controller => "public", :action => "signup_beta"
  # 
  #   map.connect "public/signin", :controller => "public", :action => "signin_beta"
  #   map.connect "public/forgot_password", :controller => "public", :action => "forgot_password_beta"
  #   map.connect "public/contact_us", :controller => "public", :action => "contact_us_beta"
  #   map.connect "public/terms_of_service", :controller => "public", :action => "terms_of_service_beta"
  #   map.connect "public/privacy_policy", :controller => "public", :action => "privacy_policy_beta"
  #   map.connect "public/help", :controller => "public", :action => "help_beta"
  #   map.connect "public/how_stixy_works", :controller => "public", :action => "how_stixy_works_beta"
  #   map.connect "public/this_is_stixy", :controller => "public", :action => "this_is_stixy_beta"
  #   map.connect "public/signup", :controller => "public", :action => "signup_beta"
  # end
  
  # Change the name of the path to update to new uniq pathname. To prevent spam robots
  # If robots continues to be a problem we need to implement captcha
  # This will be a little bit tricky since the new support ticket lives on this server and the rest on the helpdesk server
  # CHANGE: This is no longer needed since we now use captcha
  map.support '/support', :controller => 'support', :action => 'index'
  
  # Promotional
  map.connect 'welcome/:action/:id', :controller => 'promotional', :id => /.*/
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id', :id => /.*/
  
  #Report a bug
  map.connect 'report_a_bug', :controller => "feedback", :action => "report_a_bug"
  
  map.connect ':action/:id',  :controller => "public", :id => /.*/
  
end
