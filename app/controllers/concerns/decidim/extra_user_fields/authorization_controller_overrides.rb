# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    module AuthorizationControllerOverrides
      def update
        enforce_permission_to :update, :authorization, authorization: @authorization

        @form = Decidim::Verifications::IdDocuments::UploadForm.from_params(
          params.merge(
            user: current_user,
            verification_type: verification_type,
            verification_attachment: params[:id_document_upload][:verification_attachment] || @authorization.verification_attachment.blob,
            second_verification_attachment: params[:id_document_upload][:second_verification_attachment] || @authorization.try(:second_verification_attachment).try(:blob)
          )
        ).with_context(current_organization: current_organization)

        Decidim::Verifications::PerformAuthorizationStep.call(@authorization, @form) do
          on(:ok) do
            flash[:notice] = t("authorizations.update.success", scope: "decidim.verifications.id_documents")
            redirect_to decidim_verifications.authorizations_path
          end

          on(:invalid) do
            flash[:alert] = t("authorizations.update.error", scope: "decidim.verifications.id_documents")
            render action: :edit
          end
        end
      end
    end
  end
end
