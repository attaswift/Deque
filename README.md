# A Double-Ended Queue Type in Swift

[![Swift 4](https://img.shields.io/badge/Swift-4-blue.svg)](https://swift.org)
[![License](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/lorentey/BTree/blob/master/LICENSE.md)
[![Platform](https://img.shields.io/badge/platforms-OS_X%20∙%20iOS%20∙%20watchOS%20∙%20tvOS-blue.svg)](https://developer.apple.com/platforms/)

[![Build Status](https://travis-ci.org/lorentey/Deque.svg?branch=master)](https://travis-ci.org/lorentey/Deque)
[![codecov.io](https://codecov.io/github/lorentey/Deque/coverage.svg?branch=master)](https://codecov.io/github/lorentey/Deque?branch=master)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPod Version](https://img.shields.io/cocoapods/v/Deque.svg)](http://cocoapods.org/pods/Deque)


`Deque<Element>` implements a double-ended queue type.
It's an `Array`-like random-access collection of arbitrary elements that provides efficient O(1) insertion and deletion at both ends.

Deques are structs and implement the same copy-on-write value semantics as standard collection types like 
`Array` and `Dictionary`.

## Compatibility

`Deque` on the `master` branch is compatible with Swift 3.0.

## Note on Performance

As of Swift 3.0, the Swift compiler is not yet able to specialize generics across module boundaries, which puts a 
considerable limit on the performance achievable by collection types imported from external modules. 
(This doesn't impact stdlib, which gets special treatment.)

Relying on `import` will incur a 50-200x slowdown, which may or may not be OK for your project. 
If raw performance is essential, you'll need to put the `Deque` implementation in the same module as your code.
(And don't forget to enable Whole Module Optimization in your release builds.)
I have a couple of ideas that might make this a little more pleasant than it sounds, but for now, there is no
good way around this limitation.
