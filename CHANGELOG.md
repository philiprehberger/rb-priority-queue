# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-21

### Added
- Initial release
- Binary heap `Queue` with min-heap (default) and max-heap modes
- `push(item, priority:)` and `pop` with O(log n) performance
- `peek` to view the highest-priority item without removal
- `change_priority(item, new_priority)` to update priorities in-place
- `to_a` for sorted array extraction
- `merge(other)` to combine two priority queues
- Custom comparator support via block
