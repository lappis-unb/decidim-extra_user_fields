# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module UserOverrides
      def govbr?
        identities.any? { |identity| identity.provider.to_s.strip == "govbr" }
      end

      def verification_approved?
        Decidim::Authorization.where(user: self).where.not(granted_at: nil).present?
      end
    end
  end
end
