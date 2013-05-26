ProjectLectito::Application.routes.draw do
  
  get "address/autocomplete_location_area"
  get "address/new" => "address#new"
  get "address/edit" => "address#edit"
  get "address/delete"
  match "address/update/:address_id" => "address#update"
  match "address/view" => "address#view"
  match "address/create" => "address#create"


  get "admin/view" => "admin#view"
  get "admin/edit" => "admin#admin_edit"
  get "admin" => "admin#admin_index"
  get "admin/user_details" => "admin#user_details"


  get "profile/new"
  get "profile/edit"
  match "profile/update"  => "profile#update"


  devise_for :users,
  controllers: {omniauth_callbacks: "omniauth_callbacks"}

  get "devise/User"
  match "home" => "home_page#home"
  match "admin" => "admin#admin"


  match  "book/create" => "book#create"
  get "book/view" => "book#view"
  match "book/edit" => "book#edit"
  match "book/delete" => "book#delete"
  match "book/update/:book_id" => "book#update"
  root :to => "home_page#home"
  resources :profile, :address, :home_page, :admin, :book

end