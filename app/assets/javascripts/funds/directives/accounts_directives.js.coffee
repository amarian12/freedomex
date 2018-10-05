app.directive 'accounts', ->
  return {
    restrict: 'E'
    #templateUrl: '/templates/funds/accounts.html'
    templateUrl: '/templates/funds/funds_account.html'
    scope: { localValue: '=accounts' }
    controller: ($scope, $state, ngDialog) ->
      ctrl = @
      @state = $state
      if window.location.hash == ""
        @state.transitionTo("deposits.currency", {currency: Account.first().currency})

      $scope.accounts       = Account.all()
      $scope.filterAccounts = () ->
        if (event.target.value && event.target.value.replace(/\s/g, "").length > 0)
          $scope.accounts   = Account.all().filter (account) ->
                                return account.currency.includes event.target.value.toLowerCase()
        else
          $scope.accounts   = Account.all()

      @selectedCurrency     = window.location.hash.split('/')[2] || Account.first().currency
      @currentAction        = window.location.hash.split('/')[1] || 'deposits'
      $scope.currency       = @selectedCurrency
      $scope.markets        = Market.all()
      $scope.marketTickers  = MarketTicker.all()
      $scope.currencyLogoStyles = (account) ->
        'background-image': "url('#{account.currency_icon_url}')"

      @isSelected = (currency) ->
        @selectedCurrency == currency

      $scope.currencyName = ""
      $scope.totalValue = "0.0"
      $scope.pendingDeposit = "0.0"
      $scope.accountMarket = {}
      $scope.marketName = ""
      $scope.marketTicker = {}
      @setAccountMarket = (account) ->
        $scope.currencyName     = account.currency_name()
        $scope.accountMarket    = Market.findBy('bid_unit', account.currency) || Market.findBy('ask_unit', account.currency) || {}
        $scope.marketName       = $scope.accountMarket.id
        $scope.marketTicker     = MarketTicker.findBy('name', $scope.accountMarket.name)
        $scope.totalValue       = (parseFloat(account.balance) + parseFloat(account.locked)).toFixed(4)
        $scope.pendingDeposit   = ctrl.pendingDeposit account

      @pendingDeposit = (account) ->
        deposits = Deposit.filterByState(account.currency, 'submitted'); amount = 0.0; j = 0; len = deposits.length
        while j < len
          record = deposits[j]; amount += parseFloat(record.amount); j++
        return amount.toFixed(2)


      @filterAccounts = (filterString) ->
        return true


      @isDeposit = ->
        @currentAction == 'deposits'

      @isWithdraw = ->
        @currentAction == 'withdraws'

      @deposit = (account) ->
        ctrl.state.transitionTo("deposits.currency", {currency: account.currency})
        ctrl.selectedCurrency = account.currency
        ctrl.currentAction = "deposits"
        ctrl.openModal 'DepositsController', 'deposit'

      @withdraw = (account) ->
        ctrl.state.transitionTo("withdraws.currency", {currency: account.currency})
        ctrl.selectedCurrency = account.currency
        ctrl.currentAction    = "withdraws"
        ctrl.openModal 'WithdrawsController', 'withdraw'

      @openModal = (dialogueType, actionType) ->
        ngDialog.open
          template: '/templates/funds/'+actionType+'.html'
          controller: dialogueType
          className: 'ngdialog-theme-default custom-width'
          data: {actionType: ctrl.currentAction}

      do @event = ->
        Account.bind "create update destroy", ->
          $scope.$apply()

    controllerAs: 'accountsCtrl'
  }

