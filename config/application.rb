require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Todos
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # Zona horaria de Guadalajara, México. Se puede sobrescribir por entorno.
    config.time_zone = ENV["RAILS_TIME_ZONE"].presence || "America/Mexico_City"
    # Guarda los timestamps en UTC en la base (Active Record convierte a la TZ arriba).
    config.active_record.default_timezone = :utc
    # Español por defecto (etiquetas y formatos de fecha).
    config.i18n.default_locale = :es
    config.i18n.available_locales = [ :es, :en ]
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
