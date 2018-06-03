class ApplicationController < ActionController::API
  attr_reader :user_id

  before_action :authenticate

  private

  def authenticate
    begin
      decoded = JwtWrapper.decode_jwt(request.headers)
      @user_id = decoded.user_id
      raise ApplicationController::NotAuthorized unless @user_id
      session[:user_id] = @user_id
    rescue => e
      logger.warn(e.message)
      logger.warn(e.backtrace.join("\n").truncate(1000))
      render status: :unauthorized
    end
  end
end
