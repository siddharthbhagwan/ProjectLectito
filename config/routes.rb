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

  # Profile Routes
  get "profile/edit"
  match "profile/update"  => "profile#update"


  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}

  get "devise/User"
  match "home" => "user_book#search"
  match "admin" => "admin#admin"
  match "users/sign_out" => "home_page#home"


  get "bookdb/new" => "book_detail#new"
  get "bookdb/view" => "book_detail#view"
  post  "bookdb/create" => "book_detail#create"  
  match "bookdb/edit" => "book_detail#edit"
  match "bookdb/delete" => "book_detail#delete"
  match "bookdb/update/:bookdetail_id" => "book_detail#update"


  get "user_book/delete"
  get "mybooks/view" => "user_book#view"
  get "user_book/autocomplete_book_detail_book_name"  
  post "user_book/create" => "user_book#create"
  match "user_book/create" => "user_book#create"
  match "user_book/search" => "user_book#search"
  match "user_book/sub_search" => "user_book#sub_search"

  
  root :to => "user_book#search"
  resources :profile, :address, :home_page, :admin, :book_detail, :user_book

end