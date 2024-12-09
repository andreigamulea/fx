Rails.application.routes.draw do
  get '/us30s/preluare_us30', to: 'us30s#preluare_us30', as: 'preluare_us30_us30s'
  get '/us30s/preluare_us301', to: 'us30s#preluare_us301', as: 'preluare_us30_us301s'
  get '/us30s/preluare_us30_cu_duplicat', to: 'us30s#preluare_us30_cu_duplicat', as: 'preluare_us30_cu_duplicat_us30s'
  get '/btcs/preluare_btc', to: 'btcs#preluare_btc', as: 'preluare_btc_btcs'
  get '/btcs/preluare_btc1', to: 'btcs#preluare_btc1', as: 'preluare_btc_btcs1'
  get 'home/analiza_us30', to: 'home#analiza_us30', as: 'home_analiza_us30'
  get 'home/analiza_us30_tabel', to: 'home#analiza_us30_tabel', as: 'home_analiza_us30_tabel'
  post 'home/analiza_us30_tabel', to: 'home#analiza_us30_tabel'
  get 'home/analiza_btc', to: 'home#analiza_btc', as: 'home_analiza_btc'
  post 'home/analiza_btc_tabel', to: 'home#analiza_btc_tabel', as: 'home_analiza_btc_tabel'
  


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
