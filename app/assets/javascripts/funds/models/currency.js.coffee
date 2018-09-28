class Currency extends PeatioModel.Model
  @configure 'Currency', 'id', 'coin', 'transaction_url_template', 'code', 'full_name'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        currency = Currency.create(record)

window.Currency = Currency
