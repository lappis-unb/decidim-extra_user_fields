# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    module UploadFormOverrides
      extend ActiveSupport::Concern

      included do
        attribute :second_verification_attachment
      end
    end
  end
end
