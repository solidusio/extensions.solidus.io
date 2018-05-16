require 'travis'
require 'forwardable'
require 'cgi'

module SolidusExtensions
  BRANCH_REGEX = /\Amaster\Z|\Av\d+.\d+\Z/.freeze

  class Job
    extend Forwardable
    def_delegators :@job, :passed?, :failed?, :pending?

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

    def state_by_version
      jobs.group_by(&:solidus_version).map do |(version, builds)|
        [version, builds.all?(&:passed?)]
      end.to_h
    rescue Travis::Client::Error
      {}
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
    attr_reader :name

    def initialize(name, branches=['master'])
      @name = name
      @branches = branches
    end

    def github_url
      "https://github.com/#{name}"
    end

    def travis_url
      "https://travis-ci.org/#{name}"
    end

    def shortname
      name[/\/(.*)/, 1]
    end

    def branches
      @branches.map do |name|
        Branch.new(self, name)
      end
    end

    def travis_repo
      Travis::Repository.find(name)
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

    def state_by_version
      last_build.state_by_version
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
      r = session.post("/repo/#{CGI.escape(name)}/requests", request: request)
      pp r
    end
  end
end
