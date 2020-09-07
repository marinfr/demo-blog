class Users::SessionsController < Devise::SessionsController

  def create
    resource = User.find_by(email: params[:user][:email])
    return super if resource && resource.valid_password?(params[:user][:password])

    render json: { errors: { password: ["wrong email or password"] } }, status: 400
  end

  private

  def after_sign_in_path_for(resource)
    flash.clear
    root_path
  end
end
