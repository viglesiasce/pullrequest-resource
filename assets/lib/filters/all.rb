require 'octokit'
require_relative '../pull_request'

module Filters
  class All
    def initialize(pull_requests: [], input: Input.instance)
      @input = input
    end

    def pull_requests
      @pull_requests ||= Octokit.pulls(input.source.repo, pull_options).map do |pr|
        PullRequest.new(pr: pr)
      end
      if input.source.label.nil?
        return @pull_requests
      else
        filtered_prs = []
        @pull_requests.each do |pr|
          issue = Octokit.issue(input.source.repo, pr.id)
          issue.labels.each do |label|
            if label.name == input.source.label
              filtered_prs.push(pr)
              break
            end
          end
        end
        @pull_requests = filtered_prs
      end
    end

    private

    attr_reader :input

    def pull_options
      options = { state: 'open', sort: 'updated', direction: 'asc' }
      options[:base] = input.source.base if input.source.base
      options
    end
  end
end
