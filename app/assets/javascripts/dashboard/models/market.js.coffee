class Market extends PeatioModel.Model
  @configure 'Market', 'id', 'name', 'enabled',
                       'ask_unit', 'bid_unit', 'ask_fee', 'bid_fee',
                       'ask_precision', 'bid_precision',
                       'position', 'created_at', 'updated_at'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Market.create(record)

window.Market = Market


class MarketTicker extends PeatioModel.Model
  @configure 'MarketTicker', 'name', 'open',
                             'quote_unit', 'base_unit', 'high', 'low',
                             'buy', 'sell', 'volume', 'last', 'at'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        MarketTicker.create(record)

  @updateData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        MarketTicker.findBy('name', record.name).updateAttributes(record)

window.MarketTicker = MarketTicker

