//
//  DequeTests.swift
//  Deque
//
//  Created by Károly Lőrentey on 2016-01-20.
//  Copyright © 2016–2018 Károly Lőrentey.
//

import XCTest
@testable import Deque

func cast<Source, Target>(_ value: Source) -> Target { return value as! Target }

func XCTAssertElementsEqual<Element: Equatable, S: Sequence>(_ a: S, _ b: [Element], file: StaticString = #file, line: UInt = #line) where S.Element == Element {
    let aa = Array(a)
    if !aa.elementsEqual(b) {
        XCTFail("XCTAssertEqual failed: \"\(aa)\" is not equal to \"\(b)\"", file: cast(file), line: line)
    }
}

// A reference type that consists of an integer value. This makes it easier to check problems with initialization.
private final class T: ExpressibleByIntegerLiteral, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    let value: Int

    init(_ value: Int) {
        self.value = value
    }
    required init(integerLiteral value: IntegerLiteralType) {
        self.value = numericCast(value)
    }

    var description: String { return String(value) }
    var debugDescription: String { return String(value) }
}

private func ==(a: T, b: T) -> Bool {
    return a.value == b.value
}
private func <(a: T, b: T) -> Bool {
    return a.value < b.value
}

private func deque(with elements: [T], wrappedAt wrap: Int) -> Deque<T> {
    var deque = Deque<T>(minimumCapacity: max(15, 2 * elements.count))
    let capacity = deque.capacity
    precondition(wrap > -capacity && wrap < capacity)
    precondition(elements.count < capacity)

    // First, insert dummy items so that the wrap point will be at the desired place
    let desiredStart = wrap < 0 ? -wrap : wrap == 0 ? 0 : capacity - wrap
    (0 ..< desiredStart).forEach { _ in deque.append(-1) }

    // Now insert actual elements at the correct position so that wrapping occurs where desired
    var fillersGone = false
    for e in elements {
        if deque.capacity == deque.count {
            assert(!fillersGone)
            (0 ..< desiredStart).forEach { _ in deque.removeFirst() }
            fillersGone = true
        }
        deque.append(e)
    }
    if !fillersGone {
        (0 ..< desiredStart).forEach { _ in deque.removeFirst() }
    }
    XCTAssertEqual(deque.buffer.start, desiredStart)
    return deque
}


class DequeTests: XCTestCase {
    func testEmptyDeque() {
        let deque = Deque<T>()
        XCTAssertEqual(deque.count, 0)
        XCTAssertTrue(deque.isEmpty)
        XCTAssertElementsEqual(deque, [])
    }

    func testDequeWithSingleItem() {
        let deque = Deque<T>([42])
        XCTAssertEqual(deque.count, 1)
        XCTAssertFalse(deque.isEmpty)
        XCTAssertEqual(deque[0], 42)
        XCTAssertElementsEqual(deque, [42])
    }

    func testDequeWithSomeItems() {
        let deque = Deque<T>([23, 42, 77, 111])
        XCTAssertEqual(deque.count, 4)
        XCTAssertEqual(deque[0], 23)
        XCTAssertEqual(deque[1], 42)
        XCTAssertEqual(deque[2], 77)
        XCTAssertEqual(deque[3], 111)
        XCTAssertElementsEqual(deque, [23, 42, 77, 111])
    }

    func testRepeatedValue() {
        let deque = Deque<T>(repeating: 100, count: 4)
        XCTAssertEqual(deque.count, 4)
        XCTAssertEqual(deque[0], 100)
        XCTAssertEqual(deque[1], 100)
        XCTAssertEqual(deque[2], 100)
        XCTAssertEqual(deque[3], 100)
        XCTAssertElementsEqual(deque, [100, 100, 100, 100])
    }

