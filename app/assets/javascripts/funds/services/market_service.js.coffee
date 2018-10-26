app.service 'marketService', ['$filter', '$gon', ($filter, $gon) ->

  filterBy: (filter) ->
    $filter('filter')($gon.markets, filter)

  findBy: (filter) ->
    result = @filterBy filter
    if result.length then result[0] else null

]
app.service 'marketTickerService', ['$filter', '$gon', ($filter, $gon) ->

  filterBy: (filter) ->
    $filter('filter')($gon.tickers, filter)

  findBy: (filter) ->
    result = @filterBy filter
    if result.length then result[0] else null

]
