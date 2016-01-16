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
end
