Rails.application.routes.draw do
  root to: 'home#index'

  get 'sign_in' => 'user_sessions#new'
  post 'sign_in' => 'user_sessions#create'
  delete 'sign_out' => 'user_sessions#destroy'

  resources :residents
  resources :messages, only: :index

  get 'settings' => 'settings#index'
  Settings.keys.each do |key|
    post "settings/#{key}" => "settings##{key}"
  end

  get 'telegram/broadcast' => 'telegram#broadcast', as: 'broadcast'
  post 'telegram/broadcast' => 'telegram#send_broadcast', as: 'send_broadcast'
  get 'telegram' => 'telegram#index', as: 'telegram'
  post 'telegram/send' => 'telegram#send_message', as: 'send_message'

  resources :transactions, only: :index

  namespace :my do
    get '/' => 'home#index'
    resources :transactions, only: [:index, :create]
  end

  telegram_webhooks TelegramWebhooksController
end
