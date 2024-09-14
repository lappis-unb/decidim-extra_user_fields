# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # This concern overrides Decidim::AuthorizationStatusCollection in order to
    # bypass the ordinary authorization verification for govbr users.
    #
    module AuthorizationStatusCollectionOverrides
      extend ActiveSupport::Concern

      def initialize(authorization_handlers, user, component, resource)
        @authorization_handlers = authorization_handlers

        # We prevent @statuses to be filled with the authorization handlers if
        # user is govbr. If @status is empty, user will always be authorized.
        #
        return if user.govbr?

        @statuses = authorization_handlers&.map do |name, opts|
          handler = Decidim::Verifications::Adapter.from_element(name)
          authorization = user ? Decidim::Verifications::Authorizations.new(organization: user.organization, user: user, name: name).first : nil
          status_code, data = handler.authorize(authorization, opts["options"], component, resource)
          Decidim::ActionAuthorizer::AuthorizationStatus.new(status_code, handler, data)
        end
      end
    end
  end
end
