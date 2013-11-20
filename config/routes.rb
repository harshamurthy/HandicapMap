HandicapApp::Application.routes.draw do

 root 'directions#landing_page'

 get '/route' => 'directions#route', as: 'route'

end
