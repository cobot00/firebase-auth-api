class SessionController < ActionController::API
  def create
    begin
      result = Firebase::AuthClient.authenticate!(params[:email], params[:password])
      render json: SessionSerializer.new(result).serialize
    rescue Firebase::AuthenticationException => e
      render status: :bad_request, json: { message: e.message }
    end
  end

  def update
    begin
      result = Firebase::AuthClient.refresh!(request.headers[:Authorization])
      render json: SessionSerializer.new(result).serialize
    rescue Firebase::AuthenticationException
      render status: :unauthorized
    end
  end
end
