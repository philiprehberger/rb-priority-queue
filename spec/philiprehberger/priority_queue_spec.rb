# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::PriorityQueue::Queue do
  describe 'min-heap (default)' do
    subject(:queue) { described_class.new }

    it 'pops items in ascending priority order' do
      queue.push('low', priority: 1)
      queue.push('high', priority: 10)
      queue.push('mid', priority: 5)

      expect(queue.pop).to eq('low')
      expect(queue.pop).to eq('mid')
      expect(queue.pop).to eq('high')
    end

    it 'returns lowest priority item with peek' do
      queue.push('b', priority: 5)
      queue.push('a', priority: 1)

      expect(queue.peek).to eq('a')
    end
  end

  describe 'max-heap' do
    subject(:queue) { described_class.new(mode: :max) }

    it 'pops items in descending priority order' do
      queue.push('low', priority: 1)
      queue.push('high', priority: 10)
      queue.push('mid', priority: 5)

      expect(queue.pop).to eq('high')
      expect(queue.pop).to eq('mid')
      expect(queue.pop).to eq('low')
    end
  end

  describe 'custom comparator' do
    it 'uses the provided comparator for ordering' do
      queue = described_class.new { |a, b| a.length <=> b.length }
      queue.push('medium', priority: 'medium')
      queue.push('short', priority: 'short')
      queue.push('very long string', priority: 'very long string')

      expect(queue.pop).to eq('short')
      expect(queue.pop).to eq('medium')
      expect(queue.pop).to eq('very long string')
    end
  end

  describe '#push and #pop' do
    subject(:queue) { described_class.new }

    it 'maintains heap invariant through many operations' do
      values = (1..20).to_a.shuffle
      values.each { |v| queue.push("item_#{v}", priority: v) }

      result = []
      result << queue.pop until queue.empty?

      expect(result).to eq((1..20).map { |v| "item_#{v}" })
    end

    it 'tracks size correctly' do
      expect(queue.size).to eq(0)
      queue.push('a', priority: 1)
      expect(queue.size).to eq(1)
      queue.push('b', priority: 2)
      expect(queue.size).to eq(2)
      queue.pop
      expect(queue.size).to eq(1)
    end
  end

  describe '#<<' do
    it 'adds an item using hash syntax' do
      queue = described_class.new
      queue << { item: 'hello', priority: 1 }

      expect(queue.peek).to eq('hello')
    end

    it 'raises ArgumentError for non-hash argument' do
      queue = described_class.new
      expect { queue << 'invalid' }.to raise_error(ArgumentError)
    end
  end

  describe '#peek' do
    it 'does not remove the item' do
      queue = described_class.new
      queue.push('a', priority: 1)

      expect(queue.peek).to eq('a')
      expect(queue.peek).to eq('a')
      expect(queue.size).to eq(1)
    end
  end

  describe '#change_priority' do
    it 're-sorts correctly when priority is lowered' do
      queue = described_class.new
      queue.push('a', priority: 10)
      queue.push('b', priority: 5)

      queue.change_priority('a', 1)

      expect(queue.pop).to eq('a')
      expect(queue.pop).to eq('b')
    end

    it 're-sorts correctly when priority is raised' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 5)

      queue.change_priority('a', 10)

      expect(queue.pop).to eq('b')
      expect(queue.pop).to eq('a')
    end

    it 'raises ArgumentError for missing item' do
      queue = described_class.new
      expect { queue.change_priority('missing', 1) }.to raise_error(ArgumentError)
    end
  end

  describe '#to_a' do
    it 'returns items sorted by priority' do
      queue = described_class.new
      queue.push('c', priority: 3)
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      expect(queue.to_a).to eq(%w[a b c])
    end
  end

  describe '#include?' do
    it 'returns true for items in the queue' do
      queue = described_class.new
      queue.push('a', priority: 1)

      expect(queue.include?('a')).to be true
    end

    it 'returns false for items not in the queue' do
      queue = described_class.new
      expect(queue.include?('a')).to be false
    end

    it 'returns false after item is popped' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.pop

      expect(queue.include?('a')).to be false
    end
  end

  describe '#merge' do
    it 'combines two queues into a new queue' do
      q1 = described_class.new
      q1.push('a', priority: 1)
      q1.push('c', priority: 3)

      q2 = described_class.new
      q2.push('b', priority: 2)
      q2.push('d', priority: 4)

      merged = q1.merge(q2)

      expect(merged.size).to eq(4)
      expect(merged.pop).to eq('a')
      expect(merged.pop).to eq('b')
      expect(merged.pop).to eq('c')
      expect(merged.pop).to eq('d')
    end

    it 'does not modify the original queues' do
      q1 = described_class.new
      q1.push('a', priority: 1)

      q2 = described_class.new
      q2.push('b', priority: 2)

      q1.merge(q2)

      expect(q1.size).to eq(1)
      expect(q2.size).to eq(1)
    end
  end

  describe '#clear' do
    it 'removes all items' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.clear

      expect(queue.size).to eq(0)
      expect(queue.empty?).to be true
      expect(queue.peek).to be_nil
    end
  end

  describe 'empty queue' do
    subject(:queue) { described_class.new }

    it 'returns nil for pop' do
      expect(queue.pop).to be_nil
    end

    it 'returns nil for peek' do
      expect(queue.peek).to be_nil
    end

    it 'reports empty' do
      expect(queue.empty?).to be true
    end
  end

  describe 'duplicate priorities (FIFO ordering)' do
    it 'breaks ties by insertion order' do
      queue = described_class.new
      queue.push('first', priority: 1)
      queue.push('second', priority: 1)
      queue.push('third', priority: 1)

      expect(queue.pop).to eq('first')
      expect(queue.pop).to eq('second')
      expect(queue.pop).to eq('third')
    end

    it 'maintains FIFO across many items with same priority' do
      queue = described_class.new
      items = (1..10).map { |i| "item_#{i}" }
      items.each { |item| queue.push(item, priority: 5) }

      result = []
      result << queue.pop until queue.empty?
      expect(result).to eq(items)
    end
  end

  describe 'large queue' do
    it 'handles 200 items correctly' do
      queue = described_class.new
      values = (1..200).to_a.shuffle
      values.each { |v| queue.push("item_#{v}", priority: v) }

      result = []
      result << queue.pop until queue.empty?
      expect(result).to eq((1..200).map { |v| "item_#{v}" })
    end

    it 'maintains correct size for 100+ items' do
      queue = described_class.new
      150.times { |i| queue.push("item_#{i}", priority: i) }
      expect(queue.size).to eq(150)
    end
  end

  describe '#change_priority' do
    it 'lowers priority so item pops first' do
      queue = described_class.new
      queue.push('a', priority: 10)
      queue.push('b', priority: 20)
      queue.push('c', priority: 30)

      queue.change_priority('c', 1)
      expect(queue.pop).to eq('c')
    end

    it 'raises priority so item pops last' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('c', priority: 3)

      queue.change_priority('a', 100)
      expect(queue.pop).to eq('b')
      expect(queue.pop).to eq('c')
      expect(queue.pop).to eq('a')
    end

    it 'handles changing to the same priority (no-op)' do
      queue = described_class.new
      queue.push('a', priority: 5)
      queue.change_priority('a', 5)
      expect(queue.pop).to eq('a')
    end
  end

  describe '#include?' do
    it 'returns true for an existing item' do
      queue = described_class.new
      queue.push('x', priority: 1)
      expect(queue.include?('x')).to be true
    end

    it 'returns false for a missing item' do
      queue = described_class.new
      queue.push('x', priority: 1)
      expect(queue.include?('y')).to be false
    end
  end

  describe '#clear and re-add' do
    it 'allows adding items after clear' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.clear

      queue.push('c', priority: 3)
      queue.push('d', priority: 1)

      expect(queue.size).to eq(2)
      expect(queue.pop).to eq('d')
      expect(queue.pop).to eq('c')
    end
  end

  describe '#to_a order verification' do
    it 'returns items in priority order for min-heap' do
      queue = described_class.new
      queue.push('c', priority: 30)
      queue.push('a', priority: 10)
      queue.push('b', priority: 20)

      expect(queue.to_a).to eq(%w[a b c])
    end

    it 'returns items in priority order for max-heap' do
      queue = described_class.new(mode: :max)
      queue.push('c', priority: 30)
      queue.push('a', priority: 10)
      queue.push('b', priority: 20)

      expect(queue.to_a).to eq(%w[c b a])
    end

    it 'does not modify the queue' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.to_a
      expect(queue.size).to eq(2)
    end
  end

  describe '#merge with non-empty queues' do
    it 'interleaves priorities correctly' do
      q1 = described_class.new
      q1.push('a', priority: 1)
      q1.push('c', priority: 5)

      q2 = described_class.new
      q2.push('b', priority: 3)
      q2.push('d', priority: 7)

      merged = q1.merge(q2)
      expect(merged.to_a).to eq(%w[a b c d])
    end
  end

  describe 'negative priorities' do
    it 'handles negative priority values' do
      queue = described_class.new
      queue.push('neg', priority: -10)
      queue.push('pos', priority: 10)
      queue.push('zero', priority: 0)

      expect(queue.pop).to eq('neg')
      expect(queue.pop).to eq('zero')
      expect(queue.pop).to eq('pos')
    end
  end

  describe 'float priorities' do
    it 'orders by float priority values' do
      queue = described_class.new
      queue.push('b', priority: 1.5)
      queue.push('a', priority: 1.1)
      queue.push('c', priority: 1.9)

      expect(queue.pop).to eq('a')
      expect(queue.pop).to eq('b')
      expect(queue.pop).to eq('c')
    end

    it 'handles very close float priorities' do
      queue = described_class.new
      queue.push('a', priority: 1.0000001)
      queue.push('b', priority: 1.0000002)

      expect(queue.pop).to eq('a')
      expect(queue.pop).to eq('b')
    end
  end

  describe 'pop returns nil on empty' do
    it 'returns nil after all items popped' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.pop
      expect(queue.pop).to be_nil
    end
  end

  describe 'Enumerable' do
    it 'includes Enumerable' do
      expect(described_class.ancestors).to include(Enumerable)
    end

    it 'yields [item, priority] pairs in priority order' do
      queue = described_class.new
      queue.push('c', priority: 3)
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      pairs = queue.map { |item, priority| [item, priority] }
      expect(pairs).to eq([['a', 1], ['b', 2], ['c', 3]])
    end

    it 'does not modify the queue' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.each { |_item, _priority| }
      expect(queue.size).to eq(2)
    end

    it 'returns an enumerator when no block given' do
      queue = described_class.new
      queue.push('a', priority: 1)
      expect(queue.each).to be_a(Enumerator)
    end

    it 'supports map via Enumerable' do
      queue = described_class.new
      queue.push('x', priority: 10)
      queue.push('y', priority: 20)

      result = queue.map { |item, _priority| item.upcase }
      expect(result).to eq(%w[X Y])
    end

    it 'supports select via Enumerable' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 5)
      queue.push('c', priority: 10)

      result = queue.select { |_item, priority| priority > 3 }
      expect(result).to eq([['b', 5], ['c', 10]])
    end

    it 'works with an empty queue' do
      queue = described_class.new
      expect(queue.map { |item, _| item }).to eq([])
    end
  end

  describe '#push_many' do
    it 'adds multiple items from array of hashes' do
      queue = described_class.new
      queue.push_many([{ item: 'c', priority: 3 }, { item: 'a', priority: 1 }, { item: 'b', priority: 2 }])

      expect(queue.size).to eq(3)
      expect(queue.pop).to eq('a')
      expect(queue.pop).to eq('b')
      expect(queue.pop).to eq('c')
    end

    it 'returns self for chaining' do
      queue = described_class.new
      result = queue.push_many([{ item: 'a', priority: 1 }])
      expect(result).to be(queue)
    end

    it 'handles empty array' do
      queue = described_class.new
      queue.push_many([])
      expect(queue.size).to eq(0)
    end

    it 'works with existing items in the queue' do
      queue = described_class.new
      queue.push('x', priority: 5)
      queue.push_many([{ item: 'a', priority: 1 }, { item: 'z', priority: 10 }])

      expect(queue.size).to eq(3)
      expect(queue.pop).to eq('a')
    end
  end

  describe '#peek_priority' do
    it 'returns the top priority value' do
      queue = described_class.new
      queue.push('a', priority: 5)
      queue.push('b', priority: 2)
      queue.push('c', priority: 8)

      expect(queue.peek_priority).to eq(2)
    end

    it 'returns nil on empty queue' do
      queue = described_class.new
      expect(queue.peek_priority).to be_nil
    end

    it 'returns the max priority for max-heap' do
      queue = described_class.new(mode: :max)
      queue.push('a', priority: 5)
      queue.push('b', priority: 10)

      expect(queue.peek_priority).to eq(10)
    end

    it 'does not modify the queue' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.peek_priority
      expect(queue.size).to eq(1)
    end
  end

  describe '#drain' do
    it 'returns all items in priority order' do
      queue = described_class.new
      queue.push('c', priority: 3)
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      expect(queue.drain).to eq(%w[a b c])
    end

    it 'leaves the queue empty' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.drain

      expect(queue.empty?).to be true
      expect(queue.size).to eq(0)
    end

    it 'returns empty array for empty queue' do
      queue = described_class.new
      expect(queue.drain).to eq([])
    end

    it 'works with max-heap' do
      queue = described_class.new(mode: :max)
      queue.push('a', priority: 1)
      queue.push('b', priority: 3)
      queue.push('c', priority: 2)

      expect(queue.drain).to eq(%w[b c a])
    end
  end

  describe '#pop_n' do
    it 'returns [] when n is 0' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      expect(queue.pop_n(0)).to eq([])
      expect(queue.size).to eq(2)
    end

    it 'returns items in priority order' do
      queue = described_class.new
      queue.push('c', priority: 3)
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('d', priority: 4)

      expect(queue.pop_n(3)).to eq(%w[a b c])
      expect(queue.size).to eq(1)
    end

    it 'returns all items when n exceeds size' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('c', priority: 3)

      expect(queue.pop_n(queue.size + 5)).to eq(%w[a b c])
      expect(queue.empty?).to be true
    end

    it 'drains the queue when n equals size' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      expect(queue.pop_n(2)).to eq(%w[a b])
      expect(queue.empty?).to be true
    end

    it 'returns [] for an empty queue' do
      queue = described_class.new
      expect(queue.pop_n(5)).to eq([])
    end

    it 'raises ArgumentError for negative n' do
      queue = described_class.new
      expect { queue.pop_n(-1) }.to raise_error(ArgumentError)
    end

    it 'works with max-heap mode' do
      queue = described_class.new(mode: :max)
      queue.push('a', priority: 1)
      queue.push('b', priority: 3)
      queue.push('c', priority: 2)

      expect(queue.pop_n(2)).to eq(%w[b c])
    end
  end

  describe '#peek_n' do
    it 'returns [] when n is 0' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      expect(queue.peek_n(0)).to eq([])
      expect(queue.size).to eq(2)
    end

    it 'raises ArgumentError for negative n' do
      queue = described_class.new
      expect { queue.peek_n(-1) }.to raise_error(ArgumentError, 'n must be non-negative, got -1')
    end

    it 'returns [] for an empty queue' do
      queue = described_class.new
      expect(queue.peek_n(5)).to eq([])
    end

    it 'returns the top n items in priority order when n is smaller than size' do
      queue = described_class.new
      queue.push('c', priority: 3)
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('d', priority: 4)

      expect(queue.peek_n(2)).to eq(%w[a b])
    end

    it 'returns all items in priority order when n equals size' do
      queue = described_class.new
      queue.push('c', priority: 3)
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      expect(queue.peek_n(3)).to eq(%w[a b c])
    end

    it 'returns all items when n exceeds size' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('c', priority: 3)

      expect(queue.peek_n(queue.size + 5)).to eq(%w[a b c])
    end

    it 'does not modify the queue' do
      queue = described_class.new
      queue.push('c', priority: 3)
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      queue.peek_n(2)

      expect(queue.size).to eq(3)
      expect(queue.to_a).to eq(%w[a b c])
    end

    it 'returns largest first for max-heap mode' do
      queue = described_class.new(mode: :max)
      queue.push('a', priority: 1)
      queue.push('b', priority: 3)
      queue.push('c', priority: 2)

      expect(queue.peek_n(2)).to eq(%w[b c])
    end
  end

  describe '#delete' do
    it 'removes and returns the item' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('c', priority: 3)

      expect(queue.delete('b')).to eq('b')
      expect(queue.size).to eq(2)
      expect(queue.include?('b')).to be false
    end

    it 'returns nil for item not in queue' do
      queue = described_class.new
      queue.push('a', priority: 1)
      expect(queue.delete('missing')).to be_nil
    end

    it 'maintains heap order after deletion' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('c', priority: 3)
      queue.push('d', priority: 4)
      queue.push('e', priority: 5)

      queue.delete('c')

      expect(queue.pop).to eq('a')
      expect(queue.pop).to eq('b')
      expect(queue.pop).to eq('d')
      expect(queue.pop).to eq('e')
    end

    it 'handles deleting the last item' do
      queue = described_class.new
      queue.push('a', priority: 1)

      expect(queue.delete('a')).to eq('a')
      expect(queue.empty?).to be true
    end

    it 'handles deleting the top-priority item' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      queue.delete('a')
      expect(queue.peek).to eq('b')
    end

    it 'returns nil on empty queue' do
      queue = described_class.new
      expect(queue.delete('x')).to be_nil
    end
  end

  describe '#priorities' do
    it 'returns sorted unique priority values' do
      queue = described_class.new
      queue.push('a', priority: 3)
      queue.push('b', priority: 1)
      queue.push('c', priority: 3)
      queue.push('d', priority: 2)

      expect(queue.priorities).to eq([1, 2, 3])
    end

    it 'returns empty array for empty queue' do
      queue = described_class.new
      expect(queue.priorities).to eq([])
    end

    it 'handles single item' do
      queue = described_class.new
      queue.push('a', priority: 5)
      expect(queue.priorities).to eq([5])
    end

    it 'handles negative and float priorities' do
      queue = described_class.new
      queue.push('a', priority: -1)
      queue.push('b', priority: 2.5)
      queue.push('c', priority: 0)

      expect(queue.priorities).to eq([-1, 0, 2.5])
    end
  end

  describe '#bulk_push' do
    it 'returns self for chaining' do
      queue = described_class.new
      result = queue.bulk_push('a' => 1, 'b' => 2)
      expect(result).to be(queue)
    end

    it 'maintains heap invariant when popping after bulk insert' do
      queue = described_class.new
      queue.bulk_push('c' => 3, 'a' => 1, 'b' => 2, 'd' => 4)

      result = []
      result << queue.pop until queue.empty?
      expect(result).to eq(%w[a b c d])
    end

    it 'raises ArgumentError when not passed a Hash' do
      queue = described_class.new
      expect { queue.bulk_push([%w[a 1]]) }.to raise_error(ArgumentError)
      expect { queue.bulk_push('nope') }.to raise_error(ArgumentError)
    end
  end

  describe '#priority_of' do
    it 'returns the priority of a present item' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 7)

      expect(queue.priority_of('b')).to eq(7)
    end

    it 'returns nil for an absent item' do
      queue = described_class.new
      queue.push('a', priority: 1)

      expect(queue.priority_of('missing')).to be_nil
    end

    it 'returns the first insertion priority for duplicate items' do
      queue = described_class.new
      queue.push('dup', priority: 5)
      queue.push('dup', priority: 10)

      expect(queue.priority_of('dup')).to eq(5)
    end
  end

  describe '#find' do
    it 'returns the first matching [item, priority] pair in priority order' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('c', priority: 3)

      result = queue.find { |_item, priority| priority > 1 }
      expect(result).to eq(['b', 2])
    end

    it 'returns nil when no pair matches the predicate' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)

      expect(queue.find { |_item, priority| priority > 100 }).to be_nil
    end

    it 'short-circuits and does not iterate every entry' do
      queue = described_class.new
      queue.push('a', priority: 1)
      queue.push('b', priority: 2)
      queue.push('c', priority: 3)

      seen = []
      queue.find do |item, priority|
        seen << item
        priority >= 2
      end

      expect(seen).to eq(%w[a b])
    end

    it 'returns an Enumerator when called without a block' do
      queue = described_class.new
      queue.push('a', priority: 1)

      expect(queue.find).to be_a(Enumerator)
    end
  end
end
