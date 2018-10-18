class MemberMailer < ApplicationMailer
  def ip_address_confirmation_instructions(member, token)
    @member = member
    @token = token
    @ip = member.logged_in_ips.where(token: token).first.ip_address
    mail(to: @member.email,
      subject: 'Confirm Your New Login',
      from: "support@freedomex.io",
      reply_to: "support@freedomex.io"
    )
  end
end
