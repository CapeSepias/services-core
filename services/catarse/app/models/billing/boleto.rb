# frozen_string_literal: true

module Billing
  class Boleto < ApplicationRecord
    belongs_to :payment, class_name: 'Billing::Payment'

    validates :payment_id, presence: true
    validates :barcode, presence: true
    validates :url, presence: true
    # TODO: Check attribute type. Investigate if expires at is date or datetime
    validates :expires_at, presence: true
  end
end