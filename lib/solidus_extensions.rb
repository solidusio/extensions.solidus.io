require 'travis'
require 'forwardable'

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
    def initialize(build)
      @build = build
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
    attr_reader :project, :name, :last_build
    def initialize(project, name, last_build)
      @project = project
      @name = name
      @last_build = last_build
    end
  end
  class Project
    attr_reader :name

    def initialize(name)
      @name = name
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
      travis_repo.branches.map do |name, last_build|
        next unless name =~ BRANCH_REGEX
        Branch.new(self, name, Build.new(last_build))
      end.compact
    end

    def travis_repo
      Travis::Repository.find(name)
    end

    def last_build
      Build.new(travis_repo.branch('master'))
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
      r = session.post("/repo/solidusio%2Fsolidus_auth_devise/requests", request: request)
      pp r
    end
  end
end
