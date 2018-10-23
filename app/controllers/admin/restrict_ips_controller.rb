module Admin
  class RestrictIpsController < BaseController

    def index
      @restrictIps = RestrictedIp.all
    end

    def edit
      @restrictip = RestrictedIp.find(params[:id])
    end

    def update
      restrictip = RestrictedIp.find(params[:id])
      restrictip.update(ip_address_params)
      redirect_to admin_restrict_ips_path
    end

    def destroy
      restrictip = RestrictedIp.find(params[:id])
      if restrictip.destroy
        redirect_to admin_restrict_ips_path
      else
        flash[:alert] = "Record Removed"
        redirect_to admin_restrict_ips_path
      end
    end


    def whitelisted_ip
      restrictip = RestrictedIp.find_or_create_by(whitelisted_ip: params[:admin_whitelisted_ip])
      redirect_to admin_restrict_ips_path
    end

    private

    def ip_address_params
      params.require(:restricted_ip).permit(:whitelisted_ip)
    end

  end
end
