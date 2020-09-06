class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)

    if resource.save
      sign_up(resource_name, resource)
      render json: { redirect_to: root_path }
    else
      render json: { errors: resource.errors.messages }, status: 400
    end
  end

  private

  def after_sign_up_path_for(resource)
    flash.clear
    root_path
  end
end
