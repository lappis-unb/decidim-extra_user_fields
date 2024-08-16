# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module CreateRegistrationsCommandsOverrides
      extend ActiveSupport::Concern

      private

      def create_user
        @user = User.new(
          email: form.email,
          name: form.name,
          nickname: form.nickname,
          password: form.password,
          password_confirmation: form.password_confirmation,
          password_updated_at: Time.current,
          organization: form.current_organization,
          tos_agreement: form.tos_agreement,
          newsletter_notifications_at: form.newsletter_at,
          accepted_tos_version: form.current_organization.tos_version,
          locale: form.current_locale,
          extended_data: extended_data
        )
        @user.skip_confirmation_notification!
        @user.save!

        begin
          send_verification if form.document_type.present?
        rescue StandardError => e
          print e
        end
      end

      def send_verification
        @register_form = Decidim::Verifications::IdDocuments::UploadForm.new(user: @user).with_context(current_organization: form.current_organization)

        @register_form.verification_type = "online"
        @register_form.document_number = form.document_number
        @register_form.document_type = form.document_type
        @register_form.verification_attachment = form.document_image
        @register_form.second_verification_attachment = form.selfie_image

        @authorization = Decidim::Authorization.find_or_initialize_by(
          user: @user,
          name: "id_documents"
        )

        @authorization.verification_attachment = @register_form.verification_attachment

        Decidim::Verifications::PerformAuthorizationStep.call(@authorization, @register_form) do
          on(:ok) do
            flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.id_documents")
          end

          on(:invalid) do
            flash.now[:alert] = t("authorizations.create.error", scope: "decidim.verifications.id_documents")
          end
        end
      end

      def extended_data
        @extended_data ||= (@user&.extended_data || {}).merge(
          country: form.country,
          postal_code: form.postal_code,
          date_of_birth: form.date_of_birth,
          gender: form.gender,
          phone_number: form.phone_number,
          location: form.location,

          # Brasil Participativo form
          document_number: form.document_number,
          document_valid: form.document_valid,
          document_type: form.document_type
        )
      end
    end
  end
end
