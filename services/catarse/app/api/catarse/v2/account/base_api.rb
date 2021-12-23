# frozen_string_literal: true

module Catarse
  module V2
    module Account
      class BaseAPI < Grape::API
        namespace :account do
          mount Catarse::V2::Account::AuthTokensAPI
        end
      end
    end
  end
end
