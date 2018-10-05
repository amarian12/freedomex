class Deposit extends PeatioModel.Model
  @configure 'Deposit', 'member_id', 'currency', 'amount', 'fee', 'address', 'txid', 'aasm_state', 'created_at', 'updated_at', 'completed_at', 'type', 'confirmations', 'transaction_url'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Deposit.create(record)

  @filterByState = (currency, aasm_state) ->
    ref = @findAllBy('currency', currency)
    records = []
    j = 0
    len = ref.length
    while j < len
      record = ref[j]
      if record.aasm_state == aasm_state
        records.push record.clone()
      j++
    return records

window.Deposit = Deposit



