class RestrictedIp < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20181023073412
#
# Table name: restricted_ips
#
#  id             :integer          not null, primary key
#  whitelisted_ip :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
