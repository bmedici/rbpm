require 'base64'
module StatusHelper
  
  def inline_image_src(content_type, data)
    #base64_data = escape_javascript(Base64.encode64(data))
    base64_data = Base64.encode64(data)
    return "data:#{content_type};base64,#{base64_data}"
  end
  
end