$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'solidus_extensions'
require 'circleci_solidus_extensions'
require 'pry'

Travis.access_token = ENV['TRAVIS_TOKEN']
CircleCi.configure { |config| config.token = ENV['CIRCLECI_TOKEN'] }

OLD_VERSIONS = %W[v1.0 v1.1 v1.2 v1.3 v1.4 v2.0 v2.1 v2.2 v2.3]
VERSIONS = %W[v1.0 v1.1 v1.2 v1.3 v1.4 v2.0 v2.1 v2.2 v2.3 v2.4 v2.5 v2.6 v2.7 v2.8 master]
PROJECTS = {
  # Auth
  'solidus_auth_devise' => { org: 'solidusio', ci: :circleci },
  'solidus_social' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_user_roles' => { org: 'boomerdigital', ci: :travis },

  # Payments
  'solidus_gateway' => { org: 'solidusio', ci: :travis },
  'solidus_stripe' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_braintree' => { org: 'solidusio', ci: :travis },
  'solidus_paypal_braintree' => { org: 'solidusio', ci: :travis },
  'solidus_affirm' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_signifyd' => { org: 'solidusio', ci: :travis },
  'solidus_amazon_payments' => { org: 'boomerdigital', ci: :travis },
  'solidus_subscriptions' => { org: 'solidusio-contrib', ci: :travis },

  # Shipping
  'solidus_easypost' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_active_shipping' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_shipstation' => { org: 'boomerdigital', ci: :travis },

  # I18n
  'solidus_i18n' => { org: 'solidusio', ci: :travis },
  'solidus_globalize' => { org: 'solidusio-contrib', ci: :travis },

  # Frontend enhancements
  'solidus_customer_images' => { org: 'solidusio-contrib', ci: :travis },

  # Taxes
  'solidus_avatax' => { org: 'solidusio', ci: :travis },
  'solidus_tax_cloud' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_avatax_certified' => { org: 'boomerdigital', branches: %w[master v2.1], ci: :travis },

  # Marketplace
  'solidus_multi_domain' => { org: 'solidusio-contrib', ci: :travis },

  # Product and Variant Customization
  'solidus_asset_variant_options' => { org: 'solidusio', ci: :travis },
  'solidus_related_products' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_product_assembly' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_editor' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_email_to_friend' => { org: 'boomerdigital', ci: :travis },
  'solidus_flexi_variants' => { org: 'boomerdigital', ci: :travis },

  # Search
  'solidus_elastic_product' => { org: 'boomerdigital', ci: :travis },

  # Marketing
  'solidus_product_feed' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_sitemap' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_trackers' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_seo' => { org: 'karmakatahdin', ci: :travis },

  # Promo
  'solidus_volume_pricing' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_wishlist' => { org: 'boomerdigital', ci: :travis },

  # Admin
  'solidus_prototypes' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_print_invoice' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_comments' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_reports' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_simple_dash' => { org: 'magma-labs', ci: :travis },

  # Log
  'solidus_papertrail' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_log_viewer' => { org: 'solidusio-contrib', ci: :travis },

  # CMS
  'solidus_static_content' => { org: 'solidusio-contrib', ci: :travis },

  # Legacy (extracted from core)
  'solidus_expedited_exchanges' => { org: 'solidusio-contrib', ci: :travis },
  'solidus_legacy_return_authorizations' => { org: 'solidusio', ci: :travis },
  'solidus_legacy_stock_system' => { org: 'solidusio-contrib', ci: :travis },
}.map do |repo, options|
  case options[:ci]
  when :travis
    SolidusExtensions::Project.new(options[:org], repo, options[:branches])
  when :circleci
    SolidusExtensions::CircleCi::Project.new(options[:org], repo, options[:branches])
  end
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


task :build do
  require 'erb'

  File.open('index.html', "w+") do |f|
    render = ERB.new(File.read("status.html.erb")).result
    f.write(render)
  end
end
