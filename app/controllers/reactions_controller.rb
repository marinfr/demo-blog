class ReactionsController < ApplicationController
  def create
    return head(:bad_request) if [Reaction::POST, Reaction::COMMENT].exclude?(params[:resource_type])

    resource = params[:resource_type].capitalize.constantize.find(params[:resource_id])
    reaction = resource.reactions.find_or_initialize_by(
      user_id: current_user.id,
      type:    params[:type]
    )

    if reaction.persisted?
      reaction.destroy!
    else
      reaction.save!
    end
  end
end
