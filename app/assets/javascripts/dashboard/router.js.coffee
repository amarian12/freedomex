app.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
    .state('dashboard', {
      url: '/dashboard'
      templateUrl: "/templates/dashboard/dashboard_tables.html"
    })

