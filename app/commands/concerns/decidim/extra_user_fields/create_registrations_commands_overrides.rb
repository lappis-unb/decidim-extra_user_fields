# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module CreateRegistrationsCommandsOverrides
      extend ActiveSupport::Concern  
 
      private

      def create_user
        document_image = extended_data[:document_image]
        file = extended_data[:document_image].tempfile
        filename = extended_data[:document_image].original_filename
        @user = User.create!(
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
          # if document type -> adicionar a verification apenas se existir o campo document_type
          #controller = Verifications::IdDocuments::AuthorizationsController.new(current_user: @user, using_online?: true)
          #@authorization = Decidim::Verifications::IdDocuments::AuthorizationsController.new
          
          @user.extended_data["document_image"].delete("headers")
          @user.extended_data["document_image"].delete("tempfile")
          @user.extended_data["document_image"].delete("original_filename")

          #@image = {"io" => file, "filename" => filename}
          #@image = {"io" => @user.extended_data["document_image"]["tempfile"], "filename" => @user.extended_data["document_image"]["filename_original"]}
          
          @form = Decidim::Verifications::IdDocuments::UploadForm.new(user: @user).with_context(current_organization:form.current_organization)
          @form.verification_type = "online"
          @form.document_number = @user.extended_data["document_number"]
          @form.document_type = @user.extended_data["document_type"]
          #@form.verification_attachment["document_type"] = @user.extended_data["document_image"]["document_type"]
          @form.verification_attachment = @user.extended_data["document_image"]
          @form.verification_attachment["io"] = file
          @form.verification_attachment["filename"] = filename
          
          @authorization = Decidim::Authorization.find_or_initialize_by(
            user: @user,
            name: "id_documents"
          )

          @authorization.verification_attachment = @user.extended_data["document_image"]
          #@authorization.verification_attachment["io"] = file
          #@authorization.verification_attachment["filename"] = filename

          Decidim::Verifications::PerformAuthorizationStep.call(@authorization, @form) do
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
          document_image: form.document_image,
          document_number: form.document_number,
          document_valid: form.document_valid,
          document_type: form.document_type
        )
      end
    end
  end
end
