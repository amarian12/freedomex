# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class BaseController < ::ApplicationController
    layout 'admin'

    before_action :auth_admin!
    before_action :auth_member!
    #before_action :block_ip_addresses

    def current_ability
      @current_ability ||= Admin::Ability.new(current_user)
    end

    def block_ip_addresses
      if request.env['REMOTE_ADDR'].present?
        if  (RestrictedIp.pluck(:whitelisted_ip).compact.exclude?(request.env['REMOTE_ADDR']))
          flash[:alert] = "Your IP Address is not whitelisted for Registration!"
          redirect_to :back
        end
      end
    end
  end
end

