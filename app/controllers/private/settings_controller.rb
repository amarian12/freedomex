# encoding: UTF-8
# frozen_string_literal: true

module Private
  class SettingsController < BaseController

    def index
      @loggedips = current_user.logged_in_ips
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

    def generate_qrcode
      begin
        @api_accesses = RestClient.post(
          "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/security/generate_qrcode?access_token="+current_user.auth('barong').token,params)
        @qr_code =  JSON.parse @api_accesses
      rescue => e
        @message = e.message
      end
      render :json => {:qr_code => @qr_code,
                                  :message => @message }
    end

    # def update_phone
    #     begin
    #       @update_phone = RestClient.post(
    #         "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/phones?access_token="+current_user.auth('barong').token,params
    #       )
    #       @status = true
    #       flash[:notice] =  "phone submitted!"
    #     rescue => e
    #       flash[:alert] = e.message
    #     end
    #     redirect_to settings_path
    #   end

    def verify_contact
      begin

          @update_phone = RestClient.post(
            "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/phones?access_token="+current_user.auth('barong').token,params
          )
          @status = true
          flash[:notice] =  "phone submitted!"
        rescue => e
          flash[:alert] = e.message
        end
        redirect_to settings_path
    end

    def upload_document

      begin
          @document = RestClient.post( "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/documents?access_token="+current_user.auth('barong').token,params )
          @status = true
          flash[:notice] =  "Document submitted!"
        rescue => e
          flash[:alert] = e.message
        end
         render :json => {:document => @document,
                                  :message => @message }
    end


  def verify_phone
      begin
          @update_phone = RestClient.post( "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/phones/verify?access_token="+current_user.auth('barong').token,params )
          
          @status = true
          flash[:notice] =  "phone submitted!"
        rescue => e
          flash[:alert] = e.message
        end
      render :json => {:phone_verfiy => @update_phone,
                                  :message => @message }
                                end
      # def send_code
      #   begin
      #    @send_code = RestClient.post(
      #       "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/phones?access_token="+current_user.auth('barong').token,params
      #       )
      #     @status = true
      #     flash[:notice] =  "send submitted!"
      #   rescue => e
      #     flash[:alert] = e.message
      #   end
      # render :json => {:code => @send_code,
      #                             :message => @message }

      # end

    def enabled_2fa
      begin
        @enabled_2fa = RestClient.post(
          "#{ENV.fetch('BARONG_DOMAIN')}/api/v1/security/enable_2fa?access_token="+current_user.auth('barong').token,params
        )
        @enabled_2fa =  JSON.parse @enabled_2fa
      rescue => e
         flash[:alert] = e.message
      end
      redirect_to settings_path
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
