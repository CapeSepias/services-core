# frozen_string_literal: true

module Account
  module AuthTokens
    class Generate < Actor
      input :attributes, type: Hash

      output :auth_token, type: String

      def call
        user = User.find_by(email: attributes['email'])

        fail!(error: 'E-mail or password is invalid') unless user.try(:valid_password?, attributes['password'])

        self.auth_token = Account::AuthToken.encode(payload: { user_id: user.id }, expires_at: 1.hour.from_now)
      end
    end
  end
end
