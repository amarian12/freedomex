app.directive 'priceheader', ->
  return {
    restrict: 'E'
    templateUrl: '/templates/dashboard/header.html'
    scope: { localValue: '=marketTicker' }
    controller: ($scope, $state) ->
      ctrl = @
      @state = $state

      $scope.markets = Market.all()

    controllerAs: 'priceheaderCtrl'
  }


