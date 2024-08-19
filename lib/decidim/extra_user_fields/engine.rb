# frozen_string_literal: true

require "rails"
require "decidim/core"
require "country_select"
require "deface"

module Decidim
  module ExtraUserFields
    # This is the engine that runs on the public interface of extra_user_fields.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ExtraUserFields

      DEFAULT_GENDER_OPTIONS = [:male, :female, :other].freeze
      DEFAULT_DOCUMENT_TYPE_OPTIONS = [:passport, :DNI, :RNE].freeze

      routes do
        # Add engine routes here
        # resources :extra_user_fields
        # root to: "extra_user_fields#index"
      end

      initializer "decidim_extra_user_fields.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_extra_user_fields.registration_additions" do
        config.to_prepare do
          Decidim::Verifications::PerformAuthorizationStep.class_eval do
            prepend Decidim::ExtraUserFields::PerformAuthorizationStepOverrides
          end

          Decidim::Verifications::IdDocuments::UploadForm.class_eval do
            include Decidim::ExtraUserFields::UploadFormOverrides
          end

          Decidim::Authorization.class_eval do
            prepend Decidim::ExtraUserFields::AuthorizationOverrides
          end

          Decidim::RegistrationForm.class_eval do
            include Decidim::ExtraUserFields::FormsDefinitions
          end

          Decidim::OmniauthRegistrationForm.class_eval do
            include Decidim::ExtraUserFields::FormsDefinitions
          end

          Decidim::AccountForm.class_eval do
            include Decidim::ExtraUserFields::FormsDefinitions
          end

          Decidim::CreateRegistration.class_eval do
            prepend Decidim::ExtraUserFields::CreateRegistrationsCommandsOverrides
          end

          Decidim::CreateOmniauthRegistration.class_eval do
            prepend Decidim::ExtraUserFields::OmniauthCommandsOverrides
          end

          Decidim::UpdateAccount.class_eval do
            prepend Decidim::ExtraUserFields::UpdateAccountCommandsOverrides
          end

          Decidim::Organization.class_eval do
            prepend Decidim::ExtraUserFields::OrganizationOverrides
          end

          Decidim::FormBuilder.class_eval do
            include Decidim::ExtraUserFields::FormBuilderMethods
          end

          Decidim::Verifications::DefaultActionAuthorizer.class_eval do
            prepend Decidim::ExtraUserFields::GovBrActionAuthorizer
          end
        end
      end
    end
  end
end
