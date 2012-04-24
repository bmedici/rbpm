class Utils
  def to_unc(path, server="localhost", share=nil)
    parts = path.split(File::SEPARATOR)
    parts.shift while parts.first.empty?
    if share
      parts.unshift share
    else
      # Assumes the drive will always be a single letter up front
      parts[0] = "#{parts[0][0,1]}$" 
    end
    parts.unshift server
    "\\\\#{parts.join('\\')}"
  end

end