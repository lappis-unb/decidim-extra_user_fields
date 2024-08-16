# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Extra user fields definitions for forms
    module FormsDefinitions
      extend ActiveSupport::Concern

      included do
        include ::Decidim::ExtraUserFields::ApplicationHelper

        # Block ExtraUserFields Attributes

        attribute :country, String
        attribute :postal_code, String
        attribute :date_of_birth, Decidim::Attributes::LocalizedDate
        attribute :gender, String
        attribute :phone_number, String
        attribute :location, String

        # Brasil Participativo Attributes
        attribute :selfie_image, Decidim::Attributes::Blob
        attribute :document_image, Decidim::Attributes::Blob
        attribute :document_number, String
        attribute :document_valid, String
        attribute :document_type, String

        # EndBlock

        # Block ExtraUserFields Validations

        validates :country, presence: true, if: :country?
        validates :postal_code, presence: true, if: :postal_code?
        validates :date_of_birth, presence: true, if: :date_of_birth?
        validates :gender, presence: true, inclusion: { in: Decidim::ExtraUserFields::Engine::DEFAULT_GENDER_OPTIONS.map(&:to_s) }, if: :gender?
        validates :phone_number, presence: true, if: :phone_number?
        validates :location, presence: true, if: :location?

        # Brasil participativo Validations
        validates :document_number, presence: true, if: :document_number?
        validates :selfie_image, presence: true, if: :selfie_image?
        validates :document_image, presence: true, if: :document_image?
        validates :document_valid, presence: true, if: :document_valid?
        validates :document_type, presence: true, inclusion: { in: Decidim::ExtraUserFields::Engine::DEFAULT_DOCUMENT_TYPE_OPTIONS.map(&:to_s) }, if: :document_type?

        # EndBlock
      end

      def map_model(model)
        extended_data = model.extended_data.with_indifferent_access

        self.country = extended_data[:country]
        self.postal_code = extended_data[:postal_code]
        self.date_of_birth = Date.parse(extended_data[:date_of_birth]) if extended_data[:date_of_birth].present?
        self.gender = extended_data[:gender]
        self.phone_number = extended_data[:phone_number]
        self.location = extended_data[:location]

        # Block ExtraUserFields MapModel

        self.selfie_image = extended_data[:selfie_image]
        self.document_number = extended_data[:document_number]
        self.document_image = extended_data[:document_image]
        self.document_valid = extended_data[:document_valid]
        self.document_type = extended_data[:document_type]

        # EndBlock
      end

      private

      # Block ExtraUserFields EnableFieldMethod
      def country?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:country)
      end

      def date_of_birth?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:date_of_birth)
      end

      def gender?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:gender)
      end

      def postal_code?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:postal_code)
      end

      def phone_number?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:phone_number)
      end

      def location?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:location)
      end

      def selfie_image?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:selfie_image)
      end

      def document_image?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:document_image)
      end

      def document_number?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:document_number)
      end

      def document_valid?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:document_valid)
      end

      def document_type?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:document_type)
      end

      # EndBlock

      def extra_user_fields_enabled
        @extra_user_fields_enabled ||= current_organization.extra_user_fields_enabled?
      end
    end
  end
end
