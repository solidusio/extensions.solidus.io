$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'solidus_extensions'
require 'pry'

Travis.access_token = ENV['TRAVIS_TOKEN']

PROJECTS = %W[
  solidusio/solidus_auth_devise
  solidusio/solidus_gateway
  solidusio/solidus_multi_domain
  solidusio/solidus_asset_variant_options
  solidusio/solidus_legacy_return_authorizations
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
