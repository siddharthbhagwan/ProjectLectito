ProjectLectito::Application.routes.draw do
  
  # Address Routes
  get "address/autocomplete_area" => "address#autocomplete_area"
  get "address/:id/autocomplete_area" => "address#autocomplete_area"

  # Admin routes
  get "admin/user_details" => "admin#user_details"
  post "admin/bar_user" => "admin#bar_user"
  post "admin/unbar_user" => "admin#unbar_user"

  get "devise/User"
  get "home" => "inventory#search"
  get "home_page/barred" => "home_page#user_barred"

  # Book Routes
  get "book/book_status" => "book#book_status"
  get "book/available_book_stats" => "book#available_book_stats"
  get "book/borrowed_book_stats" => "book#borrowed_book_stats"

  # Inventory Routes
  get "inventory/search" => "inventory#search"
  get "inventory/search_books" => "inventory#search_books"
  get "inventory/search_books_city" => "inventory#search_books_city"
  get "inventory/autocomplete_author" => "inventory#autocomplete_author"
  get "inventory/autocomplete_book_name" => "inventory#autocomplete_book_name"
  get "inventory/autocomplete_book_details" => "inventory#autocomplete_book_details"
  get "inventory/check_inventory_duplication" => "inventory#check_inventory_duplication"
  post "inventory/update/:inventory_id" => "inventory#update"

  # Transaction Routes
  get "transaction/latest_lent" => "transaction#latest_lent"
  get "transaction/latest_borrowed" => "transaction#latest_borrowed"
  get "transaction/update_request_status_accept" => "transaction#update_request_status_accept"
  get "transaction/update_request_status_reject" => "transaction#update_request_status_reject"
   

  root :to => "inventory#search"
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}
  resources :profile, :address, :home_page, :admin, :book, :inventory, :transaction

end