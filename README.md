# philiprehberger-priority_queue

[![Tests](https://github.com/philiprehberger/rb-priority-queue/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-priority-queue/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-priority_queue.svg)](https://rubygems.org/gems/philiprehberger-priority_queue)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-priority-queue)](https://github.com/philiprehberger/rb-priority-queue/commits/main)

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
queue.push("low", priority: 1)
queue.push("high", priority: 10)
queue.push("mid", priority: 5)

queue.pop   # => "low"
queue.pop   # => "mid"
queue.pop   # => "high"

# Peek without removing
queue.push("item", priority: 1)
queue.peek   # => "item"
queue.size   # => 1
queue.empty? # => false

# Shovel operator for hash-based push
queue << { item: "task", priority: 3 }
```

### Max-Heap Mode

Pass `mode: :max` to pop the highest priority first.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new(mode: :max)
queue.push("task_a", priority: 3)
queue.push("task_b", priority: 7)
queue.push("task_c", priority: 1)

queue.pop # => "task_b"
queue.pop # => "task_a"
queue.pop # => "task_c"
```

### Custom Comparator

Supply a block to define your own ordering. The block receives two priorities and must return `-1`, `0`, or `1`.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new { |a, b| a.length <=> b.length }
queue.push("short", priority: "short")
queue.push("very long", priority: "very long")
queue.pop # => "short"
```

### Priority Updates

Change the priority of an item already in the queue. The heap re-balances automatically.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push("task_a", priority: 10)
queue.push("task_b", priority: 5)

queue.change_priority("task_a", 1) # task_a is now highest priority
queue.pop # => "task_a"
```

### Batch Push

Add multiple items at once from an array of hashes.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push_many([
  { item: "email", priority: 2 },
  { item: "backup", priority: 5 },
  { item: "alert", priority: 1 }
])

queue.pop # => "alert"
```

### Bulk Insertion

Insert multiple items from a hash, look up the priority of an item, and search in priority order.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.bulk_push("email" => 2, "backup" => 5, "alert" => 1)

queue.priority_of("backup")            # => 5
queue.find { |_item, priority| priority > 1 } # => ["email", 2]
```

### Peek Priority

Return just the top priority value without the item.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push("task", priority: 7)
queue.peek_priority # => 7
```

### Drain

Pop all items and return them as an array in priority order.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push("c", priority: 3)
queue.push("a", priority: 1)
queue.push("b", priority: 2)

queue.drain # => ["a", "b", "c"]
queue.empty? # => true
```

### Pop N

Pop up to `n` items in priority order. Returns fewer than `n` items when the queue is exhausted.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push("a", priority: 1)
queue.push("b", priority: 2)
queue.push("c", priority: 3)

queue.pop_n(2) # => ["a", "b"]
queue.pop_n(5) # => ["c"]
queue.pop_n(0) # => []
```

### Delete

Remove a specific item by value.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push("a", priority: 1)
queue.push("b", priority: 2)

queue.delete("a") # => "a"
queue.size # => 1
```

### Priorities

Return a sorted array of unique priority values currently in the queue.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push("a", priority: 3)
queue.push("b", priority: 1)
queue.push("c", priority: 3)

queue.priorities # => [1, 3]
```

### Enumerable

The queue includes `Enumerable`, yielding `[item, priority]` pairs in priority order without modifying the queue.

```ruby
queue = Philiprehberger::PriorityQueue::Queue.new
queue.push("x", priority: 10)
queue.push("y", priority: 5)

queue.map { |item, priority| "#{item}:#{priority}" } # => ["y:5", "x:10"]
queue.select { |_item, priority| priority > 7 }      # => [["x", 10]]
```

### Merging Queues

Combine two queues into a new queue. The originals are unchanged.

```ruby
q1 = Philiprehberger::PriorityQueue::Queue.new
q1.push("a", priority: 1)
q1.push("b", priority: 3)

q2 = Philiprehberger::PriorityQueue::Queue.new
q2.push("c", priority: 2)

merged = q1.merge(q2)
merged.to_a # => ["a", "c", "b"]
merged.size # => 3
```

## API

| Method | Description |
|--------|-------------|
| `Queue.new(mode: :min, &comparator)` | Create a priority queue; mode can be `:min` or `:max`; optional custom comparator block |
| `#push(item, priority:)` | Add an item with the given priority; returns `self` for chaining |
| `#<<(item:, priority:)` | Shovel operator; push via a hash with `:item` and `:priority` keys |
| `#pop` | Remove and return the highest-priority item; returns `nil` when empty |
| `#peek` | Return the highest-priority item without removing it; returns `nil` when empty |
| `#size` | Return the number of items in the queue |
| `#empty?` | Return `true` if the queue has no items |
| `#change_priority(item, new_priority)` | Update the priority of an existing item and re-heapify; raises `ArgumentError` if item not found |
| `#to_a` | Return all items sorted by priority with FIFO tie-breaking |
| `#include?(item)` | Return `true` if the item is in the queue |
| `#clear` | Remove all items from the queue; returns `self` |
| `#merge(other)` | Return a new queue containing items from both queues |
| `#push_many(items)` | Batch push from array of hashes `[{ item: x, priority: n }, ...]`; returns `self` |
| `#peek_priority` | Return just the top priority value; returns `nil` when empty |
| `#drain` | Pop all items and return as array in priority order; empties the queue |
| `#pop_n(n)` | Pop up to `n` items in priority order and return as array; returns `[]` for empty queue or `n == 0`; raises `ArgumentError` for negative `n` |
| `#delete(item)` | Remove a specific item by value; returns the item or `nil` |
| `#priorities` | Return sorted array of unique priority values in the queue |
| `#each` | Yield `[item, priority]` pairs in priority order (Enumerable) |
| `#bulk_push(items_hash)` | Insert multiple items from a hash `{ item => priority, ... }`; returns `self`; raises `ArgumentError` for non-Hash input |
| `#priority_of(item)` | Return the priority of the first matching item (O(n) linear scan); returns `nil` if not present |
| `#find(&block)` | Yield `[item, priority]` pairs in priority order and return the first pair for which the block is truthy; returns `nil` if none match, or an `Enumerator` when no block is given |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-priority-queue)

🐛 [Report issues](https://github.com/philiprehberger/rb-priority-queue/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-priority-queue/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
