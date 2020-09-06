module ApplicationHelper
  def can_manage_resource?(resource)
    resource.author == current_user
  end

  def normalize_content(text)
    text
      .strip
      .gsub(/(\r\n){2,}/, "\r\n")
      .gsub(/(<br>){1,}/, "\r\n<br>")
  end

  def reaction_class(reactions)
    reactions.pluck(:user_id).include?(current_user.id) ? "active" : ""
  end
end
