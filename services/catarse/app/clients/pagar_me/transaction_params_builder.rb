# frozen_string_literal: true

module PagarMe
  class TransactionParamsBuilder
    attr_reader :payment, :user

    def initialize(payment:)
      @payment = payment
      @user = payment.user
    end

    def build
      case payment.payment_method
      when Billing::PaymentMethods::CREDIT_CARD
        build_credit_card_params
      when Billing::PaymentMethods::BOLETO
        build_boleto_params
      when Billing::PaymentMethods::PIX
        build_pix_params
      end
    end

    private

    def base_params
      {
        reference_key: payment.id,
        payment_method: payment.payment_method,
        amount: payment.total_amount_cents,
        async: false,
        postback_url: 'https://example.com'
      }
    end

    def build_credit_card_params
      base_params.merge(
        capture: false,
        card_id: 'card_123456789'
      )
    end

    def build_boleto_params
      # TODO: boleto expiration date calc
      # TODO: limit params characters length
      base_params.merge(
        boleto_rules: ['strict_expiration_date'],
        customer: build_customer_params
      )
    end

    def build_pix_params
      # TODO: pix expiration date calc
      base_params.merge(
        pix_expiration_date: 4.days.from_now.to_date.iso8601,
        customer: build_customer_params.merge(
          external_id: user.id.to_s,
          email: user.email,
          country: 'br',
          phone_numbers: [
            '+55085999999999'
          ]
        )
      )
    end

    def build_customer_params
      customer_type = user.account_type == 'pf' ? 'individual' : 'corporation'
      document_type = user.account_type == 'pf' ? 'cpf' : 'cnpj'

      {
        name: user.name,
        type: customer_type,
        documents: [
          {
            type: document_type,
            number: user.unformatted_document
          }
        ]
      }
    end
  end
end
