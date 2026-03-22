# frozen_string_literal: true

require_relative 'priority_queue/version'

module Philiprehberger
  module PriorityQueue
    class Error < StandardError; end

    # A binary heap priority queue supporting min-heap, max-heap, and custom comparators
    #
    # @example Min-heap (default)
    #   pq = Queue.new
    #   pq.push('low', priority: 1)
    #   pq.push('high', priority: 10)
    #   pq.pop  # => "low"
    #
    # @example Max-heap
    #   pq = Queue.new(mode: :max)
    #   pq.push('low', priority: 1)
    #   pq.push('high', priority: 10)
    #   pq.pop  # => "high"
    class Queue
      # Create a new priority queue
      #
      # @param mode [Symbol] :min (default) or :max
      # @yield [a, b] optional custom comparator block
      # @raise [Error] if mode is invalid
      def initialize(mode: :min, &comparator)
        unless %i[min max].include?(mode)
          raise Error, "Invalid mode: #{mode}. Use :min or :max"
        end

        @heap = []
        @comparator = comparator || default_comparator(mode)
      end

      # Push an item onto the queue with a given priority
      #
      # @param item [Object] the item to enqueue
      # @param priority [Numeric] the priority value
      # @return [self]
      def push(item, priority: 0)
        entry = { item: item, priority: priority }
        @heap << entry
        bubble_up(@heap.length - 1)
        self
      end

      # Remove and return the highest-priority item
      #
      # @return [Object, nil] the item, or nil if empty
      def pop
        return nil if @heap.empty?

        swap(0, @heap.length - 1)
        entry = @heap.pop
        bubble_down(0) unless @heap.empty?
        entry[:item]
      end

      # Return the highest-priority item without removing it
      #
      # @return [Object, nil] the item, or nil if empty
      def peek
        return nil if @heap.empty?

        @heap[0][:item]
      end

      # Return the number of items in the queue
      #
      # @return [Integer]
      def size
        @heap.length
      end

      # Check if the queue is empty
      #
      # @return [Boolean]
      def empty?
        @heap.empty?
      end

      # Update the priority of an existing item
      #
      # @param item [Object] the item to update
      # @param new_priority [Numeric] the new priority
      # @return [self]
      # @raise [Error] if the item is not found
      def change_priority(item, new_priority)
        index = @heap.index { |e| e[:item] == item }
        raise Error, 'Item not found in queue' if index.nil?

        @heap[index][:priority] = new_priority
        bubble_up(index)
        bubble_down(index)
        self
      end

      # Return all items as a sorted array
      #
      # @return [Array] items in priority order
      def to_a
        clone = Queue.new(&@comparator)
        @heap.each { |entry| clone.push(entry[:item], priority: entry[:priority]) }

        result = []
        result << clone.pop until clone.empty?
        result
      end

      # Merge another priority queue into this one
      #
      # @param other [Queue] the queue to merge
      # @return [self]
      def merge(other)
        other.each_entry { |item, priority| push(item, priority: priority) }
        self
      end

      # @api private
      def each_entry
        @heap.each { |entry| yield entry[:item], entry[:priority] }
      end

      private

      def default_comparator(mode)
        case mode
        when :min then ->(a, b) { a[:priority] <=> b[:priority] }
        when :max then ->(a, b) { b[:priority] <=> a[:priority] }
        end
      end

      def bubble_up(index)
        while index.positive?
          parent = (index - 1) / 2
          break unless @comparator.call(@heap[index], @heap[parent]).negative?

          swap(index, parent)
          index = parent
        end
      end

      def bubble_down(index)
        size = @heap.length

        loop do
          smallest = index
          left = 2 * index + 1
          right = 2 * index + 2

          smallest = left if left < size && @comparator.call(@heap[left], @heap[smallest]).negative?
          smallest = right if right < size && @comparator.call(@heap[right], @heap[smallest]).negative?

          break if smallest == index

          swap(index, smallest)
          index = smallest
        end
      end

      def swap(i, j)
        @heap[i], @heap[j] = @heap[j], @heap[i]
      end
    end
  end
end
