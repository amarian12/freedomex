app.directive 'dashboard', ->
  return {
    restrict: 'E'
    templateUrl: '/templates/dashboard/dashboard_tables.html'
    scope: { localValue: '=markets' }
    controller: ($scope, $state) ->
      ctrl = @
      @state = $state
      #if window.location.hash == ""
      #  @state.transitionTo("deposits.currency", {currency: Account.first().currency})

      $scope.accounts = Account.all()
      $scope.markets = Market.all()
      $scope.marketTickers = MarketTicker.all()

      @marketTicker = null
      $scope.marketTicker = @marketTicker

      @ifMarketsPresent = (currency_code) ->
        @getMarkets(currency_code).length > 0

      @getMarkets = (currency_code) ->
        Market.findAllBy('bid_unit', currency_code)

      @getMarketTicker = (market_name) ->
        @marketTicker = MarketTicker.findBy('name', market_name)

      @getChangeValue = (market_name) ->
        @pervalue = MarketTicker.findBy('name', market_name)
        @changeval = 100-((@pervalue.low*100)/@pervalue.high)
        return @changeval


      @currencies = ->
        currs = []
        Currency.all().map((currency) ->
          if Market.findAllBy('bid_unit', currency.code).length > 0
            currs.push currency
        )

        return currs

    controllerAs: 'dashboardCtrl'
  }


