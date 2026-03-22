# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::PriorityQueue do
  it 'has a version number' do
    expect(Philiprehberger::PriorityQueue::VERSION).not_to be_nil
  end

  describe Philiprehberger::PriorityQueue::Queue do
    describe '#initialize' do
      it 'creates a min-heap by default' do
        pq = described_class.new
        expect(pq).to be_empty
      end

      it 'creates a max-heap' do
        pq = described_class.new(mode: :max)
        expect(pq).to be_empty
      end

      it 'raises on invalid mode' do
        expect { described_class.new(mode: :invalid) }.to raise_error(Philiprehberger::PriorityQueue::Error)
      end

      it 'accepts a custom comparator' do
        pq = described_class.new { |a, b| a[:priority] <=> b[:priority] }
        expect(pq).to be_empty
      end
    end

    describe 'min-heap' do
      it 'pops the lowest priority first' do
        pq = described_class.new
        pq.push('high', priority: 10)
        pq.push('low', priority: 1)
        pq.push('mid', priority: 5)

        expect(pq.pop).to eq('low')
        expect(pq.pop).to eq('mid')
        expect(pq.pop).to eq('high')
      end

      it 'peeks at the lowest priority item' do
        pq = described_class.new
        pq.push('high', priority: 10)
        pq.push('low', priority: 1)

        expect(pq.peek).to eq('low')
        expect(pq.size).to eq(2)
      end
    end

    describe 'max-heap' do
      it 'pops the highest priority first' do
        pq = described_class.new(mode: :max)
        pq.push('high', priority: 10)
        pq.push('low', priority: 1)
        pq.push('mid', priority: 5)

        expect(pq.pop).to eq('high')
        expect(pq.pop).to eq('mid')
        expect(pq.pop).to eq('low')
      end

      it 'peeks at the highest priority item' do
        pq = described_class.new(mode: :max)
        pq.push('low', priority: 1)
        pq.push('high', priority: 10)

        expect(pq.peek).to eq('high')
      end
    end

    describe '#push' do
      it 'returns self for chaining' do
        pq = described_class.new
        expect(pq.push('a', priority: 1)).to be(pq)
      end

      it 'increases size' do
        pq = described_class.new
        pq.push('a', priority: 1)
        pq.push('b', priority: 2)
        expect(pq.size).to eq(2)
      end
    end

    describe '#pop' do
      it 'returns nil for empty queue' do
        pq = described_class.new
        expect(pq.pop).to be_nil
      end

      it 'decreases size' do
        pq = described_class.new
        pq.push('a', priority: 1)
        pq.pop
        expect(pq.size).to eq(0)
      end

      it 'maintains heap invariant after many operations' do
        pq = described_class.new
        values = (1..100).to_a.shuffle
        values.each { |v| pq.push(v, priority: v) }

        result = []
        result << pq.pop until pq.empty?
        expect(result).to eq((1..100).to_a)
      end
    end

    describe '#peek' do
      it 'returns nil for empty queue' do
        pq = described_class.new
        expect(pq.peek).to be_nil
      end

      it 'does not remove the item' do
        pq = described_class.new
        pq.push('a', priority: 1)
        pq.peek
        expect(pq.size).to eq(1)
      end
    end

    describe '#size' do
      it 'returns 0 for empty queue' do
        pq = described_class.new
        expect(pq.size).to eq(0)
      end
    end

    describe '#empty?' do
      it 'returns true for empty queue' do
        pq = described_class.new
        expect(pq.empty?).to be true
      end

      it 'returns false for non-empty queue' do
        pq = described_class.new
        pq.push('a', priority: 1)
        expect(pq.empty?).to be false
      end
    end

    describe '#change_priority' do
      it 'updates priority and re-sorts' do
        pq = described_class.new
        pq.push('a', priority: 10)
        pq.push('b', priority: 5)
        pq.change_priority('a', 1)

        expect(pq.pop).to eq('a')
        expect(pq.pop).to eq('b')
      end

      it 'raises when item not found' do
        pq = described_class.new
        expect { pq.change_priority('missing', 1) }.to raise_error(Philiprehberger::PriorityQueue::Error)
      end

      it 'handles priority increase in min-heap' do
        pq = described_class.new
        pq.push('a', priority: 1)
        pq.push('b', priority: 5)
        pq.change_priority('a', 10)

        expect(pq.pop).to eq('b')
        expect(pq.pop).to eq('a')
      end
    end

    describe '#to_a' do
      it 'returns items in priority order' do
        pq = described_class.new
        pq.push('c', priority: 3)
        pq.push('a', priority: 1)
        pq.push('b', priority: 2)

        expect(pq.to_a).to eq(%w[a b c])
      end

      it 'returns empty array for empty queue' do
        pq = described_class.new
        expect(pq.to_a).to eq([])
      end

      it 'does not modify the original queue' do
        pq = described_class.new
        pq.push('a', priority: 1)
        pq.to_a
        expect(pq.size).to eq(1)
      end
    end

    describe '#merge' do
      it 'combines two queues' do
        pq1 = described_class.new
        pq1.push('a', priority: 1)
        pq1.push('c', priority: 3)

        pq2 = described_class.new
        pq2.push('b', priority: 2)

        pq1.merge(pq2)
        expect(pq1.size).to eq(3)
        expect(pq1.pop).to eq('a')
        expect(pq1.pop).to eq('b')
        expect(pq1.pop).to eq('c')
      end

      it 'returns self' do
        pq1 = described_class.new
        pq2 = described_class.new
        expect(pq1.merge(pq2)).to be(pq1)
      end
    end

    describe 'duplicate priorities' do
      it 'handles items with the same priority' do
        pq = described_class.new
        pq.push('a', priority: 1)
        pq.push('b', priority: 1)
        pq.push('c', priority: 1)

        results = [pq.pop, pq.pop, pq.pop]
        expect(results).to contain_exactly('a', 'b', 'c')
      end
    end

    describe 'single element' do
      it 'handles push and pop of a single element' do
        pq = described_class.new
        pq.push('only', priority: 42)
        expect(pq.peek).to eq('only')
        expect(pq.pop).to eq('only')
        expect(pq.empty?).to be true
      end
    end
  end
end
