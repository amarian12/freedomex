class Currency extends PeatioModel.Model
  @configure 'Currency', 'id', 'code', 'isCoin', 'symbol'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        currency = Currency.create(record)

window.Currency = Currency