    func testCapacity() {
        var deque = Deque<T>(minimumCapacity: 100)
        XCTAssertGreaterThanOrEqual(deque.capacity, 100)

        deque.append(contentsOf: [0, 1, 2, 3, 4])

        deque.reserveCapacity(1000)
        XCTAssertGreaterThanOrEqual(deque.capacity, 1000)
        XCTAssertElementsEqual(deque, [0, 1, 2, 3, 4])

        deque.reserveCapacity(100)
        XCTAssertGreaterThanOrEqual(deque.capacity, 1000)
        XCTAssertElementsEqual(deque, [0, 1, 2, 3, 4])

        let capacity = deque.capacity
        let copy = deque
        XCTAssertEqual(copy.capacity, capacity)
        deque.reserveCapacity(5000)
        XCTAssertGreaterThanOrEqual(deque.capacity, 5000)
        XCTAssertEqual(copy.capacity, capacity)
        XCTAssertElementsEqual(deque, [0, 1, 2, 3, 4])
        XCTAssertElementsEqual(copy, [0, 1, 2, 3, 4])
    }

    func testCapacityWrapped() {
        var d = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        let capacity = d.capacity
        d.reserveCapacity(2 * capacity)
        XCTAssertGreaterThanOrEqual(d.capacity, 2 * capacity)
        XCTAssertElementsEqual(d, [0, 1, 2, 3, 4])
    }

    func testIsUnique() {
        var deque = Deque<T>([1, 2, 3, 4])
        XCTAssertTrue(deque.isUnique)

        var copy = deque
        XCTAssertFalse(deque.isUnique)
        XCTAssertFalse(copy.isUnique)

        copy.reserveCapacity(copy.capacity + 1)
        XCTAssertTrue(deque.isUnique)
        XCTAssertTrue(copy.isUnique)
    }

    func testSubscriptSetter() {
        var deque = Deque<T>([23, 42, 77, 111])
        let deque2 = deque

        deque[2] = 66
        XCTAssertElementsEqual(deque, [23, 42, 66, 111])

        XCTAssertElementsEqual(deque2, [23, 42, 77, 111])
    }

    func testCollectionRequirements() {
        var deque = Deque<T>([0, 1, 2, 3, 4, 5])
        XCTAssertEqual(0 ..< 6, deque.indices)
        XCTAssertEqual(3, deque.index(after: 2))
        XCTAssertEqual(1, deque.index(before: 2))
        XCTAssertEqual(5, deque.index(2, offsetBy: 3))

        var i = 2
        deque.formIndex(after: &i)
        XCTAssertEqual(3, i)
        deque.formIndex(before: &i)
        XCTAssertEqual(2, i)
        deque.formIndex(&i, offsetBy: 3)
        XCTAssertEqual(5, i)

        XCTAssertElementsEqual(deque[2 ..< 5], [2, 3, 4])
        deque[2 ..< 5] = Deque([20, 30, 31, 40, 41])[0 ..< 5]
        XCTAssertElementsEqual(deque, [0, 1, 20, 30, 31, 40, 41, 5])
    }

    func testArrayLiteral() {
        let deque: Deque<T> = [1, 7, 3, 2, 6, 5, 4]
        XCTAssertElementsEqual(deque, [1, 7, 3, 2, 6, 5, 4])
    }

    func testCustomPrinting() {
        let deque: Deque<T> = [1, 7, 3, 2, 6, 5, 4]
        XCTAssertEqual(deque.description, "Deque[1, 7, 3, 2, 6, 5, 4]")
        let debug = deque.debugDescription.replacingOccurrences(of: "<[^>]+>", with: "<T>", options: .regularExpression)
        XCTAssertEqual(debug, "Deque.Deque<T>([1, 7, 3, 2, 6, 5, 4])")
    }

