
import Foundation

public struct ArrayDiff {
	static var debugLogging = false
	
	/// The indexes in the old array of the items that were kept
	public let commonIndexes: NSIndexSet
	/// The indexes in the old array of the items that were removed
	public let removedIndexes: NSIndexSet
	/// The indexes in the new array of the items that were inserted
	public let insertedIndexes: NSIndexSet
	
	/// Returns nil if the item was inserted
	public func oldIndexForNewIndex(index: Int) -> Int? {
        if insertedIndexes.contains(index) { return nil }
		
		var result = index
        result -= insertedIndexes.countOfIndexes(in: NSMakeRange(0, index))
        result += removedIndexes.countOfIndexes(in: NSMakeRange(0, result + 1))
		return result
	}
	
	/// Returns nil if the item was deleted
	public func newIndexForOldIndex(index: Int) -> Int? {
        if removedIndexes.contains(index) { return nil }
		
		var result = index
        let deletedBefore = removedIndexes.countOfIndexes(in: NSMakeRange(0, index))
		result -= deletedBefore
		var insertedAtOrBefore = 0
		for i in insertedIndexes {
			if i <= result  {
				insertedAtOrBefore += 1
				result += 1
			} else {
				break
			}
		}
		if ArrayDiff.debugLogging {
			print("***Old -> New\n Removed \(removedIndexes)\n Inserted \(insertedIndexes)\n \(index) - \(deletedBefore) + \(insertedAtOrBefore) = \(result)\n")
		}
		
		return result
	}
    
    /**
     Returns true iff there are no changes to the items in this diff
     */
    public var isEmpty: Bool {
        return removedIndexes.count == 0 && insertedIndexes.count == 0
    }
}

public extension Array {
	
    func diff(other: Array<Element>, elementsAreEqual: ((Element, Element) -> Bool)) -> ArrayDiff {
		var lengths: [[Int]] = Array<Array<Int>>(
            unsafeUninitializedCapacity: count + 1,
            initializingWithunsafeUninitializedCapacityinitializingWith: Array<Int>(
                unsafeUninitializedCapacity: other.count + 1,
                initializingWith: 0)
		)

		for i in (0...count).reversed() {
			for j in (0...other.count).reversed() {
				if i == count || j == other.count {
					lengths[i][j] = 0
				} else if elementsAreEqual(self[i], other[j]) {
					lengths[i][j] = 1 + lengths[i+1][j+1]
				} else {
                    lengths[i][j] = Swift.max(lengths[i+1][j], lengths[i][j+1])
				}
			}
		}
		let commonIndexes = NSMutableIndexSet()
		var i = 0, j = 0

		while i < count && j < other.count {
			if elementsAreEqual(self[i], other[j]) {
                commonIndexes.add(i)
				i += 1
				j += 1
			} else if lengths[i+1][j] >= lengths[i][j+1] {
				i += 1
			} else {
				j += 1
			}
		}
		
        let removedIndexes = NSMutableIndexSet(indexesIn: NSMakeRange(0, count))
        removedIndexes.remove(commonIndexes as IndexSet)
		
		let commonObjects = self[commonIndexes]
		let addedIndexes = NSMutableIndexSet()
		i = 0
		j = 0
		
		while i < commonObjects.count || j < other.count {
			if i < commonObjects.count && j < other.count && elementsAreEqual (commonObjects[i], other[j]) {
				i += 1
				j += 1
			} else {
                addedIndexes.add(j)
				j += 1
			}
		}
		
		return ArrayDiff(commonIndexes: commonIndexes, removedIndexes: removedIndexes, insertedIndexes: addedIndexes)
	}
}

public extension Array where Element: Equatable {
    func diff(other: Array<Element>) -> ArrayDiff {
        return self.diff(other: other, elementsAreEqual: { $0 == $1 })
	}
}
