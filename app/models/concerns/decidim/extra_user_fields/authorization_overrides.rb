# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    module AuthorizationOverrides
      extend ActiveSupport::Concern

      prepended do
        has_one_attached :second_verification_attachment
      end

      def grant!
        update!(granted_at: Time.current, verification_metadata: {}, verification_attachment: nil, second_verification_attachment: nil)
      end
    end
  end
end
