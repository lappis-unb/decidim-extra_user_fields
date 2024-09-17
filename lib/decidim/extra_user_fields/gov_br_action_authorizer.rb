# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module GovBrActionAuthorizer
      def component_permitted_for_foreign_user?
        @component.settings.try(:enabled_for_foreign_users)
      end

      def authorize
        if !authorization
          [:missing, { action: :authorize }]
        elsif authorization_expired?
          [:expired, { action: :authorize }]
        elsif !authorization.granted?
          [:pending, { action: :resume }]
        elsif unmatched_fields.any?
          [:unauthorized, { fields: unmatched_fields }]
        elsif missing_fields.any?
          [:incomplete, { fields: missing_fields, action: :reauthorize, cancel: true }]
        elsif !component_permitted_for_foreign_user?
          [:forbidden, {}]
        else
          [:ok, {}]
        end
      end
    end
  end
end
