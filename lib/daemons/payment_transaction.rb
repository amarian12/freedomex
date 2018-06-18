# encoding: UTF-8
# frozen_string_literal: true

RAILS_ROOT = File.expand_path('../../..', __FILE__)
require File.join(RAILS_ROOT, 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running do
  Deposits::Coin.recent.where(aasm_state: :submitted).find_each batch_size: 100 do |deposit|
    break unless running
    begin
      confirmations = deposit.currency.api.load_deposit!(deposit.txid).fetch(:confirmations)
      deposit.with_lock do
        deposit.update!(confirmations: confirmations)
        deposit.accept! if confirmations >= deposit.currency.deposit_confirmations
      end
    rescue => e
      report_exception(e)
    end
  end

  Kernel.sleep 5
end
