class LoggedInIpsController < ApplicationController
  def confirm_login_ip
    @loggedip = LoggedInIp.where(token: params[:token], ip_address: request.remote_ip).last
    if @loggedip && @loggedip.update(is_confirmed: true)
      flash[:notice] = "IP confirmed. Please Login now!"
    else
      flash[:notice] = "No request IP found! Please confirm again!"
    end
    redirect_to root_path
  end
end
