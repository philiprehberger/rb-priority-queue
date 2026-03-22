# philiprehberger-priority_queue

[![Tests](https://github.com/philiprehberger/rb-priority-queue/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-priority-queue/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-priority_queue.svg)](https://rubygems.org/gems/philiprehberger-priority_queue)
[![License](https://img.shields.io/github/license/philiprehberger/rb-priority-queue)](LICENSE)

Binary heap priority queue with min/max modes and custom comparators

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem 'philiprehberger-priority_queue'
```

Or install directly:

```bash
gem install philiprehberger-priority_queue
```

## Usage

```ruby
require 'philiprehberger/priority_queue'

pq = Philiprehberger::PriorityQueue::Queue.new
pq.push('low', priority: 1)
pq.push('high', priority: 10)
pq.push('mid', priority: 5)

pq.pop   # => "low"
pq.pop   # => "mid"
pq.pop   # => "high"
```

### Max-Heap

```ruby
pq = Philiprehberger::PriorityQueue::Queue.new(mode: :max)
pq.push('low', priority: 1)
pq.push('high', priority: 10)
pq.pop   # => "high"
```

### Custom Comparator

```ruby
pq = Philiprehberger::PriorityQueue::Queue.new { |a, b| a[:priority] <=> b[:priority] }
pq.push('task', priority: 5)
```

### Updating Priorities

```ruby
pq = Philiprehberger::PriorityQueue::Queue.new
pq.push('task_a', priority: 10)
pq.push('task_b', priority: 5)
pq.change_priority('task_a', 1)
pq.pop  # => "task_a" (now has lowest priority)
```

### Merging Queues

```ruby
pq1 = Philiprehberger::PriorityQueue::Queue.new
pq1.push('a', priority: 1)

pq2 = Philiprehberger::PriorityQueue::Queue.new
pq2.push('b', priority: 2)

pq1.merge(pq2)
pq1.size  # => 2
```

## API

### `Philiprehberger::PriorityQueue::Queue`

| Method | Description |
|--------|-------------|
| `.new(mode: :min)` | Create a min-heap (default) or max-heap |
| `.new { \|a, b\| ... }` | Create with a custom comparator block |
| `#push(item, priority:)` | Add an item with a priority |
| `#pop` | Remove and return the highest-priority item |
| `#peek` | View the highest-priority item without removing it |
| `#size` | Number of items in the queue |
| `#empty?` | Whether the queue is empty |
| `#change_priority(item, new_priority)` | Update an item's priority |
| `#to_a` | Return all items in priority order |
| `#merge(other)` | Merge another queue into this one |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
