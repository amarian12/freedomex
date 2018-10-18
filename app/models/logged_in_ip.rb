class LoggedInIp < ActiveRecord::Base
  belongs_to :member

  before_create :set_ip_token

  private
  def set_ip_token
    self.token = Base64.encode64(self.ip_address)
  end
end

# == Schema Information
# Schema version: 20181018081939
#
# Table name: logged_in_ips
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  ip_address   :string(255)
#  token        :string(255)
#  is_confirmed :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_logged_in_ips_on_member_id  (member_id)
#
# Foreign Keys
#
#  fk_rails_1f048330c4  (member_id => members.id)
#
