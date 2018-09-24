HeaderCoffee =
  setHeaderValues: ->
    _this = this
    $.each gon.markets, (market, marketTic) ->
      marketLi = $('.market_' + market)
      if marketLi.length > 0
        _this.setValuesNow marketTic, marketLi
      return
    return

  setValuesNow: (marketTic, marketLi) ->
    _this = this
    marketTicker = MarketTicker.findBy('name', marketTic.name)
    marketLi.find('span.last_price').text marketTicker.last
    marketLi.find('span.24h_change').text _this.priceChange(marketTicker)
    marketLi.find('span.24h_high').text marketTicker.high
    marketLi.find('span.24h_low').text marketTicker.low
    marketLi.find('span.24h_volume').text marketTicker.volume
    return

  priceChange: (marketTicker) ->
    p1 = parseFloat marketTicker.open
    p2 = parseFloat marketTicker.last
    percent = if p1
                Math.round((100*(p2-p1)/p1) * 100) / 100
              else
                '0'
    return percent
window.HeaderCoffee = HeaderCoffee
