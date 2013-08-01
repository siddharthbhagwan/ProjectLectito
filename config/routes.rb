ProjectLectito::Application.routes.draw do
  
  get "address/delete"
  get "address/new" => "address#new"
  get "address/edit" => "address#edit"
  get "address/autocomplete_area" => "address#autocomplete_area"
  match "address/update/:address_id" => "address#update"
  match "address/view" => "address#view"
  match "address/create" => "address#create"


  post "user_inventory/update/:user_inventory_id" => "user_inventory#update"

  get "admin/view" => "admin#view"
  get "admin/edit" => "admin#admin_edit"
  get "admin" => "admin#admin_index"
  get "admin/user_details" => "admin#user_details"
  post "admin/bar_user" => "admin#bar_user"
  post "admin/unbar_user" => "admin#unbar_user"

  # Profile Routes
  get "profile/edit" => "profile#edit"
  match "profile/update"  => "profile#update"

  get "devise/User"
  match "home" => "user_inventory#search"
  match "admin" => "admin#admin"
  match "home_page/barred" => "home_page#user_barred"


  get "bookdb/new" => "book_detail#new"
  get "bookdb/view" => "book_detail#view"
  post  "bookdb/create" => "book_detail#create"  
  match "bookdb/edit" => "book_detail#edit"
  match "bookdb/delete" => "book_detail#delete"
  match "bookdb/update/:bookdetail_id" => "book_detail#update"
  match "book_detail/book_status" => "book_detail#book_status"
  match "book_detail/available_book_stats" => "book_detail#available_book_stats"
  match "book_detail/borrowed_book_stats" => "book_detail#borrowed_book_stats"



  get "user_inventory/delete"
  get "mybooks/view" => "user_inventory#view"
  get "user_inventory/edit" => "user_inventory#edit"
  get "user_inventory/search" => "user_inventory#search"
  get "user_inventory/autocomplete_author" => "user_inventory#autocomplete_author"
  get "user_inventory/autocomplete_book_name" => "user_inventory#autocomplete_book_name"
  get "user_inventory/autocomplete_book_details" => "user_inventory#autocomplete_book_details"
  get "user_inventory/check_user_inventory_duplication" => "user_inventory#check_user_inventory_duplication"

  post "create" => "transaction#create"
  match "user_inventory/create" => "user_inventory#create"
  match "user_inventory/search_books" => "user_inventory#search_books"
  match "user_inventory/search_books_city" => "user_inventory#search_books_city"


  get "transaction/update_request_status_accept" => "transaction#update_request_status_accept"
  get "transaction/update_request_status_reject" => "transaction#update_request_status_reject"
  get "transaction/get_latest_lent" => "transaction#get_latest_lent"  

  
  root :to => "user_inventory#search"
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}
  resources :profile, :address, :home_page, :admin, :book_detail, :user_inventory, :transaction

end