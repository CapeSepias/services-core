# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Membership::BillingOption, type: :model do
  describe 'Relations' do
    it { is_expected.to belong_to(:tier).class_name('Membership::Tier') }

    it { is_expected.to have_one(:project).through(:tier) }
  end

  describe 'Validations' do
    it do
      billing_option = create(:membership_billing_option)
      expect(billing_option).to validate_uniqueness_of(:cadence_in_months).scoped_to(:tier_id)
    end

    it { is_expected.to validate_numericality_of(:cadence_in_months).is_equal_to(1).only_integer }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(1) }
  end
end