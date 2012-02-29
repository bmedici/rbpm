class WebserviceController < ApplicationController
  layout :nil

  def getdate
    render :text => "Date is: #{Time.now.to_s}"
  end

  def wait
  end

  def encode
  end

  def checksum
  end

end
