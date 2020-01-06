//
//  UIKitIntegration.swift
//  ArrayDiff
//
//  Created by Adlai Holler on 10/3/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

import UIKit

public extension ArrayDiff {
	/**
	Apply this diff to items in the given section of the collection view.

	This should be called on the main thread inside collectionView.performBatchUpdates
	*/
    func applyToItemsInCollectionView(collectionView: UICollectionView, section: Int) {
        assert(Thread.current.isMainThread)
		// Apply updates in safe order for good measure.
		// Deletes, descending
		// Inserts, ascending
        collectionView.deleteItems(at: removedIndexes.indexPathsInSection(section: section, ascending: false) as [IndexPath])
        collectionView.insertItems(at: insertedIndexes.indexPathsInSection(section: section) as [IndexPath])
	}

	/**
	Apply this diff to rows in the given section of the table view.

	This should be called on the main thread between tableView.beginUpdates and tableView.endUpdates
	*/
    func applyToRowsInTableView(tableView: UITableView, section: Int, rowAnimation: UITableView.RowAnimation) {
        assert(Thread.current.isMainThread)
		// Apply updates in safe order for good measure.
		// Deletes, descending
		// Inserts, ascending
        tableView.deleteRows(at: removedIndexes.indexPathsInSection(section: section, ascending: false) as [IndexPath], with: rowAnimation)
        tableView.insertRows(at: insertedIndexes.indexPathsInSection(section: section) as [IndexPath], with: rowAnimation)
	}

	/**
	Apply this diff to the sections of the table view.

	This should be called on the main thread between tableView.beginUpdates and tableView.endUpdates
	*/
    func applyToSectionsInTableView(tableView: UITableView, rowAnimation: UITableView.RowAnimation) {
        assert(Thread.current.isMainThread)
		// Apply updates in safe order for good measure.
		// Deletes, descending
		// Inserts, ascending
		if removedIndexes.count > 0 {
            tableView.deleteSections(removedIndexes as IndexSet, with: rowAnimation)
		}
		if insertedIndexes.count > 0 {
            tableView.insertSections(insertedIndexes as IndexSet, with: rowAnimation)
		}
	}

	/**
	Apply this diff to the sections of the collection view.

	This should be called on the main thread inside collectionView.performBatchUpdates
	*/
    func applyToSectionsInCollectionView(collectionView: UICollectionView) {
        assert(Thread.current.isMainThread)
		// Apply updates in safe order for good measure.
		// Deletes, descending
		// Inserts, ascending
		if removedIndexes.count > 0 {
            collectionView.deleteSections(removedIndexes as IndexSet)
		}
		if insertedIndexes.count > 0 {
            collectionView.insertSections(insertedIndexes as IndexSet)
		}
	}
}

public extension NestedDiff {
	/**
	Apply this nested diff to the given table view.
	
	This should be called on the main thread between tableView.beginUpdates and tableView.endUpdates
	*/
    func applyToTableView(tableView: UITableView, rowAnimation: UITableView.RowAnimation) {
        assert(Thread.current.isMainThread)
		// Apply updates in safe order for good measure.
		// Item deletes, descending
		// Section deletes
		// Section inserts
		// Item inserts, ascending
		for (oldSection, diffOrNil) in itemDiffs.enumerated() {
			if let diff = diffOrNil {
                tableView.deleteRows(at: diff.removedIndexes.indexPathsInSection(section: oldSection, ascending: false) as [IndexPath], with: rowAnimation)
			}
		}
        sectionsDiff.applyToSectionsInTableView(tableView: tableView, rowAnimation: rowAnimation)
		for (oldSection, diffOrNil) in itemDiffs.enumerated() {
			if let diff = diffOrNil {
                if let newSection = sectionsDiff.newIndexForOldIndex(index: oldSection) {
                    tableView.insertRows(at: diff.insertedIndexes.indexPathsInSection(section: newSection) as [IndexPath], with: rowAnimation)
				} else {
					assertionFailure("Found an item diff for a section that was removed. Wat.")
				}
			}
		}
	}
	
	/**
	Apply this nested diff to the given collection view.
	
	This should be called on the main thread inside collectionView.performBatchUpdates
	*/
    func applyToCollectionView(collectionView: UICollectionView) {
        assert(Thread.current.isMainThread)
		// Apply updates in safe order for good measure. 
		// Item deletes, descending
		// Section deletes
		// Section inserts
		// Item inserts, ascending
		for (oldSection, diffOrNil) in itemDiffs.enumerated() {
			if let diff = diffOrNil {
                collectionView.deleteItems(at: diff.removedIndexes.indexPathsInSection(section: oldSection, ascending: false) as [IndexPath])
			}
		}
        sectionsDiff.applyToSectionsInCollectionView(collectionView: collectionView)
		for (oldSection, diffOrNil) in itemDiffs.enumerated() {
			if let diff = diffOrNil {
                if let newSection = sectionsDiff.newIndexForOldIndex(index: oldSection) {
                    collectionView.insertItems(at: diff.insertedIndexes.indexPathsInSection(section: newSection) as [IndexPath])
				} else {
					assertionFailure("Found an item diff for a section that was removed. Wat.")
				}
			}
		}
	}
}
