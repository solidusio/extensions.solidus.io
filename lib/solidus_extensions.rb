require 'travis'
require 'forwardable'
require 'cgi'
require 'erb'

module SolidusExtensions
  BRANCH_REGEX = /\Amaster\Z|\Av\d+.\d+\Z/.freeze

  class Job
    extend Forwardable
    def_delegators :@job, :passed?, :failed?, :pending?, :finished_at, :started_at

    def initialize(job)
      @job = job
    end

    def solidus_version
      @job.config['env'][/SOLIDUS_BRANCH=(\S+)/, 1]
    end
  end
  class Build
    def initialize(project, build)
      @project = project
      @build = build
    end

    def url
      "#{@project.travis_url}/builds/#{@build.id}"
    end

    def jobs
      @jobs ||= @build.jobs.map { |job| Job.new(job) }
    end

    def jobs_for(solidus_version:)
      jobs.select { |job| job.solidus_version == solidus_version }
    end

    def jobs_by_version
      jobs.group_by(&:solidus_version)
    end
  end
  class Branch
    attr_reader :project, :name
    def initialize(project, name)
      @project = project
      @name = name
      @last_build = last_build
    end

    def last_build
      @last_build ||= Build.new(@project, @project.travis_repo.branch(@name))
    end
  end
  class Project
    include ERB::Util
    attr_reader :org, :repo

    def initialize(org, repo, branches = nil)
      @org = org
      @repo = repo
      @branches = branches || ['master']
    end

    def fullname
      [org, repo].join("/")
    end

    def github_url
      "https://github.com/#{fullname}"
    end

    def travis_url
      "https://travis-ci.org/#{fullname}"
    end

    def branches
      @branches.map do |name|
        Branch.new(self, name)
      end
    end

    def travis_repo
      Travis::Repository.find(fullname)
    end

    def exists?
      travis_repo
      true
    rescue Travis::Client::NotFound
      false
    end

    def last_build
      Build.new(self, travis_repo.branch('master'))
    end

    def retrigger
      session = Travis::Client.new
      session.access_token = Travis.access_token
      session.headers['Accept'] = 'application/json'
      session.headers['Travis-API-Version'] = '3'
      request = {
        branch: 'master',
        message: "Automatic retrigger"
      }
      r = session.post("/repo/#{CGI.escape(fullname)}/requests", request: request)
      pp r
    end

    def render
      puts "Rendering #{org}⁄#{repo}"
      ERB.new(template).result(binding)
    end

    def template
      %{
        <% branches.each_with_index do |branch, i| %>
          <tr>
            <% if i == 0 %>
              <th class="name" rowspan="<%= branches.size %>">
                <a href="<%= github_url %>"><%= repo %></a>
              </th>
            <% end %>
            <td><%= branch.name %></td>
            <% VERSIONS.each do |version| %>
              <%
                build = branch.last_build
                jobs = branch.last_build.jobs_for(solidus_version: version)
                classes = ["status"]
                classes << "hide-old" if OLD_VERSIONS.include?(version)
                classes = classes.join(" ")

                started_at = jobs.map(&:started_at).min
                finished_at = jobs.map(&:finished_at).max
              %>
              <% if jobs.none? %>
                <td class="<%= classes %> unsupported"></td>
              <% elsif jobs.any?(&:pending?) %>
                <td class="<%= classes %> pending" title="started building at <%= started_at %>"><a href="<%= build.url %>">pending</a></td>
              <% elsif jobs.all?(&:passed?) %>
                <td class="<%= classes %> success" title="passed at <%= finished_at %>"><a href="<%= build.url %>">passed</a></td>
              <% else %>
                <td class="<%= classes %> failed" title="failed at <%= finished_at %>"><a href="<%= build.url %>">failed</a></td>
              <% end %>
            <% end %>
          </tr>
        <% end %>
      }
    end
  end
end
