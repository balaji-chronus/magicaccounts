module UsersHelper
	def render_user_image(user, options = {})
		image_content = gravatar_image_tag(user.email, :class => "gravatar_image", :gravatar => {:size => options[:size] || 32}) 
		(image_content += content_tag(:span, user.name, :class => "gravatar_user_name")) if options[:render_user_name]
		return image_content
	end
end
