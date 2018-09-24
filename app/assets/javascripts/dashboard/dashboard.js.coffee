#= require clipboard
#= require_tree ./models
#= require_tree ./filters
#= require_self
#= require_tree ./config
#= require_tree ./services
#= require_tree ./directives
#= require_tree ./controllers
#= require ./router
#= require ./events

# $ ->
#   window.pusher_subscriber = new PusherSubscriber()
#   global_channel = window.pusher.subscribe("market-global")
#   global_channel.bind 'tickers', (data) =>
#     gon.tickers = data
#     MarketTicker.updateData(gon.tickers)

Member.initData         [gon.user]
Deposit.initData         gon.deposits
Account.initData         gon.accounts
Currency.initData        gon.currencies
Withdraw.initData        gon.withdraws
Market.initData          gon.markets
MarketTicker.initData    gon.tickers

window.app = app = angular.module 'dashboard', ["ui.router", "ngResource", "translateFilters", "textFilters", "precisionFilters", 'htmlFilters']

