Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker


  # Admin CSV Report
  get "admin/relatorios/csv" => "resultados#export_csv_resultado", as: :admin_relatorios_csv
  get "admin/relatorios" => "resultados#relatorios", as: :admin_relatorios

  # Resultados (Consolidated reports)
  get "resultados" => "resultados#index", as: :resultados
  get "resultados/:id" => "resultados#show", as: :resultado
  get "resultados/:id/export_csv" => "resultados#export_csv_resultado", as: :export_csv_resultado

  # Defines the root path route ("/")
  # root "posts#index"
end
