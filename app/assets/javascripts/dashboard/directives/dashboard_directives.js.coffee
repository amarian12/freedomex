app.directive 'dashboard', ->
  return {
    restrict: 'E'
    templateUrl: '/templates/dashboard/dashboard_tables.html'
    scope: { localValue: '=marketTicker' }
    controller: ($scope, $state) ->
      ctrl = @
      @state = $state
      #if window.location.hash == ""
      #  @state.transitionTo("deposits.currency", {currency: Account.first().currency})

      @currencies = ->
        currs = []
        Currency.all().map((currency) ->
          if Market.findAllBy('bid_unit', currency.code).length > 0
            currs.push currency
        )
        return currs

      $scope.currencies = Currency.all()
      $scope.accounts = Account.all()
      $scope.markets = Market.all()
      $scope.marketTickers = MarketTicker.all()

      @marketTicker = null
      $scope.marketTicker = @marketTicker

      @selectedCurrency = null

      @changeCurrency = (currency_code) ->
        return ctrl.selectedCurrency = currency_code

      @itterationMarkets = []

      @ifMarketsPresent = (currency_code) ->
        ctrl.itterationMarkets = Market.findAllBy('bid_unit', currency_code)
        ctrl.itterationMarkets.length > 0

      @marketValues = {}
      @setMarketValues = (market_name) ->
        ctrl.marketValues.marketTicker = MarketTicker.findBy('name', market_name)
        ctrl.marketValues.marketChange = ctrl.getChangeValue(market_name)

      @getChangeValue = (market_name) ->
        market = MarketTicker.findBy('name', market_name)
        p1 = parseFloat market.open
        p2 = parseFloat market.last
        ctrl.price_change(p1,p2)

      @price_change = (p1, p2) ->
        percent = if p1
                    Math.round((100*(p2-p1)/p1) * 100) / 100
                  else
                    '0'

      do @event = ->
        MarketTicker.bind "create update destroy", ->
          @marketTickers = MarketTicker.all()
          $scope.$apply()
          true

    controllerAs: 'dashboardCtrl'
  }


