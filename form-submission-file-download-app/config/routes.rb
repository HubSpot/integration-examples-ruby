Rails.application.routes.draw do
  get '/contacts', to: 'contacts#index'
  get '/oauth', to: 'oauth/authorization#authorize'
  get '/oauth/callback', to: 'oauth/authorization#callback'
  post '/webhooks/handle', to: 'webhooks#handle'
  resource :form, only: %i[show new create], controller: :form
  
  root to: 'contacts#index'
end
