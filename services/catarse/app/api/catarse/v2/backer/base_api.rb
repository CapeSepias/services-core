# frozen_string_literal: true

module Catarse
  module V2
    module Backer
      class BaseAPI < Grape::API
        namespace :backer do
          namespace :billing do
            mount Catarse::V2::Backer::Billing::CreditCardsAPI
            mount Catarse::V2::Backer::Billing::InstallmentSimulationsAPI
            mount Catarse::V2::Backer::Billing::PaymentsAPI
          end

          namespace :membership do
            mount Catarse::V2::Backer::Membership::SubscriptionsAPI
          end
        end
      end
    end
  end
end
