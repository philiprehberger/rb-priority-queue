# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2026-03-22

### Fixed

- Fix CHANGELOG header wording
- Add bug_tracker_uri to gemspec

## [0.1.0] - 2026-03-22

### Added

- Binary heap priority queue with min-heap and max-heap modes
- Custom comparator support via block
- `push`, `pop`, `peek` operations with O(log n) performance
- `<<` operator for hash-based push syntax
- `change_priority` to update item priority with re-heapification
- `merge` to combine two queues into a new queue
- `to_a` to return items sorted by priority
- `include?`, `clear`, `size`, `empty?` utility methods
- FIFO tie-breaking for equal priorities
