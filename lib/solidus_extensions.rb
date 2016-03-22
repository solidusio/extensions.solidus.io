require 'travis'

module SolidusExtensions
  class Project
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def shortname
      name[/\/(.*)/, 1]
    end

    def travis_repo
      Travis::Repository.find(name)
    end

    def travis_jobs
      travis_repo.branch('master').jobs
    end

    def state_by_version
      travis_jobs.group_by do |job|
        job.config['env'][/SOLIDUS_BRANCH=(\S+)/, 1]
      end.map do |(version, builds)|
        [version, builds.all?(&:passed?)]
      end.to_h
    rescue Travis::Client::Error
      {}
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
