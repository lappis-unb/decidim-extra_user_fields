# frozen_string_literal: true

Decidim::Verifications.register_workflow(:id_documents) do |workflow|
  workflow.action_authorizer = "Decidim::Verifications::IdDocuments::ActionAuthorizer"
end
