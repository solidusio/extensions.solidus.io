# frozen_string_literal: true

require 'circleci'
require 'erb'

module SolidusExtensions
  module CircleCi
    class Project
      include ERB::Util
      attr_reader :org, :repo

      def initialize(org, repo, branches = nil)
        @org = org
        @repo = repo
        @branches = branches || ['master']
      end

      def github_url
        "https://github.com/#{org}/#{repo}"
      end

      def branches
        @branches.map do |name|
          Branch.new(self, name)
        end
      end

      def circleci_project
        ::CircleCi::Project.new(org, repo)
      end

      def exists?
        # Just make a noop call to see if the project exists
        circleci_project.settings.success?
      end

      def retrigger
        # noop
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
                  workflow = branch.last_workflow
                  steps = workflow.steps_for(solidus_version: version)
                  classes = ["status"]
                  classes << "hide-old" if OLD_VERSIONS.include?(version)
                  classes = classes.join(" ")

                  started_at = steps.map(&:started_at).min
                  finished_at = steps.map(&:finished_at).max
                %>
                <% if steps.none? %>
                  <td class="<%= classes %> unsupported"></td>
                <% elsif steps.any?(&:pending?) %>
                  <td class="<%= classes %> pending" title="started building at <%= started_at %>"><a href="<%= workflow.url %>">pending</a></td>
                <% elsif steps.all?(&:passed?) %>
                  <td class="<%= classes %> success" title="passed at <%= finished_at %>"><a href="<%= workflow.url %>">passed</a></td>
                <% else %>
                  <td class="<%= classes %> failed" title="failed at <%= finished_at %>"><a href="<%= workflow.url %>">failed</a></td>
                <% end %>
              <% end %>
            </tr>
          <% end %>
        }
      end
    end

    class Branch
      attr_reader :project, :name

      def initialize(project, name)
        @project = project
        @name = name
        @last_workflow = last_workflow
      end

      def last_workflow
        last_builds = project.circleci_project.recent_builds_branch(name, limit: 4).body
        builds_grouped_by_workflow = last_builds.group_by { |build| build["workflows"]["workflow_id"] if build && build.key?("workflows") }
        last_complete_workflow = builds_grouped_by_workflow.find { |_id, builds| builds.size == 2 }

        Workflow.new(project, *last_complete_workflow)
      end
    end

    class Workflow
      attr_reader :workflow_id, :builds, :project

      def initialize(project, workflow_id, builds)
        @workflow_id = workflow_id
        @project = project
        @builds = builds.map { |build_data| Build.new(project, build_data["build_num"]) }
      end

      def mysql_build
        @mysql_build ||= builds.find { |build| build.name == 'run-specs-with-mysql' }
      end

      def postgres_build
        @postgres_build ||= builds.find { |build| build.name == 'run-specs-with-postgres' }
      end

      def steps_for(solidus_version: 'master')
        mysql_build.steps_for(solidus_version: solidus_version) +
          postgres_build.steps_for(solidus_version: solidus_version)
      end

      def url
        "https://circleci.com/workflow-run/#{workflow_id}"
      end
    end

    class Build
      attr_reader :project, :id, :cirlceci_build

      def initialize(project, id)
        @project = project
        @id = id
        @cirlceci_build = ::CircleCi::Build.new(project.org, project.repo, nil, id).get.body
      end

      def name
        cirlceci_build["build_parameters"]["CIRCLE_JOB"]
      end

      def steps
        @steps ||= cirlceci_build["steps"].map { |step_data| Step.new(step_data) }
      end

      def steps_for(solidus_version: 'master')
        steps.select { |step| step.solidus_version == solidus_version }
      end
    end

    class Step
      attr_reader :step_data

      def initialize(step_data)
        @step_data = step_data
      end

      def name
        step_data["name"]
      end

      def solidus_version
        name.gsub("Runs tests on Solidus ", '')
      end

      def action
        step_data["actions"].first
      end

      def status
        action["status"]
      end

      def passed?
        status == "success" || status == "fixed"
      end

      def pending?
        status == "running" || status == "queued" || status == "scheduled"
      end

      def failure?
        !passed? && !pending?
      end

      def started_at
        action["start_time"]
      end

      def finished_at
        action["end_time"]
      end
    end
  end
end
