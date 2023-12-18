# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Custom helpers, scoped to the extra_user_fields engine.
    #
    module ApplicationHelper
      def gender_options_for_select
        Decidim::ExtraUserFields::Engine::DEFAULT_GENDER_OPTIONS.map do |gender|
          [gender, I18n.t(gender, scope: "decidim.extra_user_fields.genders")]
        end
      end

      def document_type_options_for_select
        Decidim::ExtraUserFields::Engine::DEFAULT_DOCUMENT_TYPE_OPTIONS.map do |document_type|
          [document_type, I18n.t(document_type, scope: "decidim.extra_user_fields.document_types")]
        end
      end

    end
  end
end
