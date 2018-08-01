# encoding: UTF-8
# frozen_string_literal: true

module CoinAPI
  class STEEM < BaseAPI
    def initialize(*)
      super
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint!)
    end

    def load_balance!
      json_rpc(:get_account, ["aaa"]).fetch('result')["balance"].to_d
    end

    def each_deposit!(options = {})
      each_batch_of_deposits do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def each_deposit(options = {})
      each_batch_of_deposits false do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def load_deposit!(txid)
      json_rpc(:get_transaction, [normalize_txid(txid)]).fetch('result').yield_self do |tx|
        { id:            normalize_txid(tx.fetch('transaction_id')),
          confirmations: 1,
          received_at:   Time.parse(tx.fetch('expiration')),
          entries:       [{ amount:  tx.fetch('operations')[0][1].fetch('amount').to_d,
                            address: normalize_address(tx.fetch('operations')[0][1].fetch('memo')) }] }
      end                          
    end

    def create_address!(options = {})
      puts '--------------STEEM create_address-----------'
      { address: normalize_address(SecureRandom.uuid) }
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(:transfer, ["freedom-exchange", normalize_address(recipient.fetch(:address)), convert_amount(amount), "FreedomExchange withdraw opeartion", true])
        .fetch('result').fetch('transaction_id')
        .yield_self(&method(:normalize_txid))
    end

    def inspect_address!(address)
      json_rpc(:get_account, [normalize_address(address)]).fetch('result').yield_self do |x|
        { address: normalize_address(address), is_valid: !!x['id'] }
      end
    end

  protected

    def connection
      Faraday.new(@json_rpc_endpoint).tap do |connection|
        unless @json_rpc_endpoint.user.blank?
          connection.basic_auth(@json_rpc_endpoint.user, @json_rpc_endpoint.password)
        end
      end
    end
    memoize :connection

    def json_rpc(method, params = [])
      response = connection.post \
        '/',
        { jsonrpc: '2.0', method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def each_batch_of_deposits(raise = true)
      # offset    = 0
      collected = []
      begin
        batch_deposits = nil
        response       = json_rpc(:get_account_history, ["freedom-exchange", -1, 10])
        # offset        += 100
        batch_deposits = build_deposit_collection(response.fetch('result'))
      rescue => e
        report_exception(e)
        raise e if raise
      end
      yield batch_deposits if batch_deposits && block_given?
      collected += batch_deposits
      collected
    end

    def build_deposit_collection(txs)
      txs.map do |tx|
        txd = tx[1]
        txop = txd.fetch('op')[1]
        next unless txd.fetch('op')[0] == 'transfer' && txop.fetch('memo') != '' && txop.fetch('to') == 'freedom-exchange'  # to replace with ENV
        { id:            normalize_txid(txd.fetch('trx_id')),
          confirmations: 1,
          received_at:   Time.parse(txd.fetch('timestamp')),
          entries:       [{ amount: txop.fetch('amount').to_d, address: normalize_address(txop.fetch('memo')) }] }
      end.compact.reverse
    end

    def more_deposits_available?(batch_deposits)
      batch_deposits.present?
    end

    def convert_amount(amount)
      "%.3f STEEM" % [amount]
    end
  end
end
