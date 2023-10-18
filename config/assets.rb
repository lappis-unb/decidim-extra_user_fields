# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_path("#{base_path}/node_modules")
Decidim::Webpacker.register_entrypoints(
  decidim_forms: "#{base_path}/app/packs/entrypoints/extra_user_fields_validations.js",
)
