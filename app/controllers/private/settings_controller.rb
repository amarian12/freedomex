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
  end
end

