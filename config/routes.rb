ProjectLectito::Application.routes.draw do
  
  get "address/delete"
  get "address/new" => "address#new"
  get "address/edit" => "address#edit"
  get "address/autocomplete_area" => "address#autocomplete_area"
  match "address/update/:address_id" => "address#update"
  match "address/view" => "address#view"
  match "address/create" => "address#create"


  post "inventory/update/:inventory_id" => "inventory#update"

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
  match "home" => "inventory#search"
  match "admin" => "admin#admin"
  match "home_page/barred" => "home_page#user_barred"


  get "bookdb/new" => "book#new"
  get "bookdb/view" => "book#view"
  post  "bookdb/create" => "book#create"  
  match "bookdb/edit" => "book#edit"
  match "bookdb/delete" => "book#delete"
  match "bookdb/update/:book_id" => "book#update"
  match "book/book_status" => "book#book_status"
  match "book/available_book_stats" => "book#available_book_stats"
  match "book/borrowed_book_stats" => "book#borrowed_book_stats"



  get "inventory/delete"
  get "mybooks/view" => "inventory#view"
  get "inventory/edit" => "inventory#edit"
  get "inventory/search" => "inventory#search"
  get "inventory/autocomplete_author" => "inventory#autocomplete_author"
  get "inventory/autocomplete_book_name" => "inventory#autocomplete_book_name"
  get "inventory/autocomplete_book_details" => "inventory#autocomplete_book_details"
  get "inventory/check_inventory_duplication" => "inventory#check_inventory_duplication"

  post "create" => "transaction#create"
  match "inventory/create" => "inventory#create"
  match "inventory/search_books" => "inventory#search_books"
  match "inventory/search_books_city" => "inventory#search_books_city"


  get "transaction/update_request_status_accept" => "transaction#update_request_status_accept"
  get "transaction/update_request_status_reject" => "transaction#update_request_status_reject"
  get "transaction/get_latest_lent" => "transaction#get_latest_lent"  

  
  root :to => "inventory#search"
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}
  resources :profile, :address, :home_page, :admin, :book, :inventory, :transaction

end