    func testReplaceSubrange() {
        var deque: Deque<T> = [1, 7, 3, 2, 6, 5, 4]
        let deque2 = deque

        deque.replaceSubrange(2..<5, with: (10..<15).map { T($0) })
        XCTAssertElementsEqual(deque, [1, 7, 10, 11, 12, 13, 14, 5, 4])

        deque.replaceSubrange(1..<5, with: [])
        XCTAssertElementsEqual(deque, [1, 13, 14, 5, 4])

        deque.replaceSubrange(0..<5, with: [20, 21, 22])
        XCTAssertElementsEqual(deque, [20, 21, 22])

        deque.replaceSubrange(0..<3, with: [1, 2, 3, 4, 5])
        XCTAssertElementsEqual(deque, [1, 2, 3, 4, 5])

        deque.replaceSubrange(0...3, with: [10, 11, 12, 13, 14])
        XCTAssertElementsEqual(deque, [10, 11, 12, 13, 14, 5])

        #if !(swift(>=4.1) || (swift(>=3.3) && !swift(>=4.0)))
        deque.replaceSubrange(ClosedRange(0...3), with: [20, 21, 22])
        XCTAssertElementsEqual(deque, [20, 21, 22, 14, 5])
        #endif

        XCTAssertElementsEqual(deque2, [1, 7, 3, 2, 6, 5, 4])
    }

    func testAppend() {
        var deque: Deque<T> = [1, 2, 3]
        let deque2 = deque

        deque.append(4)
        XCTAssertElementsEqual(deque, [1, 2, 3, 4])

        deque.append(5)
        XCTAssertElementsEqual(deque, [1, 2, 3, 4, 5])

        deque.append(6)
        XCTAssertElementsEqual(deque, [1, 2, 3, 4, 5, 6])

        XCTAssertElementsEqual(deque2, [1, 2, 3])
    }

    func testAppendContentsOf() {
        var deque: Deque<T> = [1, 2, 3]
        let deque2 = deque

        deque.append(contentsOf: (4...6).map { T($0) })
        XCTAssertElementsEqual(deque, (1...6).map { T($0) })

        deque.append(contentsOf: (7...100).map { T($0) })
        XCTAssertElementsEqual(deque, (1...100).map { T($0) })

        // Add a sequence with inexact underestimateCount()
        var i = 101
        deque.append(contentsOf: AnySequence<T> {
            AnyIterator {
                if i > 1000 {
                    return nil
                }
                defer { i += 1 }
                return T(i)
            }
        })
        XCTAssertElementsEqual(deque, (1...1000).map { T($0) })

        XCTAssertElementsEqual(deque2, [1, 2, 3])
    }

    func testInsert() {
        var deque: Deque<T> = [1, 2, 3, 4]
        let deque2 = deque

        deque.insert(10, at: 2)
        XCTAssertElementsEqual(deque, [1, 2, 10, 3, 4])

        deque.insert(11, at: 0)
        XCTAssertElementsEqual(deque, [11, 1, 2, 10, 3, 4])

        deque.insert(12, at: 6)
        XCTAssertElementsEqual(deque, [11, 1, 2, 10, 3, 4, 12])

        XCTAssertElementsEqual(deque2, [1, 2, 3, 4])
    }

    func testInsertContentsOf() {
        var deque: Deque<T> = [1, 2, 3]
        let deque2 = deque

        deque.insert(contentsOf: [], at: 2)
        XCTAssertElementsEqual(deque, [1, 2, 3])

        deque.insert(contentsOf: [10], at: 2)
        XCTAssertElementsEqual(deque, [1, 2, 10, 3])

        deque.insert(contentsOf: [11, 12], at: 0)
        XCTAssertElementsEqual(deque, [11, 12, 1, 2, 10, 3])

        deque.insert(contentsOf: [13, 14, 15], at: 6)
        XCTAssertElementsEqual(deque, [11, 12, 1, 2, 10, 3, 13, 14, 15])

        XCTAssertElementsEqual(deque2, [1, 2, 3])
    }

