# philiprehberger-priority_queue

[![Tests](https://github.com/philiprehberger/rb-priority-queue/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-priority-queue/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-priority_queue.svg)](https://rubygems.org/gems/philiprehberger-priority_queue)
[![License](https://img.shields.io/github/license/philiprehberger/rb-priority-queue)](LICENSE)

Binary heap priority queue with min/max modes, custom comparators, and priority updates

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-priority_queue"
```

Or install directly:

```bash
gem install philiprehberger-priority_queue
```

## Usage

```ruby
require "philiprehberger/priority_queue"

# Min-heap (default) - lowest priority first
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push('low', priority: 1)
queue.push('high', priority: 10)
queue.push('mid', priority: 5)

queue.pop   # => "low"
queue.pop   # => "mid"
queue.pop   # => "high"

# Max-heap - highest priority first
queue = Philiprehberger::PriorityQueue::Queue.new(mode: :max)
queue.push('task_a', priority: 3)
queue.push('task_b', priority: 7)
queue.pop   # => "task_b"

# Custom comparator
queue = Philiprehberger::PriorityQueue::Queue.new { |a, b| a.length <=> b.length }
queue.push('short', priority: 'short')
queue.push('very long', priority: 'very long')
queue.pop   # => "short"

# Peek without removing
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push('item', priority: 1)
queue.peek  # => "item"
queue.size  # => 1

# Change priority
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push('task', priority: 10)
queue.change_priority('task', 1)  # now highest priority in min-heap

# Merge queues
merged = queue1.merge(queue2)

# Other operations
queue.include?('task')  # => true
queue.to_a              # => items sorted by priority
queue.empty?            # => false
queue.clear             # removes all items
```

## API

| Method | Description |
|--------|-------------|
| `Queue.new(mode: :min, &comparator)` | Create a priority queue; mode can be `:min` or `:max`; optional custom comparator block |
| `#push(item, priority:)` | Add an item with the given priority |
| `#pop` | Remove and return the highest-priority item |
| `#peek` | Return the highest-priority item without removing it |
| `#size` | Return the number of items in the queue |
| `#empty?` | Return `true` if the queue has no items |
| `#change_priority(item, new_priority)` | Update the priority of an existing item and re-heapify |
| `#to_a` | Return all items sorted by priority |
| `#include?(item)` | Return `true` if the item is in the queue |
| `#clear` | Remove all items from the queue |
| `#merge(other)` | Return a new queue containing items from both queues |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
