ProjectLectito::Application.routes.draw do

  # Devise routes
  authenticated :user do
    root :to => 'inventory#search'
  end

  unauthenticated :user do
    devise_scope :user do 
      get "/" => "devise/sessions#new"
      get '/users/confirmation/new' => 'devise/passwords#new'
      get '/inventory/search' => 'devise/sessions#new'
    end
  end

  # Chat Routes
  get 'chat/box_chat_history' => 'chat#box_chat_history'

  # Profile Routes
  get 'profile/rating' => 'profile#rating'
  get 'profile/public_rating/:tr_id' => 'profile#public_rating'
  post 'profile/online' => 'profile#online'

  # Address Routes
  get 'address/autocomplete_area' => 'address#autocomplete_area'
  get 'address/:id/autocomplete_area' => 'address#autocomplete_area'

  # Admin routes
  get 'admin/user_details' => 'admin#user_details'
  get 'admin/user_transaction_history/:id' => 'admin#user_transaction_history', as: 'user_transaction_history'
  post 'admin/bar_user' => 'admin#bar_user'
  post 'admin/unbar_user' => 'admin#unbar_user'

  get 'devise/User'
  get 'home_page/barred' => 'home_page#user_barred'

  # Book Routes
  get 'book/history/:id' => 'book#history', as: 'book_history'
  get 'book/book_status' => 'book#book_status'
  get 'book/available_book_stats' => 'book#available_book_stats'
  get 'book/borrowed_book_stats' => 'book#borrowed_book_stats'

  # Inventory Routes
  get 'inventory/search' => 'inventory#search'
  get 'inventory/search_books' => 'inventory#search_books'
  get 'inventory/search_books_city' => 'inventory#search_books_city'
  get 'inventory/autocomplete_author' => 'inventory#autocomplete_author'
  get 'inventory/autocomplete_book_name' => 'inventory#autocomplete_book_name'
  get 'inventory/autocomplete_book_details' => 'inventory#autocomplete_book_details'
  get 'inventory/check_inventory_duplication' => 'inventory#check_inventory_duplication'

  # Transaction Routes
  get 'transaction/user_id' => 'transaction#user_id'
  get 'transaction/history' => 'transaction#history'
  get 'transaction/details/:id' => 'transaction#details', as: 'transaction_details'
  post 'transaction/new_chat' => 'transaction#new_chat'
  post 'transaction/update_request_status_accept' => 'transaction#update_request_status_accept'
  post 'transaction/update_request_status_reject' => 'transaction#update_request_status_reject'
  post 'transaction/update_request_status_cancel' => 'transaction#update_request_status_cancel'
  post 'transaction/update_request_status_return' => 'transaction#update_request_status_return'
  post 'transaction/update_request_status_receive_lender' => 'transaction#update_request_status_receive_lender'
  post 'transaction/update_request_status_receive_borrower' => 'transaction#update_request_status_receive_borrower'

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }, controllers: { sessions: :sessions }
  resources :profile, :address, :home_page, :admin, :book, :inventory, :transaction, :chat

end
