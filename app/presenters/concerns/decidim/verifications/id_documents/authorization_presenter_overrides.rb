# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Verifications
    module IdDocuments
      module AuthorizationPresenterOverrides
        extend ActiveSupport::Concern

        # The SLA Deadline is meant to represent the target date
        # where authorization feedback is due.
        #
        def sla_deadline
          @sla_deadline ||= created_at + 72.hours
        end
      end
    end
  end
end
