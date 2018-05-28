class SessionController < ApplicationController
  def create
    begin
      result = Firebase::AuthClient.authenticate!(params[:email], params[:password])
      render json: SessionSerializer.new(result).serialize
    rescue Firebase::AuthenticationException => e
      render status: :bad_request, json: { message: e.message }
    end
  end
end
