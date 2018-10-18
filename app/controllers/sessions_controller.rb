# encoding: UTF-8
# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: :failure
  #before_action :loggedin_ip_confirmation, only: :create

  def create
    @member = Member.from_auth(auth_hash)
    return redirect_on_unsuccessful_sign_in unless @member
    return redirect_to(root_path, alert: t('.disabled')) if @member.disabled?
    return redirect_to(root_path, alert: 'Please check you mail and confirm IP address.') unless loggedin_ip_confirmation

    reset_session rescue nil
    session[:member_id] = @member.id
    memoize_member_session_id @member.id, session.id
    redirect_on_successful_sign_in
  end

  def failure
    redirect_to root_path, alert: t('.error')
  end

  def destroy
    destroy_member_sessions(current_user.id)
    reset_session
    # redirect_to root_path
    redirect_to "#{ENV.fetch('BARONG_DOMAIN')}#{ENV.fetch('BARONG_SIGNOUT_PATH')}"
  end

private

  def loggedin_ip_confirmation
    member = @member
    unless member.logged_in_ips.where(is_confirmed: true).map(&:ip_address).include?(request.remote_ip)
      logged_in_ip = member.logged_in_ips.create(ip_address: request.remote_ip)
      reset_session
      MemberMailer.ip_address_confirmation_instructions(member, logged_in_ip.token).deliver_now rescue true
      flash[:notice] = 'Please check you mail and confirm IP address.'
      return false
    end
    return true
  end

  def auth_hash
    @auth_hash ||= request.env['omniauth.auth']
  end

  def redirect_on_successful_sign_in
    "#{params[:provider].to_s.gsub(/(?:_|oauth2)+\z/i, '').upcase}_OAUTH2_REDIRECT_URL".tap do |key|
      if ENV[key] && params[:provider].to_s == 'barong'
        redirect_to "#{ENV[key]}?#{auth_hash.fetch('credentials').to_query}"
      elsif ENV[key]
        redirect_to ENV[key]
      else
        redirect_to settings_url
      end
    end
  end

  def redirect_on_unsuccessful_sign_in
    redirect_to root_path, alert: t('.error')
  end
end
