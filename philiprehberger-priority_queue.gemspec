# frozen_string_literal: true

require_relative 'lib/philiprehberger/priority_queue/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-priority_queue'
  spec.version = Philiprehberger::PriorityQueue::VERSION
  spec.authors = ['philiprehberger']
  spec.email = ['philiprehberger@users.noreply.github.com']

  spec.summary = 'Binary heap priority queue with min/max modes, custom comparators, and priority updates'
  spec.description = 'A binary heap-based priority queue supporting min-heap, max-heap, and custom comparator ' \
                     'modes. Features O(log n) push/pop, priority changes, merge operations, and FIFO tie-breaking.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-priority_queue'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-priority-queue'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-priority-queue/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-priority-queue/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
