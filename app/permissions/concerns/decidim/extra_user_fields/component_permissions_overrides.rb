# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # This concern is meant to be included in al components that
    # foreign users participation must be authorized, i.e.
    # allowed or disallowed.
    #
    # See `enabled_for_foreign_users` setting
    module ComponentPermissionsOverrides
      extend ActiveSupport::Concern

      def permissions
        return super unless user && component_settings && space && space.organization.extra_user_fields_enabled?

        if !user.govbr? && !component_settings.try(:enabled_for_foreign_users) && permission_action.action.in?([:create, :update, :cancel, :destroy, :close, :register])
          disallow!
          return permission_action
        end

        super
      end
    end
  end
end
