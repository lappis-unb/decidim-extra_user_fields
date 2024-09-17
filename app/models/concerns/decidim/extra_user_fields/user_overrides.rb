# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module UserOverrides
      def govbr?
        identities.any? { |identity| identity.provider.to_s.strip == "govbr" }
      end
    end
  end
end
