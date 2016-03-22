$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'solidus_extensions'
require 'pry'

Travis.access_token = ENV['TRAVIS_TOKEN']

VERSIONS = %W[v1.0 v1.1 v1.2 master]
PROJECTS = %W[
  solidusio/solidus_auth_devise
  solidusio/solidus_gateway
  solidusio/solidus_multi_domain
  solidusio/solidus_asset_variant_options
  solidusio/solidus_legacy_return_authorizations
  solidusio/solidus_virtual_gift_card
  solidusio/solidus_braintree
  solidusio/solidus_avatax
  solidusio/solidus_signifyd

  solidusio-contrib/solidus_social
  solidusio-contrib/solidus_related_products
].map{|name| SolidusExtensions::Project.new(name) }

task :retrigger do
  PROJECTS.each do |project|
    project.retrigger
  end
end

task :status do
  PROJECTS.each do |project|
    puts project.name
    project.state_by_version.each do |version, state|
      puts "   #{version} #{state}"
    end
  end
end

task :status_html do
  require 'erb'
  puts ERB.new(File.read("status.html.erb")).result
end
