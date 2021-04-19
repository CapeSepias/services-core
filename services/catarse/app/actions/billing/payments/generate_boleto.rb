# frozen_string_literal: true

module Billing
  module Payments
    class GenerateBoleto < Actor
      include Helpers::ErrorHandler

      input :payment, type: Billing::Payment
      input :pagarme_client, type: PagarMe::Client, default: -> { PagarMe::Client.new }

      def call
        # TODO: check if payment method is boleto
        response = pagarme_client.create_transaction(transaction_params)

        if response['status'] == 'waiting_payment'
          payment.transition_to!(:waiting_payment, response)
          payment.update!(gateway: 'pagarme', gateway_id: response['id'])
          create_boleto(response)
        else
          handle_fatal_error('Invalid gateway request',
            { data: response, payment_id: payment.id, user_id: payment.user_id }
          )
        end
      end

      private

      def transaction_params
        PagarMe::TransactionParamsBuilder.new(payment: payment).build
      end

      def create_boleto(response)
        payment.create_boleto!(
          barcode: response['boleto_barcode'],
          url: response['boleto_url'],
          expires_at: response['boleto_expiration_date'].to_datetime
        )
      end
    end
  end
end
