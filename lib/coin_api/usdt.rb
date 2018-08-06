# encoding: UTF-8
# frozen_string_literal: true

 module CoinAPI
  class USDT < BaseAPI
    def initialize(*)
      super
      @hot_wallet_address = currency.options['hot_wallet_address']
      @property_id = currency.options['property_id']
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint!)
    end

    def load_balance!
      load_balance_of_address @hot_wallet_address
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
      json_rpc(:omni_gettransaction, [normalize_txid(txid)]).fetch('result').yield_self { |tx| build_standalone_deposit(tx) }
    end

    def create_address!(options = {})
      { address: normalize_address(json_rpc(:getnewaddress).fetch('result')) }
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(:settxfee, [options[:fee]]) if options.key?(:fee)
      json_rpc(:omni_send, [@hot_wallet_address, normalize_address(recipient.fetch(:address)), @property_id, amount.to_s])
        .fetch('result')
        .yield_self(&method(:normalize_txid))
    end

    def inspect_address!(address)
      json_rpc(:validateaddress, [normalize_address(address)]).fetch('result').yield_self do |x|
        { address: normalize_address(address), is_valid: !!x['isvalid'] }
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
        { jsonrpc: '1.0', method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def each_batch_of_deposits(raise = true)
      offset    = 0
      collected = []
      max_block_number = latest_block_number
      loop do
        begin
          batch_deposits = nil
          response       = json_rpc(:omni_listtransactions, ["*", 100, offset, 0, max_block_number])
          offset        += 100
          batch_deposits = build_deposit_collection(response.fetch('result'))
        rescue => e
          report_exception(e)
          raise e if raise
        end
        yield batch_deposits if batch_deposits
        collected += batch_deposits
        break unless more_deposits_available?(batch_deposits)
      end
      collected
    end

    def build_standalone_deposit(tx)
      if tx['type_int'] == 0
        return unless tx['valid'] && tx['propertyid'] == @property_id && tx['amount'].to_d > 0
        { id:            normalize_txid(tx.fetch('txid')),
          confirmations: tx.fetch('confirmations').to_i,
          received_at:   Time.at(tx.fetch('blocktime')),
          entries:       [{ amount: tx.fetch('amount').to_d, address: normalize_address(tx.fetch('referenceaddress')) }] }
      elsif tx['type_int'] == 4
        return unless tx['valid']
        tx['subsends'].map do |subsend|
          return unless subsend['propertyid'] == @property_id && subsend['amount'].to_d > 0
          return { id:            normalize_txid(tx.fetch('txid')),
            confirmations: tx.fetch('confirmations').to_i,
            received_at:   Time.at(tx.fetch('blocktime')),
            entries:       [{ amount: subsend.fetch('amount').to_d, address: normalize_address(tx.fetch('referenceaddress')) }] }
        end
      end
    end

    def build_deposit_collection(txs)
      txs.map do |tx|
        if tx['type_int'] == 0
          next unless tx['valid'] && tx['propertyid'] == @property_id && tx['amount'].to_d > 0
          { id:            normalize_txid(tx.fetch('txid')),
            confirmations: tx.fetch('confirmations').to_i,
            received_at:   Time.at(tx.fetch('blocktime')),
            entries:       [{ amount: tx.fetch('amount').to_d, address: normalize_address(tx.fetch('referenceaddress')) }] }
        elsif tx['type_int'] == 4
          next unless tx['valid']
          tx['subsends'].map do |subsend|
            next unless subsend['propertyid'] == @property_id && subsend['amount'].to_d > 0
            { id:            normalize_txid(tx.fetch('txid')),
              confirmations: tx.fetch('confirmations').to_i,
              received_at:   Time.at(tx.fetch('blocktime')),
              entries:       [{ amount: subsend.fetch('amount').to_d, address: normalize_address(tx.fetch('referenceaddress')) }] }
          end.compact.reverse[0]
        end
      end.compact.reverse
    end

    def more_deposits_available?(batch_deposits)
      batch_deposits.present?
    end

    def latest_block_number
      json_rpc(:getblockcount).fetch('result')
    end

    def load_balance_of_address(address)
      json_rpc(:omni_getbalance, [normalize_address(address), @property_id]).fetch('balance').to_d
    rescue => e
      report_exception_to_screen(e)
      0.0
    end
  end
end
