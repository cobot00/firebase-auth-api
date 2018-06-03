class UserController < ApplicationController
  def create
    values = permitted_params
    User.sign_up!(values[:email], values[:password], values[:name])
    render status: :ok
  rescue Firebase::AuthenticationException => e
    render status: :bad_request, json: { message: e.message }
  end

  def current
    render json: User.find_with_id(user_id)
  rescue ActiveRecord::RecordNotFound
    render status: :bad_request, json: { message: '対象のデータが存在しません。' }
  end

  def destroy
    User.disable!(params[:id])
    render status: :ok
  rescue ActiveRecord::RecordNotFound
    render status: :bad_request, json: { message: '対象のデータが存在しません。' }
  end

  private

  def permitted_params
    params.permit(*User::PERMITTED_FIELDS)
  end
end