    func testInsertContentsOfBuffer() {
        let d1 = deque(with: [0, 1, 2, 3], wrappedAt: 0)
        d1.buffer.insert(contentsOf: deque(with: [5, 6, 7], wrappedAt: 0).buffer, at: 2)
        XCTAssertElementsEqual(d1, [0, 1, 5, 6, 7, 2, 3])

        let d2 = deque(with: [0, 1, 2, 3, 4], wrappedAt: -1)
        d2.buffer.insert(contentsOf: deque(with: [5, 6, 7], wrappedAt: 0).buffer, at: 1)
        XCTAssertElementsEqual(d2, [0, 5, 6, 7, 1, 2, 3, 4])

        let d3 = deque(with: [0, 1, 2, 3, 4], wrappedAt: 0)
        d3.buffer.insert(contentsOf: deque(with: [5, 6, 7], wrappedAt: 1).buffer, at: 3)
        XCTAssertElementsEqual(d3, [0, 1, 2, 5, 6, 7, 3, 4])

        let d4 = deque(with: [0, 1, 2, 3, 4], wrappedAt: -1)
        d4.buffer.insert(contentsOf: deque(with: [5, 6, 7], wrappedAt: 2).buffer, at: 1)
        XCTAssertElementsEqual(d4, [0, 5, 6, 7, 1, 2, 3, 4])

        let d5 = deque(with: [0, 1, 2, 3, 4], wrappedAt: -2)
        d5.buffer.insert(contentsOf: deque(with: [5, 6, 7, 8, 9], wrappedAt: 1).buffer, at: 1)
        XCTAssertElementsEqual(d5, [0, 5, 6, 7, 8, 9, 1, 2, 3, 4])

        let d6 = deque(with: [0, 1, 2, 3, 4], wrappedAt: -1)
        d6.buffer.insert(contentsOf: deque(with: [5, 6, 7], wrappedAt: 1).buffer, at: 1)
        XCTAssertElementsEqual(d6, [0, 5, 6, 7, 1, 2, 3, 4])
    }

    func testRemoveAtIndex() {
        var deque: Deque<T> = [1, 2, 3, 4]
        let deque2 = deque

        deque.remove(at: 2)
        XCTAssertElementsEqual(deque, [1, 2, 4])

        deque.remove(at: 0)
        XCTAssertElementsEqual(deque, [2, 4])

        deque.remove(at: 1)
        XCTAssertElementsEqual(deque, [2])

        deque.remove(at: 0)
        XCTAssertElementsEqual(deque, [])

        XCTAssertElementsEqual(deque2, [1, 2, 3, 4])
    }

    func testRemoveFirst() {
        var deque: Deque<T> = [1, 2, 3, 4]
        let deque2 = deque

        XCTAssertEqual(deque.removeFirst(), 1)
        XCTAssertElementsEqual(deque, [2, 3, 4])

        XCTAssertEqual(deque.removeFirst(), 2)
        XCTAssertElementsEqual(deque, [3, 4])

        XCTAssertEqual(deque.removeFirst(), 3)
        XCTAssertElementsEqual(deque, [4])

        XCTAssertEqual(deque.removeFirst(), 4)
        XCTAssertElementsEqual(deque, [])

        XCTAssertElementsEqual(deque2, [1, 2, 3, 4])
    }

    func testRemoveFirstN() {
        var deque: Deque<T> = [1, 2, 3, 4, 5, 6]
        let deque2 = deque

        deque.removeFirst(2)
        XCTAssertElementsEqual(deque, [3, 4, 5, 6])

        deque.removeFirst(0)
        XCTAssertElementsEqual(deque, [3, 4, 5, 6])

        deque.removeFirst(4)
        XCTAssertElementsEqual(deque, [])

        deque.removeFirst(0)
        XCTAssertElementsEqual(deque, [])

        XCTAssertElementsEqual(deque2, [1, 2, 3, 4, 5, 6])
    }

