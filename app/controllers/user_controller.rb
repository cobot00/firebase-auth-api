class UserController < ApplicationController
  def create
    values = permitted_params
    User.sign_up!(values[:email], values[:password], values[:name])
    render status: :ok
  rescue Firebase::AuthenticationException => e
    render status: :bad_request, json: { message: e.message }
  end

  private

  def permitted_params
    params.permit(*User::PERMITTED_FIELDS)
  end
end
