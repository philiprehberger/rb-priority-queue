# philiprehberger-priority_queue

[![Gem Version](https://badge.fury.io/rb/philiprehberger-priority_queue.svg)](https://badge.fury.io/rb/philiprehberger-priority_queue)
$badge_line
[![CI](https://github.com/philiprehberger/rb-priority-queue/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-priority-queue/actions/workflows/ci.yml)

Binary heap priority queue with min/max modes and custom comparators. Features O(log n) push/pop, priority updates, merge operations, and FIFO tie-breaking for equal priorities.

## Requirements

- Ruby >= 3.1

## Installation

```sh
gem install philiprehberger-priority_queue
```

Or add to your Gemfile:

```ruby
gem 'philiprehberger-priority_queue'
```

## Usage

```ruby
require 'philiprehberger/priority_queue'

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

### `Queue.new(mode: :min, &comparator)`

Creates a new priority queue. Mode can be `:min` (default) or `:max`. An optional block provides a custom comparator.

### `#push(item, priority:)` / `#<<`

Adds an item with the given priority. Returns self. The `<<` operator accepts a hash: `queue << { item: 'x', priority: 1 }`.

### `#pop`

Removes and returns the highest-priority item. Returns `nil` if empty.

### `#peek`

Returns the highest-priority item without removing it. Returns `nil` if empty.

### `#size` / `#empty?`

Returns the number of items or whether the queue is empty.

### `#change_priority(item, new_priority)`

Updates the priority of an existing item and re-heapifies. Raises `ArgumentError` if the item is not found.

### `#to_a`

Returns all items sorted by priority.

### `#include?(item)`

Returns `true` if the item is in the queue.

### `#clear`

Removes all items from the queue.

### `#merge(other)`

Returns a new queue containing items from both queues. Does not modify the originals.

## Development

```sh
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT License. See [LICENSE](LICENSE) for details.