    func testRemoveSubrange() {
        var deque: Deque<T> = [1, 2, 3, 4, 5, 6]
        let deque2 = deque

        deque.removeSubrange(3 ..< 3)
        XCTAssertElementsEqual(deque, [1, 2, 3, 4, 5, 6])

        deque.removeSubrange(3 ..< 5)
        XCTAssertElementsEqual(deque, [1, 2, 3, 6])

        deque.removeSubrange(2 ..< 4)
        XCTAssertElementsEqual(deque, [1, 2])

        deque.removeSubrange(0 ..< 1)
        XCTAssertElementsEqual(deque, [2])

        deque.removeSubrange(0 ..< 1)
        XCTAssertElementsEqual(deque, [])

        deque.removeSubrange(0 ..< 0)
        XCTAssertElementsEqual(deque, [])

        XCTAssertElementsEqual(deque2, [1, 2, 3, 4, 5, 6])
    }

    func testRemoveAllKeepingCapacity() {
        var deque = Deque<T>((0 ..< 1000).map { T($0) })
        let deque2 = deque

        let capacity = deque.capacity
        deque.removeAll(keepingCapacity: true)
        XCTAssertElementsEqual(deque, [])
        XCTAssertEqual(deque.capacity, capacity)

        XCTAssertElementsEqual(deque2, (0 ..< 1000).map { T($0) })
    }

    func testRemoveAllNotKeepingCapacity() {
        var deque = Deque<T>((0 ..< 1000).map { T($0) })
        let deque2 = deque

        let capacity = deque.capacity
        deque.removeAll()
        XCTAssertElementsEqual(deque, [])
        XCTAssertLessThan(deque.capacity, capacity)

        XCTAssertElementsEqual(deque2, (0 ..< 1000).map { T($0) })
    }

    @available(*, deprecated)
    func testDeprecatedRemoveAllKeepCapacity() {
        var deque = Deque<T>((0 ..< 1000).map { T($0) })
        let deque2 = deque

        let capacity = deque.capacity
        deque.removeAll(keepCapacity: true)
        XCTAssertElementsEqual(deque, [])
        XCTAssertEqual(deque.capacity, capacity)

        XCTAssertElementsEqual(deque2, (0 ..< 1000).map { T($0) })
    }

    func testRemoveLast() {
        var deque: Deque<T> = [1, 2, 3]
        let deque2 = deque

        XCTAssertEqual(deque.removeLast(), 3)
        XCTAssertElementsEqual(deque, [1, 2])

        XCTAssertEqual(deque.removeLast(), 2)
        XCTAssertElementsEqual(deque, [1])

        XCTAssertEqual(deque.removeLast(), 1)
        XCTAssertElementsEqual(deque, [])

        XCTAssertElementsEqual(deque2, [1, 2, 3])
    }

    func testRemoveLastN() {
        var deque: Deque<T> = [1, 2, 3, 4, 5, 6, 7]
        let deque2 = deque

        deque.removeLast(0)
        XCTAssertElementsEqual(deque, [1, 2, 3, 4, 5, 6, 7])

        deque.removeLast(2)
        XCTAssertElementsEqual(deque, [1, 2, 3, 4, 5])

        deque.removeLast(1)
        XCTAssertElementsEqual(deque, [1, 2, 3, 4])

        deque.removeLast(4)
        XCTAssertElementsEqual(deque, [])

        XCTAssertElementsEqual(deque2, [1, 2, 3, 4, 5, 6, 7])
    }

    func testPopFirst() {
        var deque: Deque<T> = [1, 2, 3]
        let deque2 = deque

        XCTAssertEqual(deque.popFirst(), 1)
        XCTAssertElementsEqual(deque, [2, 3])

        XCTAssertEqual(deque.popFirst(), 2)
        XCTAssertElementsEqual(deque, [3])

        XCTAssertEqual(deque.popFirst(), 3)
        XCTAssertElementsEqual(deque, [])

        XCTAssertEqual(deque.popFirst(), nil)

        XCTAssertElementsEqual(deque2, [1, 2, 3])
    }

