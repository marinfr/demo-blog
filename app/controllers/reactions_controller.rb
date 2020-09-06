class ReactionsController < ApplicationController
  def create
    reaction = current_user.reactions.find_or_initialize_by(
      resource_id:   params[:resource_id],
      resource_type: params[:resource_type],
      type:          params[:type]
    )

    if reaction.persisted?
      reaction.destroy!
    else
      reaction.save!
    end
  end
end