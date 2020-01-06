
import Foundation

// MARK: NSRange <-> Range<Int> conversion

public extension NSRange {
    var range: Range<Int> {
		return location..<location+length
	}
	
    init(range: Range<Int>) {
        self.init()
        location = range.startIndex
		length = range.endIndex - range.startIndex
	}
}

// MARK: NSIndexSet -> [NSIndexPath] conversion

public extension NSIndexSet {
	/**
	Returns an array of NSIndexPaths that correspond to these indexes in the given section.
	
	When reporting changes to table/collection view, you can improve performance by sorting
	deletes in descending order and inserts in ascending order.
	*/
    func indexPathsInSection(section: Int, ascending: Bool = true) -> [NSIndexPath] {
		var result: [NSIndexPath] = []
		result.reserveCapacity(count)
        enumerate(options: ascending ? [] : .reverse) { index, _ in
			result.append(NSIndexPath(indexes: [section, index], length: 2))
		}
		return result
	}
}

// MARK: NSIndexSet support

public extension Array {
	
    subscript (indexes: NSIndexSet) -> [Element] {
		var result: [Element] = []
		result.reserveCapacity(indexes.count)
        indexes.enumerateRanges { nsRange, _ in
			result += self[nsRange.range]
		}
		return result
	}
	
    mutating func removeAtIndexes(indexSet: NSIndexSet) {
        indexSet.enumerateRanges(options: .reverse) { nsRange, _ in
            self.removeSubrange(nsRange.range)
		}
	}
	
    mutating func insertElements(newElements: [Element], atIndexes indexes: NSIndexSet) {
		assert(indexes.count == newElements.count)
		var i = 0
        indexes.enumerateRanges { range, _ in
            self.insert(contentsOf: newElements[i..<i+range.length], at: range.location)
			i += range.length
		}
	}
}
