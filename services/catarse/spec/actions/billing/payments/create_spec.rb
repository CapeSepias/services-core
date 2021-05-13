# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Billing::Payments::Create, type: :action do
  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to include(user: { type: User }) }
    it { is_expected.to include(attributes: { type: Hash }) }
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to include(payment: { type: Billing::Payment }) }
  end

  describe '#call' do
    subject(:result) { described_class.result(user: user, attributes: attributes) }

    let(:user) { create(:user) }
    let(:payment) { build(:billing_payment, user: user, billing_address: create(:shared_address)) }
    let(:attributes) { Hash[*Faker::Lorem.words(number: 8)] }
    let(:payment_builder) { instance_double(Billing::PaymentBuilder) }

    before do
      allow(Billing::PaymentBuilder).to receive(:new).and_return(payment_builder)
      allow(payment_builder).to receive(:build).and_return(payment)
    end

    it 'builds payment with Billing::PaymentBuilder' do
      expect(result.payment).to equal(payment)
    end

    context 'when built payment is valid' do
      it { is_expected.to be_success }

      it 'saves payment' do
        expect(result.payment).to be_persisted
      end
    end

    context 'when built payment is invalid' do
      before { payment.user = nil }

      it 'raises error' do
        expect { result }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'rollbacks transaction' do
        expect do
          result
        rescue ActiveRecord::RecordInvalid
          # do nothing
        end.not_to change(Shared::Address, :count)
      end
    end

    # it { is_expected.to be_success }

    # it 'replicates billing address' do
    #   original_address = Shared::Address.find(attributes[:billing_address_id])
    #   address_replica = Shared::Address.where.not(id: original_address.id).find(result.payment.billing_address_id)

    #   expect(address_replica.attributes).to include(
    #     original_address.attributes.except('updated_at', 'created_at', 'id')
    #   )
    # end

    # context 'when shipping address is present' do
    #   before { attributes[:shipping_address_id] = create(:shared_address).id }

    #   it 'replicates shipping address' do
    #     original_address = Shared::Address.find(attributes[:shipping_address_id])
    #     address_replica = Shared::Address.where.not(id: original_address.id).find(result.payment.shipping_address_id)

    #     expect(address_replica.attributes).to include(
    #       original_address.attributes.except('updated_at', 'created_at', 'id')
    #     )
    #   end
    # end

    # context 'when shipping address isn`t present' do
    #   before { attributes[:shipping_address_id] = nil }

    #   it 'doesn`t duplicate shipping address' do
    #     expect(result.payment.shipping_address_id).to eq(nil)
    #   end
    # end

    # it 'creates payment' do
    #   expect(result.payment.reload.attributes).to include(
    #     'user_id' => user.id,
    #     'payment_method' => attributes[:payment_method],
    #     'gateway' => attributes[:gateway],
    #     'billing_address_id' => attributes[:billing_address_id],
    #     'state' => Billing::PaymentStateMachine.initial_state,
    #     'amount_cents' => result.payment.items.sum(:amount_cents),
    #     'shipping_fee_cents' => result.payment.items.sum(&:shipping_fee_cents),
    #     'total_amount_cents' => result.payment.items.sum(:total_amount_cents)
    #   )
    # end

    # it 'creates first payment item' do
    #   created_payment = result.payment

    #   payment_item_a = created_payment.items.find_by!(payable: contribution_a)

    #   amount_cents = (contribution_a.value * 100).to_i
    #   shipping_fee_cents = (contribution_a.shipping_fee.value.to_f * 100).to_i

    #   expect(payment_item_a.attributes).to include(
    #     'amount_cents' => amount_cents,
    #     'shipping_fee_cents' => shipping_fee_cents,
    #     'total_amount_cents' => amount_cents + shipping_fee_cents,
    #     'state' => Billing::PaymentItemStateMachine.initial_state
    #   )
    # end

    # it 'creates second payment item' do
    #   created_payment = result.payment

    #   payment_item_a = created_payment.items.find_by!(payable: contribution_b)

    #   amount_cents = (contribution_b.value * 100).to_i

    #   expect(payment_item_a.attributes).to include(
    #     'amount_cents' => amount_cents,
    #     'shipping_fee_cents' => 0,
    #     'total_amount_cents' => amount_cents,
    #     'state' => Billing::PaymentItemStateMachine.initial_state
    #   )
    # end
  end
end
