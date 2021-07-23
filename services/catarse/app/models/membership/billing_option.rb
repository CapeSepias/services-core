# frozen_string_literal: true

module Membership
  class BillingOption < ApplicationRecord
    belongs_to :tier, class_name: 'Membership::Tier'

    has_one :project, through: :tier

    monetize :amount_cents, numericality: { greater_than_or_equal_to: 1 }

    validates :cadence_in_months, uniqueness: { scope: :tier_id }

    validates :cadence_in_months, numericality: { equal_to: 1, only_integer: true }
  end
end