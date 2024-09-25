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
        return super unless permission_action.scope == :public
        return super if user_might_be_allowed?

        disallow!
        permission_action
      end

      # If user is a govbr user, or they are a foreign user but verified, or even the action
      # is not a constructive/destructive action, then they should be verified against
      # the default permission
      #
      def user_might_be_allowed?
        user.govbr? ||
          !permission_action.action.in?([:create, :update, :cancel, :destroy, :close, :register]) ||
          (component_settings.try(:enabled_for_foreign_users) && user.verification_approved?)
      end
    end
  end
end
