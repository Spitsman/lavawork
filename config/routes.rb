Rails.application.routes.draw do
  root to: 'home#index'

  get 'sign_in' => 'user_sessions#new'
  post 'sign_in' => 'user_sessions#create'
  delete 'sign_out' => 'user_sessions#destroy'

  resources :residents, only: :index
  resources :messages, only: :index

  get 'settings' => 'settings#index'
  post 'settings/demurrage' => 'settings#demurrage'
  post 'settings/commission' => 'settings#commission'
  post 'settings/master_account' => 'settings#master_account'
  post 'settings/accrual_frequency' => 'settings#accrual_frequency'
  post 'settings/additional_amount' => 'settings#additional_amount'

  get 'telegram/broadcast' => 'telegram#broadcast', as: 'broadcast'
  post 'telegram/broadcast' => 'telegram#send_broadcast', as: 'send_broadcast'
  get 'telegram' => 'telegram#index', as: 'telegram'
  post 'telegram/send' => 'telegram#send_message', as: 'send_message'

  resources :transactions, only: :index

  telegram_webhooks TelegramWebhooksController
end
