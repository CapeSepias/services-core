# frozen_string_literal: true

module Membership
  class Tier < ApplicationRecord
    belongs_to :project

    has_many :billing_options, class_name: 'Membership::BillingOption', dependent: :destroy
    has_many :subscriptions, class_name: 'Membership::Subscription', dependent: :destroy

    validates :name, presence: true
    validates :description, presence: true

    validates :name, length: { maximum: 512 }
    validates :description, length: { maximum: 16_000 }

    validates :subscribers_limit, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
    validates :order, numericality: { only_integer: true }

    before_validation :fill_order, on: :create

    private

    def fill_order
      return if order.present?

      self.order = self.class.where(project_id: project_id).maximum(:order).to_i + 1
    end
  end
end
