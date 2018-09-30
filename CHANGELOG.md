# 3.1.1 (2018-09-30)

This release updates the project for Swift 4.2 compatibility.

- Disable CountableRange overloads in Swift 4.2 and above (#2, contributed by@kmiloaguilar)
- Fix typo by renaming removeAll(keepCapacity:) to removeAll(keepingCapacity:). The old name is still available through a deprecated compatibility definition.
- Fix deprecation warnings emitted by the Swift 4.1 and 4.2 compilers.

# 3.1.0 (2017-09-07)

This release updates the project to Swift 4 with no functional changes.

Deque is now part of the Attaswift project. The bundle identifiers in the supplied Xcode project have been updated accordingly.

Note that the URL for the package's Git repository has changed; please update your references.

# 3.0.0 (2017-02-07)

This release contains an API-breaking change, so the major version number was bumped. It is, however, very likely that your existing code using Deque will continue to work unchanged.

- The `SubSequence` of `Deque` has been changed from `RandomAccessSlice` to `RangeReplaceableRandomAccessSlice` to adopt newly enforced requirements of `RangeReplaceableCollection`.
- (Xcode project) The macOS deployment target was set to 10.9.
- (Xcode project) Code signing was disabled, following Xcode 8 suggestions.
- (Xcode project) App extensions are now able to link Deque's tvOS framework.

# 2.0.1 (2016-11-08)

This release updates the project for Swift 3.0.1, restoring support for the Swift Package Manager.

# 2.0.0 (2016-09-20)

This release updates the project for Swift 3.0, including adapting the API to the new naming conventions.

Furthermore, collection conformances were cleaned up. `Deque` now implements `RandomAccessCollection`. `Deque.Indices` is now simply a `CountableRange<Int>`, while `Deque.SubSequence` is `RandomAccessSlice<Deque<Element>>`.

# 1.2.0 (2016-06-04)

This is a bugfix release resolving a number of cases where mutating methods failed to copy shared storage, breaking copy-on-write semantics.

# 1.1.0 (2016-03-23)

This release updates the project for Swift 2.2 in Xcode 7.3. There have been no other changes.

# 1.0.0 (2016-02-10)

This is the initial release of Deque.
