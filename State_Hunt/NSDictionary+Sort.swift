//
//  NSDictionary+Sort.swift
//
//  Thanks to David:
//     http://stackoverflow.com/questions/24090016/sort-dictionary-by-values-in-swift
//

import Foundation

extension Dictionary {

    func sortedKeys(isOrderedBefore:(KeyType,KeyType) -> Bool) -> [KeyType] {
        return sort(Array(self.keys), isOrderedBefore)
    }
    
    // Slower because of a lot of lookups, but probably takes less memory
    // (this is equivalent to Pascals answer in an generic extension)
    func keysSortedByValue(isOrderedBefore:(ValueType, ValueType) -> Bool) -> [KeyType] {
        return sortedKeys() {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
    
    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValueFaster(isOrderedBefore:(ValueType, ValueType) -> Bool) -> [KeyType] {
        return sort(Array(self), {
            let (lk, lv) = $0
            let (rk, rv) = $1
            return isOrderedBefore(lv, rv)
            }).map({
                let (k, v) = $0
                return k
                })
    }

}