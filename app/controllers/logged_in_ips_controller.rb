class LoggedInIpsController < ApplicationController
  def confirm_login_ip
    @loggedip = LoggedInIp.find_by(:token=>"Ojox\n")
    if @loggedip.ip_address == request.remote_ip
      @loggedip.is_confirmed = true
      @loggedip.save
    end
    redirect_to "/auth/#{ENV['OAUTH2_SIGN_IN_PROVIDER'] == 'google' ? 'google_oauth2' : ENV['OAUTH2_SIGN_IN_PROVIDER']}"
  end
end
