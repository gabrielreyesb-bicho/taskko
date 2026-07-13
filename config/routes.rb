Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Interfaz web (CRUD de tareas).
  resources :categories, except: %i[show]

  # Interfaz web (CRUD de tareas).
  resources :tasks do
    member do
      # Cambio rápido de estatus desde la lista.
      patch :status, to: "tasks#update_status"
    end
  end

  # API para TARS: CRUD + recordatorios proactivos.
  namespace :api do
    namespace :v1 do
      resources :tasks do
        member do
          post :notified   # POST /api/v1/tasks/:id/notified
        end
      end
      # Recordatorios vencidos aún no notificados.
      get "reminders/due", to: "reminders#due"
    end
  end

  # Página principal: la lista de tareas.
  root "tasks#index"
end
