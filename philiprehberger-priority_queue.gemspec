# frozen_string_literal: true

require_relative 'lib/philiprehberger/priority_queue/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-priority_queue'
  spec.version       = Philiprehberger::PriorityQueue::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Binary heap priority queue with min/max modes and custom comparators'
  spec.description   = 'An efficient priority queue using a binary heap. Supports min-heap and ' \
                        'max-heap modes, custom comparators, priority updates, and merge operations.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-priority-queue'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