    func testPopLast() {
        var deque: Deque<T> = [1, 2, 3]
        let deque2 = deque

        XCTAssertEqual(deque.popLast(), 3)
        XCTAssertElementsEqual(deque, [1, 2])

        XCTAssertEqual(deque.popLast(), 2)
        XCTAssertElementsEqual(deque, [1])

        XCTAssertEqual(deque.popLast(), 1)
        XCTAssertElementsEqual(deque, [])

        XCTAssertEqual(deque.popFirst(), nil)

        XCTAssertElementsEqual(deque2, [1, 2, 3])
    }

    func testPrepend() {
        var deque: Deque<T> = [1, 2, 3]
        let deque2 = deque

        deque.prepend(-1)
        XCTAssertElementsEqual(deque, [-1, 1, 2, 3])

        deque.prepend(-2)
        XCTAssertElementsEqual(deque, [-2, -1, 1, 2, 3])

        deque.prepend(-3)
        XCTAssertElementsEqual(deque, [-3, -2, -1, 1, 2, 3])

        XCTAssertElementsEqual(deque2, [1, 2, 3])
    }

    func testEquality() {
        let a = Deque<T>([])
        let b = Deque<T>([1, 2, 3])
        let c = b
        let d = Deque<T>([1, 2, 3])
        let e = Deque<T>([1, 2, 4])

        XCTAssertTrue(a == a)
        XCTAssertTrue(b == c)
        XCTAssertTrue(b == d)
        XCTAssertFalse(a == b)
        XCTAssertFalse(b == e)

        XCTAssertFalse(a != a)
        XCTAssertFalse(b != d)
        XCTAssertTrue(a != b)
    }

    func testInsertionCases() {
        func testInsert(_ elements: [T], wrappedAt wrap: Int, insertionIndex: Int, insertedElements: [T], file: StaticString = #file, line: UInt = #line) {
            var d = deque(with: elements, wrappedAt: wrap)
            let orig = d

            var expected = elements
            expected.insert(contentsOf: insertedElements, at: insertionIndex)
            d.insert(contentsOf: insertedElements, at: insertionIndex)

            XCTAssertElementsEqual(d, expected, file: file, line: line)
            XCTAssertElementsEqual(orig, elements, file: file, line: line)
        }
        // These tests exercise all cases in DequeBuffer.openGapAt(_:, length:).
        testInsert([0, 1, 2, 3, 4], wrappedAt: 0, insertionIndex: 3, insertedElements: [5, 6])
        testInsert([0, 1, 2, 3, 4, 5, 6], wrappedAt: 7, insertionIndex: 4, insertedElements: [7, 8])
        testInsert([0, 1, 2, 3, 4, 5, 6], wrappedAt: 7, insertionIndex: 4, insertedElements: [7, 8, 9, 10])
        testInsert([0, 1, 2, 3, 4, 5, 6], wrappedAt: 6, insertionIndex: 4, insertedElements: [7])
        testInsert([0, 1, 2, 3, 4, 5, 6], wrappedAt: 6, insertionIndex: 4, insertedElements: [7, 8, 9, 10])

        testInsert([0, 1, 2, 3, 4], wrappedAt: -2, insertionIndex: 2, insertedElements: [5, 6])
        testInsert([0, 1, 2, 3, 4], wrappedAt: -1, insertionIndex: 2, insertedElements: [5, 6])
        testInsert([0, 1, 2, 3, 4], wrappedAt: 0, insertionIndex: 2, insertedElements: [5, 6, 7, 8])
        testInsert([0, 1, 2, 3, 4], wrappedAt: 1, insertionIndex: 2, insertedElements: [5])
        testInsert([0, 1, 2, 3, 4], wrappedAt: 1, insertionIndex: 2, insertedElements: [5, 6, 7, 8])
    }


