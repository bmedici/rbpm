module ApplicationHelper
  
  # Dates and times: date generator
  def my_date(param, format = :short)
    return "-"  if param.nil?
    thedate = param.to_date
    today = Time.now.to_date
    yesterday = today - 1.day
    tomorrow = today + 1.day
 
    case format
      when :short_with_seconds then
        return ""  if (thedate==today)
        return "hier" if (thedate==yesterday)
        return "demain" if (thedate==tomorrow)
        return thedate.strftime("%d.%m") if (thedate.year==today.year)
        return thedate.strftime("%d.%m.%Y")      
      when :short then
        return "auj."  if (thedate==today)
        return "hier" if (thedate==yesterday)
        return "demain" if (thedate==tomorrow)
        return thedate.strftime("%d.%m") if (thedate.year==today.year)
        return thedate.strftime("%d.%m.%Y")      
      when :long then
        return "aujourd'hui"  if (thedate==today)
        return "hier" if (thedate==yesterday)
        return "demain" if (thedate==tomorrow)
        return thedate.strftime("%A %d %B") if (thedate.year==today.year)
        return thedate.strftime("%A %d %B %Y")
      end 
  end  

  # Dates and times: time generator
  def my_time(param, format = :short)
    return "-"  if param.nil?
    case format
      when :short then
        return param.to_datetime.strftime("%H:%M")        
      when :short_with_seconds, :long then
        return param.to_datetime.strftime("%H:%M:%S")        
      end 
  end

  # Dates and times: date with time generator
  def my_datetime(param, format = :short_with_seconds)
    return "-"  if param.nil?
    return "#{my_date(param, format)} #{my_time(param, format)}"
  end
  
  def seconds_ago(seconds)
    rounded = sprintf "%.1f", seconds
    return "#{rounded}s ago"
  end
  
  # Dates and times: misc helpers
  def my_date_short(param)
   return my_date(param, :short)
  end
  def my_date_long(param)
    return my_date(param, :long)
  end
  def my_date_interval(date1, date2)
    if date1
      if date2 == date1
        "le #{my_date(date1, :short)}"
      elsif date2
        "du #{my_date(date1, :short)} au #{my_date(date2, :short)}"  
      end
    end
  end
  
  def set_title(title)
    @title = title
  end
  
  
  # Button helpers
  def add_button(type, path, text = "")
    # Map some types to default ones
    map = {
      :refresh => :reload,
      :restore => :reload,
      :back => :arrowleft,
      :link => :arrowright,
      :delete => :remove,
      :print => :log,
      #:delete => :remove,
      nil => :arrowright,
    }
    
    # Force method "delete" if original type is :delete
    method = :delete if type.to_sym == :delete

    # Catch the original type here, as a fallback
    text = type if text.blank?
    
    # Then map the type if expected
    type = map[type] unless map[type].nil?
    
    # Stack this info in the button array  
    @buttons ||= []
    @buttons << [type, path, text, method]
  end

  def twitterized_type(type)
    case type
      when :alert
        "warning"
      when :error
        "error"
      when :notice
        "info"
      when :success
        "success"
      else
        type.to_s
    end
  end
  
end
