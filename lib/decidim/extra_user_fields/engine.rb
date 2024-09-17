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

      initializer "decidim_extra_user_fields.components_permission" do
        Decidim.component_registry.find(:proposals).settings(:global) do |settings|
          settings.attribute :enabled_for_foreign_users, type: :boolean, default: false
        end

        Decidim.component_registry.find(:meetings).settings(:global) do |settings|
          settings.attribute :enabled_for_foreign_users, type: :boolean, default: false
        end

        Decidim.component_registry.find(:surveys).settings(:global) do |settings|
          settings.attribute :enabled_for_foreign_users, type: :boolean, default: false
        end
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

          # This is commented because it is not intended to have the extra user
          # information in omniauth sign in/up strategy
          #
          # Decidim::OmniauthRegistrationForm.class_eval do
          #   include Decidim::ExtraUserFields::FormsDefinitions
          # end

          # This is commented because extra fields are not meant to be displayed
          # in user profile page, or manipulated after sign up
          #
          # Decidim::AccountForm.class_eval do
          #   include Decidim::ExtraUserFields::FormsDefinitions
          # end

          Decidim::CreateRegistration.class_eval do
            prepend Decidim::ExtraUserFields::CreateRegistrationsCommandsOverrides
          end

          # This is commented because it is not intended to have the extra user
          # information in omniauth sign in/up strategy
          #
          # Decidim::CreateOmniauthRegistration.class_eval do
          #   prepend Decidim::ExtraUserFields::OmniauthCommandsOverrides
          # end

          # This is commented because extra fields are not meant to be displayed
          # in user profile page, or manipulated after sign up
          #
          # Decidim::UpdateAccount.class_eval do
          #   prepend Decidim::ExtraUserFields::UpdateAccountCommandsOverrides
          # end

          Decidim::Organization.class_eval do
            prepend Decidim::ExtraUserFields::OrganizationOverrides
          end

          Decidim::FormBuilder.class_eval do
            include Decidim::ExtraUserFields::FormBuilderMethods
          end

          Decidim::Verifications::DefaultActionAuthorizer.class_eval do
            prepend Decidim::ExtraUserFields::GovBrActionAuthorizer
          end

          Decidim::Verifications::IdDocuments::Admin::PendingAuthorizationsController.class_eval do
            prepend Decidim::ExtraUserFields::PendingAuthorizationsControllerOverrides
          end

          Decidim::Verifications::IdDocuments::AuthorizationPresenter.class_eval do
            include Decidim::Verifications::IdDocuments::AuthorizationPresenterOverrides
          end

          Decidim::Verifications::IdDocuments::AuthorizationsController.class_eval do
            prepend Decidim::ExtraUserFields::AuthorizationControllerOverrides
          end

          Decidim::User.class_eval do
            include Decidim::ExtraUserFields::UserOverrides
          end

          Decidim::ActionAuthorizer::AuthorizationStatusCollection.class_eval do
            prepend Decidim::ExtraUserFields::AuthorizationStatusCollectionOverrides
          end
        end
      end
    end
  end
end
