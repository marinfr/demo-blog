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
end
