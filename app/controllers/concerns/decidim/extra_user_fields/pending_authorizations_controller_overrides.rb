# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    module PendingAuthorizationsControllerOverrides
      extend ActiveSupport::Concern

      # We need to override it in order to return an AuthorizationPresenter
      # instead of an ordinary Authorization. An AuthorizationPresenter is
      # an Authorization but with methods that cover SLA status
      #
      def pending_online_authorizations
        Decidim::Verifications::Authorizations
          .new(organization: current_organization, name: "id_documents", granted: false)
          .query
          .where("verification_metadata->'rejected' IS NULL")
          .order(created_at: :asc)
          .select { |auth| auth.verification_metadata["verification_type"] == "online" }
          .map { |auth| Decidim::Verifications::IdDocuments::AuthorizationPresenter.new(auth) }
      end
    end
  end
end
