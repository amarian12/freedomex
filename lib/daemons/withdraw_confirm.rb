# encoding: UTF-8
# frozen_string_literal: true
RAILS_ROOT = File.expand_path('../../..', __FILE__)
require File.join(RAILS_ROOT, 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  Withdraw.succeed.order(created_at: :asc).each do |w|
    next if w.txid.blank?
    w.try_to_confirm!
  end
  sleep 5
end
