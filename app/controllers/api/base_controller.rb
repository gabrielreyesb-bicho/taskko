module Api
  # Base para todos los endpoints de la API que consume TARS.
  #
  # Autenticación: si la variable de entorno API_TOKEN está definida, exige el
  # header `Authorization: Bearer <token>`. Si no está definida (p. ej. en dev),
  # la API queda abierta. Así es simple en local y se puede blindar en producción
  # (Cloudflare Tunnel) con solo setear la variable.
  class BaseController < ActionController::API
    before_action :authenticate_api!

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "not_found" }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { error: "invalid", messages: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    private

    def authenticate_api!
      expected = ENV["API_TOKEN"].presence
      return if expected.nil? # API abierta si no se configuró token

      provided = request.headers["Authorization"].to_s.remove(/\ABearer\s+/i)
      return if ActiveSupport::SecurityUtils.secure_compare(provided, expected)

      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
