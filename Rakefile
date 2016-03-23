$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'solidus_extensions'
require 'pry'

Travis.access_token = ENV['TRAVIS_TOKEN']

VERSIONS = %W[v1.0 v1.1 v1.2 master]
PROJECTS = {
  'solidusio/solidus_auth_devise'                   => %w[master],
  'solidusio/solidus_gateway'                       => %w[master],
  'solidusio/solidus_multi_domain'                  => %w[master],
  'solidusio/solidus_asset_variant_options'         => %w[master],
  'solidusio/solidus_legacy_return_authorizations'  => %w[master],
  'solidusio/solidus_virtual_gift_card'             => %w[master],
  'solidusio/solidus_braintree'                     => %w[master],
  'solidusio/solidus_avatax'                        => %w[master],
  'solidusio/solidus_signifyd'                      => %w[master],

  'solidusio-contrib/solidus_social'                => %w[master],
  'solidusio-contrib/solidus_related_products'      => %w[master],
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
