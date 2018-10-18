# encoding: UTF-8
# frozen_string_literal: true

module Private
  class SettingsController < BaseController
    helper_method :tabs
    def index
      begin
        @profile = RestClient.get(
          "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/profiles/me?access_token="+current_user.auth('barong').token
        )
        @profile =  JSON.parse @profile
      rescue => e

         flash[:alert] = e.message if !@profile.blank?
      end
    end

    def change_password
      if request.put?
        begin
          profile = RestClient.put(
            "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/accounts/password",
            params.require(:member).permit!.merge({access_token: current_user.auth('barong').token})
          )
          @status = true
          flash[:notice] =  "Password Changed!"
        rescue => e
           flash[:alert] = e.message
        end
        redirect_to settings_path
      end
    end

    def identity_verification
    end

    def account_data
      if request.post?
         params[:profile] = params[:profile].merge({access_token: current_user.auth('barong').token})
         params[:profile]["dob"] = Date.new params[:profile]["dob(1i)"].to_i, params[:profile]["dob(2i)"].to_i, params[:profile]["dob(3i)"].to_i
        begin
          profile = RestClient.post(
            "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/profiles",
            params.require(:profile).permit!
          )
          @status = true
          flash[:notice] =  "Profile Created!"
        rescue => e
           flash[:alert] = e.message
        end
        redirect_to settings_path
      end
    end

  end
end

