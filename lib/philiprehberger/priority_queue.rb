# frozen_string_literal: true

require_relative 'priority_queue/version'

module Philiprehberger
  module PriorityQueue
    class Queue
      include Enumerable

      attr_reader :size

      def initialize(mode: :min, &comparator)
        @heap = []
        @size = 0
        @insertion_counter = 0
        @item_index = {}

        @comparator = if comparator
                        comparator
                      elsif mode == :max
                        ->(a, b) { b <=> a }
                      else
                        ->(a, b) { a <=> b }
                      end
      end

      def push(item, priority:)
        entry = [priority, @insertion_counter, item]
        @insertion_counter += 1
        @heap << entry
        @item_index[item] = @size
        @size += 1
        bubble_up(@size - 1)
        self
      end

      def <<(item_with_priority)
        raise ArgumentError, 'Expected a hash with :item and :priority keys' unless item_with_priority.is_a?(Hash)

        push(item_with_priority[:item], priority: item_with_priority[:priority])
      end

      def pop
        return nil if empty?

        swap(0, @size - 1)
        entry = @heap.pop
        @size -= 1
        @item_index.delete(entry[2])
        bubble_down(0) unless empty?
        entry[2]
      end

      def peek
        return nil if empty?

        @heap[0][2]
      end

      def pop_n(n)
        raise ArgumentError, "n must be non-negative, got #{n}" if n.negative?

        result = []
        n.times do
          break if empty?

          result << pop
        end
        result
      end

      def empty?
        @size.zero?
      end

      def change_priority(item, new_priority)
        idx = @item_index[item]
        raise ArgumentError, "Item not found in queue: #{item.inspect}" if idx.nil?

        old_priority = @heap[idx][0]
        @heap[idx] = [new_priority, @heap[idx][1], item]

        cmp = @comparator.call(new_priority, old_priority)
        if cmp.negative?
          bubble_up(idx)
        elsif cmp.positive?
          bubble_down(idx)
        end
        self
      end

      def to_a
        @heap.sort { |a, b| compare_entries(a, b) }.map { |entry| entry[2] }
      end

      def include?(item)
        @item_index.key?(item)
      end

      def clear
        @heap.clear
        @item_index.clear
        @size = 0
        self
      end

      def each(&block)
        return enum_for(:each) unless block

        sorted = @heap.sort { |a, b| compare_entries(a, b) }
        sorted.each { |entry| block.call(entry[2], entry[0]) }
        self
      end

      def push_many(items)
        items.each { |h| push(h[:item], priority: h[:priority]) }
        self
      end

      def peek_priority
        return nil if empty?

        @heap[0][0]
      end

      def drain
        result = []
        result << pop until empty?
        result
      end

      def delete(item)
        idx = @item_index[item]
        return nil if idx.nil?

        if idx == @size - 1
          entry = @heap.pop
          @size -= 1
          @item_index.delete(item)
          return entry[2]
        end

        swap(idx, @size - 1)
        entry = @heap.pop
        @size -= 1
        @item_index.delete(item)
        bubble_up(idx)
        bubble_down(idx)
        entry[2]
      end

      def priorities
        @heap.map { |entry| entry[0] }.uniq.sort
      end

      # Insert multiple items from a hash in one call.
      #
      # @param items_hash [Hash] a mapping of item to priority
      # @return [self] the queue, for chaining
      # @raise [ArgumentError] if +items_hash+ is not a Hash
      def bulk_push(items_hash)
        raise ArgumentError, "Expected a Hash, got #{items_hash.class}" unless items_hash.is_a?(Hash)

        items_hash.each { |item, priority| push(item, priority: priority) }
        self
      end

      # Look up the priority of the first matching item.
      #
      # Uses a linear scan (O(n)) over internal storage and returns
      # the priority associated with the first entry whose item is
      # +==+ to the argument.
      #
      # @param item [Object] the item to look up
      # @return [Object, nil] the priority of the first match, or +nil+ when not present
      def priority_of(item)
        entry = @heap.find { |e| e[2] == item }
        entry.nil? ? nil : entry[0]
      end

      # Find the first [item, priority] pair in priority order for which
      # the block returns a truthy value.
      #
      # @yield [item, priority] pairs in priority order
      # @yieldparam item [Object] the item
      # @yieldparam priority [Object] the priority
      # @return [Array, nil] the first matching +[item, priority]+ pair, or +nil+ when none match
      # @return [Enumerator] if no block is given
      def find(&block)
        return enum_for(:find) unless block

        each do |item, priority|
          return [item, priority] if block.call(item, priority)
        end
        nil
      end

      def merge(other)
        merged = self.class.new(&@comparator)
        @heap.each { |entry| merged.push(entry[2], priority: entry[0]) }
        other.each_entry { |entry| merged.push(entry[2], priority: entry[0]) }
        merged
      end

      protected

      def each_entry(&)
        @heap.each(&)
      end

      private

      def compare_entries(a, b)
        cmp = @comparator.call(a[0], b[0])
        cmp.zero? ? a[1] <=> b[1] : cmp
      end

      def bubble_up(idx)
        while idx.positive?
          parent = (idx - 1) / 2
          break unless compare_entries(@heap[idx], @heap[parent]).negative?

          swap(idx, parent)
          idx = parent
        end
      end

      def bubble_down(idx)
        loop do
          smallest = idx
          left = (2 * idx) + 1
          right = (2 * idx) + 2

          smallest = left if left < @size && compare_entries(@heap[left], @heap[smallest]).negative?
          smallest = right if right < @size && compare_entries(@heap[right], @heap[smallest]).negative?

          break if smallest == idx

          swap(idx, smallest)
          idx = smallest
        end
      end

      def swap(i, j)
        @heap[i], @heap[j] = @heap[j], @heap[i]
        @item_index[@heap[i][2]] = i
        @item_index[@heap[j][2]] = j
      end
    end
  end
end
