module ApplicationHelper

  def render_flash
    flash.map do |name, message|
      content_tag(:p, message, class: "flash #{name}")
    end.join.html_safe
  end
end
