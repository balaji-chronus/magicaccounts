module UsersHelper
	def render_user_image(user, options = {})
		image_content = gravatar_image_tag(user.email, :class => "#{options[:class_name]} mg-user-image", :gravatar => {:size => options[:size] || 32})
		image_content = ((content_tag(:span, user.name, :class => "btn btn-default btn-xs #{options[:user_name_class]}") if options[:user_name_class].present?) || "") + image_content
		return image_content
	end

  def render_activity(activity)
    if activity.activity == " added "
      icon_class = 'icon-plus-sign'
      span_class = 'label-success'
    elsif activity.activity == " removed "
      icon_class = 'icon-edit-sign'
      span_class = 'label-danger'
    elsif activity.activity == " changed "
      icon_class = 'icon-trash'
      span_class = 'label-warning'
    end
    time_ago = content_tag(:span, content_tag(:small, raw("&nbsp; - ") + time_ago_in_words(activity.created_at.to_s) + " ago"), :class => 'text-muted')
    return content_tag(:span, content_tag(:i, "", :class => icon_class) + " " + j(activity.activity), :class => "label #{span_class}") + time_ago
  end
end
