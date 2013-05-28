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


  post  "bookdb/create" => "book_detail#create"
  get "bookdb/view" => "book_detail#view"
  match "bookdb/edit" => "book_detail#edit"
  match "bookdb/delete" => "book_detail#delete"
  match "bookdb/update/:bookdetail_id" => "book_detail#update"
  get "bookdb/new" => "book_detail#new"

  get "user_book/autocomplete_book_detail_book_name"
  get "mybooks/view" => "user_book#view"
  match "user_book/create" => "user_book#create"
  get "user_book/delete"

  
  root :to => "home_page#home"
  resources :profile, :address, :home_page, :admin, :book_detail, :user_book

end