ProjectLectito::Application.routes.draw do
  
  get "address/delete"
  get "address/autocomplete_location_area"
  get "address/new" => "address#new"
  get "address/edit" => "address#edit"
  match "address/update/:address_id" => "address#update"
  match "address/view" => "address#view"
  match "address/create" => "address#create"


  post "user_book/update/:user_book_id" => "user_book#update"

  get "admin/view" => "admin#view"
  get "admin/edit" => "admin#admin_edit"
  get "admin" => "admin#admin_index"
  get "admin/user_details" => "admin#user_details"

  # Profile Routes
  get "profile/edit"
  match "profile/update"  => "profile#update"

  get "devise/User"
  match "home" => "user_book#search"
  match "admin" => "admin#admin"


  get "bookdb/new" => "book_detail#new"
  get "bookdb/view" => "book_detail#view"
  post  "bookdb/create" => "book_detail#create"  
  match "bookdb/edit" => "book_detail#edit"
  match "bookdb/delete" => "book_detail#delete"
  match "bookdb/update/:bookdetail_id" => "book_detail#update"



  get "user_book/delete"
  get "mybooks/view" => "user_book#view"
  get "user_book/edit" => "user_book#edit"
  get "user_book/autocomplete_book_detail_author"
  get "user_book/autocomplete_book_detail_book_name"
  get "user_book/check_user_book_duplication" => "user_book#check_user_book_duplication"

  post "create" => "transaction#create"
  match "user_book/create" => "user_book#create"
  match "user_book/search_books" => "user_book#search_books"

  match "user_book/search_books_city" => "user_book#search_books_city"



  get "transaction/update_request_status_accept" => "transaction#update_request_status_accept"
  get "transaction/update_request_status_reject" => "transaction#update_request_status_reject"
  get "transaction/get_latest_lent" => "transaction#get_latest_lent"
  

  
  root :to => "user_book#search"
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}
  resources :profile, :address, :home_page, :admin, :book_detail, :user_book, :transaction

end