    func testRemovalCases() {
        func testRemove(_ elements: [T], wrappedAt wrap: Int, range: Range<Int>, file: StaticString = #file, line: UInt = #line) {
            var d = deque(with: elements, wrappedAt: wrap)
            let orig = d
            var expected = elements
            expected.removeSubrange(range)
            d.removeSubrange(range)

            XCTAssertElementsEqual(d, expected, file: file, line: line)
            XCTAssertElementsEqual(orig, elements)
        }
        // These tests exercise all cases in DequeBuffer.removeSubrange(_:).
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 0, range: 7..<8)
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 8, range: 7..<10)
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 8, range: 7..<9)
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 10, range: 7..<9)
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 9, range: 7..<8)

        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 0, range: 1..<2)
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 3, range: 1..<5)
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 3, range: 2..<4)
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 1, range: 2..<4)
        testRemove([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], wrappedAt: 2, range: 3..<4)

    }

    func testForEachSimple() {
        let d1 = deque(with: [0, 1, 2, 3, 4], wrappedAt: 0)
        var r1: [T] = []
        d1.forEach { i in r1.append(i) }
        XCTAssertEqual(r1, [0, 1, 2, 3, 4])
    }

    func testForEachWrapped() {
        let d2 = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        var r2: [T] = []
        d2.forEach { i in r2.append(i) }
        XCTAssertEqual(r2, [0, 1, 2, 3, 4])
    }

    func testForEachMutating() {
        var d = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        let orig = d
        var r: [T] = []
        d.forEach { i in
            r.append(i)
            d.append(T(d.count))
        }
        XCTAssertEqual(r, [0, 1, 2, 3, 4])
        XCTAssertElementsEqual(d, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        XCTAssertElementsEqual(orig, [0, 1, 2, 3, 4])
    }

    func testMap() {
        let d = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        XCTAssertElementsEqual(d.map { 2 * $0.value }, [0, 2, 4, 6, 8])
    }

    func testFlatMapOptional() {
        let d = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        let r = d.flatMap { $0.value % 2 == 0 ? $0.value : nil }
        XCTAssertElementsEqual(r, [0, 2, 4])
    }

    func testFlatMapSequence() {
        let d = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        let r = d.flatMap { 0...$0.value }
        XCTAssertElementsEqual(r, [0, 0, 1, 0, 1, 2, 0, 1, 2, 3, 0, 1, 2, 3, 4])
    }

    func testFilter() {
        let d = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        let r = d.filter { $0.value % 2 == 0 }
        XCTAssertElementsEqual(r, [0, 2, 4])
    }

    func testReduce() {
        let d = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        let sum = d.reduce(0) { $0 + $1.value }
        XCTAssertEqual(sum, 10)
    }

    func testIndexConversion() {
        let d = deque(with: [0, 1, 2, 3, 4], wrappedAt: 2)
        XCTAssertEqual(d.buffer.bufferIndex(forDequeIndex: 0), d.capacity - 2)
        XCTAssertEqual(d.buffer.bufferIndex(forDequeIndex: 1), d.capacity - 1)
        XCTAssertEqual(d.buffer.bufferIndex(forDequeIndex: 2), 0)
        XCTAssertEqual(d.buffer.bufferIndex(forDequeIndex: 3), 1)
        XCTAssertEqual(d.buffer.bufferIndex(forDequeIndex: 4), 2)

        XCTAssertEqual(d.buffer.dequeIndex(forBufferIndex: d.capacity - 2), 0)
        XCTAssertEqual(d.buffer.dequeIndex(forBufferIndex: d.capacity - 1), 1)
        XCTAssertEqual(d.buffer.dequeIndex(forBufferIndex: 0), 2)
        XCTAssertEqual(d.buffer.dequeIndex(forBufferIndex: 1), 3)
        XCTAssertEqual(d.buffer.dequeIndex(forBufferIndex: 2), 4)
    }
}
