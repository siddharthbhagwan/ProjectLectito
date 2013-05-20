ProjectLectito::Application.routes.draw do
  
  get "address/autocomplete_location_area"
  get "address/new" => "address#new"
  get "address/edit" => "address#edit"
  get "address/delete"


  get "admin/view" => "admin#view"
  get "admin/edit" => "admin#admin_edit"
  match "admin" => "admin#admin_index"
  get "admin/user_details" => "admin#user_details"

  match "address/update/:address_id" => "address#update"
  match "address/view" => "address#view"
  match "address/create" => "address#create"


  get "profile/new"
  get "profile/edit"
  match "profile/update"  => "profile#update"


  devise_for :users,
  controllers: {omniauth_callbacks: "omniauth_callbacks"}

  get "devise/User"
  match "home" => "home_page#home"
  match "admin" => "admin#admin"

  root :to => "home_page#home"
  resources :profile, :address, :home_page, :admin  
  



end
