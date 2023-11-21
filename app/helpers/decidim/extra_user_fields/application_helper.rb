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

      def registration_type_options_for_select
        Decidim::ExtraUserFields::Engine::DEFAULT_REGISTRATION_TYPE_OPTIONS.map do |registration_type|
          [registration_type, I18n.t(registration_type, scope: "decidim.extra_user_fields.registration_types")]
        end
      end

    end
  end
end
