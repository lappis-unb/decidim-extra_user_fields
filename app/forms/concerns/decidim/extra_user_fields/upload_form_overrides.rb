# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    module UploadFormOverrides
      extend ActiveSupport::Concern

      included do
        attribute :second_verification_attachment

        validates :second_verification_attachment,
                  presence: true,
                  if: :uses_online_method?
      end
    end
  end
end
