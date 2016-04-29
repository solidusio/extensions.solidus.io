$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'solidus_extensions'
require 'pry'

Travis.access_token = ENV['TRAVIS_TOKEN']

VERSIONS = %W[v1.0 v1.1 v1.2 v1.3 master]
PROJECTS = {
  'solidusio/solidus_auth_devise'                   => %w[master],
  'solidusio/solidus_gateway'                       => %w[master v1.0 v0.9],
  'solidusio/solidus_multi_domain'                  => %w[master v1.0],
  'solidusio/solidus_asset_variant_options'         => %w[master],
  'solidusio/solidus_legacy_return_authorizations'  => %w[master],
  'solidusio/solidus_virtual_gift_card'             => %w[master],
  'solidusio/solidus_braintree'                     => %w[master],
  'solidusio/solidus_avatax'                        => %w[master v1.1],
  'solidusio/solidus_signifyd'                      => %w[master],

  'solidusio-contrib/solidus_i18n'                  => %w[master],
  'solidusio-contrib/solidus_globalize'             => %w[master],
  'solidusio-contrib/solidus_social'                => %w[master],
  'solidusio-contrib/solidus_related_products'      => %w[master],
  'solidusio-contrib/solidus_easypost'              => %w[master],
  'solidusio-contrib/solidus_editor'                => %w[master],
  'solidusio-contrib/solidus_paypal_express'        => %w[master],
  'solidusio-contrib/solidus_papertrail'            => %w[master],
  'solidusio-contrib/solidus_product_feed'          => %w[master],
  'solidusio-contrib/solidus_comments'              => %w[master],
  'solidusio-contrib/solidus_log_viewer'            => %w[master],
  'solidusio-contrib/solidus_print_invoice'         => %w[master],
  'solidusio-contrib/solidus_product_assembly'      => %w[master],
}.map{|name, branches| SolidusExtensions::Project.new(name, branches) }

task :retrigger do
  PROJECTS.each do |project|
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
