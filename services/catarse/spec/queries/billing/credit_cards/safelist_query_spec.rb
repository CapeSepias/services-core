# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Billing::CreditCards::SafelistQuery, type: :query do
  subject(:query) { described_class.new }

  describe '#call' do
    let(:paid_credit_card) { create(:billing_credit_card) }

    before do
      create(:billing_payment, :paid, credit_card: paid_credit_card)

      not_paid_states = Billing::PaymentStateMachine.states - ['paid']
      not_paid_states.each do |state|
        credit_card = create(:billing_credit_card)
        create(:billing_payment, state: state, credit_card: credit_card)
      end
    end

    it 'returns credit cards used on paid payments' do
      expect(query.call).to eq [paid_credit_card]
    end
  end
end
