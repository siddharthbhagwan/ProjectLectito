module DeviseHelper
  def devise_error_messages!
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t('errors.messages.not_saved',
      count: resource.errors.count,
      resource: resource.class.model_name.human.downcase)

    if messages == '<li>Email has already been taken</li>'
      html = <<-HTML
      <div class='signin_options'>
      
        <div class='alert alert-danger'>
          <strong>#{sentence}</strong>
          <ul>
            #{messages}
          </ul>
        </div>

        <div class='sbg rounded-corners'>
          <h5> Perhaps you signed up using another service</h5>
        </div>
      </div>
      <div><h5>Sign Up with another Email Id</h5></div>
      HTML
    else
      if params[:provider] == 'twitter'
        html = <<-HTML
        <div class='alert alert-info'>
          <strong>#{sentence}</strong>
          <ul>
            Please enter an Email Id to complete the registration
          </ul>
        </div>
        HTML
      else
        html = <<-HTML
        <div class='alert alert-danger'>
          <strong>#{sentence}</strong>
          <ul>
            #{messages}
          </ul>
        </div>
        HTML
      end

    end

    html.html_safe
  end
end
