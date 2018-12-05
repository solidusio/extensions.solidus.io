$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'solidus_extensions'
require 'pry'

Travis.access_token = ENV['TRAVIS_TOKEN']

OLD_VERSIONS = %W[v1.0 v1.1 v1.2 v1.3 v1.4 v2.0 v2.1 v2.2]
VERSIONS = %W[v1.0 v1.1 v1.2 v1.3 v1.4 v2.0 v2.1 v2.2 v2.3 v2.4 v2.5 v2.6 v2.7 master]
PROJECTS = {
  # Auth
  'solidusio/solidus_auth_devise'                   => %w[master],
  'solidusio-contrib/solidus_social'                => %w[master],
  'boomerdigital/solidus_user_roles'                => %w[master],

  # Payments
  'solidusio/solidus_gateway'                       => %w[master],
  'solidusio-contrib/solidus_stripe'                => %w[master],
  'solidusio/solidus_braintree'                     => %w[master],
  'solidusio/solidus_paypal_braintree'              => %w[master],
  'solidusio-contrib/solidus_affirm'                => %w[master],
  'solidusio/solidus_signifyd'                      => %w[master],
  'boomerdigital/solidus_amazon_payments'           => %w[master],
  'solidusio-contrib/solidus_subscriptions'         => %w[master],

  # Shipping
  'solidusio-contrib/solidus_easypost'              => %w[master],
  'solidusio-contrib/solidus_active_shipping'       => %w[master],
  'boomerdigital/solidus_shipstation'               => %w[master],

  # I18n
  'solidusio/solidus_i18n'                          => %w[master],
  'solidusio-contrib/solidus_globalize'             => %w[master],

  # Taxes
  'solidusio/solidus_avatax'                        => %w[master],
  'boomerdigital/solidus_avatax_certified'          => %w[master v2.1],

  # Marketplace
  'solidusio/solidus_multi_domain'                  => %w[master],

  # Product/Variant Customization
  'solidusio/solidus_asset_variant_options'         => %w[master],
  'solidusio-contrib/solidus_related_products'      => %w[master],
  'solidusio-contrib/solidus_product_assembly'      => %w[master],
  'solidusio-contrib/solidus_editor'                => %w[master],
  'boomerdigital/solidus_email_to_friend'           => %w[master],
  'boomerdigital/solidus_flexi_variants'            => %w[master],

  # Search
  'boomerdigital/solidus_elastic_product'           => %w[master],

  # Marketing
  'solidusio-contrib/solidus_product_feed'          => %w[master],
  'solidusio-contrib/solidus_sitemap'               => %w[master],
  'solidusio-contrib/solidus_trackers'              => %w[master],

  # Promo
  'solidusio-contrib/solidus_volume_pricing'        => %w[master],
  'boomerdigital/solidus_wishlist'                  => %w[master],

  # Admin
  'solidusio-contrib/solidus_prototypes'            => %w[master],
  'solidusio-contrib/solidus_print_invoice'         => %w[master],
  'solidusio-contrib/solidus_comments'              => %w[master],
  'solidusio-contrib/solidus_reports'               => %w[master],

  # Log
  'solidusio-contrib/solidus_papertrail'            => %w[master],
  'solidusio-contrib/solidus_log_viewer'            => %w[master],

  # CMS
  'solidusio-contrib/solidus_static_content'        => %w[master],

  # Legacy (extracted from core)
  'solidusio-contrib/solidus_expedited_exchanges'   => %w[master],
  'solidusio/solidus_legacy_return_authorizations'  => %w[master],
  'solidusio-contrib/solidus_legacy_stock_system'   => %w[master],
}.map do |name, branches|
  SolidusExtensions::Project.new(name, branches)
end.select(&:exists?)

task :retrigger do
  PROJECTS.each do |project|
    next unless project.name =~ /\Asolidusio/
    project.retrigger
  end
end

task :status do
  PROJECTS.each do |project|
    puts project.name
    project.branches.each do |branch|
      puts "  #{branch.name}"
      branch.last_build.state_by_version.each do |version, state|
        puts "    #{version} #{state}"
      end
    end
  end
end

task :status_html do
  require 'erb'
  puts ERB.new(File.read("status.html.erb")).result
end
