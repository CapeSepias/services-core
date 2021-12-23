# frozen_string_literal: true

module Catarse
  module V2
    module Creator
      class BaseAPI < Grape::API
        namespace :creator do
          namespace :membership do
            mount Catarse::V2::Creator::Membership::BillingOptionsAPI
            mount Catarse::V2::Creator::Membership::TiersAPI
          end
        end
      end
    end
  end
end
