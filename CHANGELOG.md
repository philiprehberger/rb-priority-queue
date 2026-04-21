# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-21

### Added
- `Queue#bulk_push` — insert multiple items from a hash
- `Queue#priority_of` — lookup priority by item
- `Queue#find` — priority-ordered search

### Fixed
- `bug_report.yml` — require Ruby version; add Gem version input per guide

## [0.3.0] - 2026-04-15

### Added
- `Queue#pop_n(n)` to pop up to `n` items in priority order and return them as an array; returns `[]` for empty queues or `n == 0`; raises `ArgumentError` for negative `n`

## [0.2.1] - 2026-04-15

### Fixed
- Set gemspec authors to `Philip Rehberger` and email to `me@philiprehberger.com`
- Update `required_ruby_version` to `>= 3.1.0` to match gemspec template

## [0.2.0] - 2026-04-03

### Added
- Include `Enumerable` module with `each` yielding `[item, priority]` pairs in priority order
- `push_many(items)` for batch pushing from array of hashes
- `peek_priority` to return just the top priority value
- `drain` to pop all items and return as array in priority order
- `delete(item)` to remove a specific item by value
- `priorities` to return sorted array of unique priority values

## [0.1.11] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.10] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.9] - 2026-03-26

### Changed
- Add Sponsor badge to README
- Fix License section format


## [0.1.8] - 2026-03-24

### Changed
- Add Usage subsections and expand API table in README

## [0.1.7] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.6] - 2026-03-24

### Fixed
- Standardize README API section to table format
- Fix Installation section quote style to double quotes

## [0.1.5] - 2026-03-23

### Fixed
- Standardize README to match template (installation order, code fences, license section, one-liner format)
- Update gemspec summary to match README description

## [0.1.4] - 2026-03-22

### Changed
- Fix README badges to match template (Tests, Gem Version, License)

## [0.1.3] - 2026-03-22

### Added
- Expanded test suite from 23 to 30+ examples covering large queues, change_priority edge cases, clear-and-re-add, to_a order, merge interleaving, negative/float priorities, and FIFO tie-breaking

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
