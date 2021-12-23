# frozen_string_literal: true

module Creator
  module Membership
    class BillingOptionEntity < BaseEntity
      expose :id
      expose :cadence_in_months
      expose :amount, using: MoneyEntity
      expose :enabled
    end
  end
end
