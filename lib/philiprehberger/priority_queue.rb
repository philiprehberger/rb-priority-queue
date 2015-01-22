# frozen_string_literal: true

require_relative 'priority_queue/version'

module Philiprehberger
  module PriorityQueue
    class Queue
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
