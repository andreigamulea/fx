Rails.application.routes.draw do

  get '/xauusds/preluare_xauusd', to: 'xauusds#preluare_xauusd', as: 'preluare_xauusd_xauusds'
  get '/xauusds/analiza_xauusd', to: 'xauusds#analiza_xauusd', as: 'xauusds_analiza_xauusd'
  get '/xauusds/analiza_xauusd_tabel', to: 'xauusds#analiza_xauusd_tabel', as: 'xauusds_analiza_xauusd_tabel'
  post '/xauusds/analiza_xauusd_tabel', to: 'xauusds#analiza_xauusd_tabel'
  get '/xauusds/preluare_xauusd1', to: 'xauusds#preluare_xauusd1', as: 'preluare_xauusd1_xauusds'




  resources :xauusds
  get '/us30s/preluare_us30', to: 'us30s#preluare_us30', as: 'preluare_us30_us30s'
  get '/us30s/preluare_us301', to: 'us30s#preluare_us301', as: 'preluare_us30_us301s'
  get '/us30s/preluare_us30_cu_duplicat', to: 'us30s#preluare_us30_cu_duplicat', as: 'preluare_us30_cu_duplicat_us30s'
  get '/btcs/preluare_btc', to: 'btcs#preluare_btc', as: 'preluare_btc_btcs'
  get '/btcs/preluare_btc1', to: 'btcs#preluare_btc1', as: 'preluare_btc_btcs1'
  # routes.rb
  get 'us30s/analiza_us30', to: 'us30s#analiza_us30', as: 'us30s_analiza_us30'
  get 'us30s/analiza_us30_tabel', to: 'us30s#analiza_us30_tabel', as: 'us30s_analiza_us30_tabel'
  post 'us30s/analiza_us30_tabel', to: 'us30s#analiza_us30_tabel'

  # routes.rb
get 'btcs/analiza_btc', to: 'btcs#analiza_btc', as: 'btcs_analiza_btc'
get 'btcs/analiza_btc_tabel', to: 'btcs#analiza_btc_tabel', as: 'btcs_analiza_btc_tabel'
post 'btcs/analiza_btc_tabel', to: 'btcs#analiza_btc_tabel'

  


  resources :btcs
  resources :us30s
  get 'monezi/us30'
  get 'home/index'
  get 'home/preluare'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"



end
