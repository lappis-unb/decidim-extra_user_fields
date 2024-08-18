# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    module PerformAuthorizationStepOverrides
      protected

      def update_verification_data
        authorization.attributes = {
          unique_id: handler.unique_id,
          metadata: handler.metadata,
          verification_metadata: handler.verification_metadata,
          verification_attachment: handler.verification_attachment,
          second_verification_attachment: handler.try(:second_verification_attachment)
        }

        authorization.save!
      end
    end
  end
end
