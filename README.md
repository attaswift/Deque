# A Double-Ended Queue Type in Swift

[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-blue.svg)](https://swift.org)
[![License](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/attaswift/BTree/blob/master/LICENSE.md)
[![Platform](https://img.shields.io/badge/platforms-OS_X%20∙%20iOS%20∙%20watchOS%20∙%20tvOS-blue.svg)](https://developer.apple.com/platforms/)

[![Build Status](https://travis-ci.org/attaswift/Deque.svg?branch=master)](https://travis-ci.org/attaswift/Deque)
[![codecov.io](https://codecov.io/github/attaswift/Deque/coverage.svg?branch=master)](https://codecov.io/github/attaswift/Deque?branch=master)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPod Version](https://img.shields.io/cocoapods/v/Deque.svg)](http://cocoapods.org/pods/Deque)


| :warning: WARNING          |
|:---------------------------|
| This package has been obsoleted by the [`Deque` type](https://github.com/apple/swift-collections/blob/main/Documentation/Deque.md) in the [Swift Collections package](https://github.com/apple/swift-collections). Using this older package in not recommended in new Swift code; I expect the double-ended queue implementation in Swift Collections to perform better and to provide a richer interface. It is also being actively maintained/updated by the Swift Standard Library team.|

`Deque<Element>` implements a double-ended queue type.
It's an `Array`-like random-access collection of arbitrary elements that provides efficient O(1) insertion and deletion at both ends.

Deques are structs and implement the same copy-on-write value semantics as standard collection types like 
`Array` and `Dictionary`.

## Compatibility

`Deque` on the `master` branch is compatible with Swift 4.2.

## Installation

### CocoaPods

If you use CocoaPods, you can start using `Deque` by including it as a dependency in your `Podfile`:

```
pod 'Deque', '~> 3.1'
```

### Carthage

For Carthage, add the following line to your `Cartfile`:

```
github "attaswift/Deque" ~> 3.1
```

### Swift Package Manager

For Swift Package Manager, add `SipHash` to the dependencies list inside your `Package.swift` file:

```
import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .Package(url: "https://github.com/attaswift/SipHash.git", from: "3.1.1")
    ]
)
```
