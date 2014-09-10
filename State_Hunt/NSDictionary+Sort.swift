//
//  NSDictionary+Sort.swift
//
//  Thanks to David:  http://stackoverflow.com/a/24090641/1693173
//

import Foundation

extension Dictionary {

    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sorted(isOrderedBefore)
    }
    
    // Slower because of a lot of lookups, but probably takes less memory
    // (this is equivalent to Pascals answer in an generic extension)
    func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys() {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
    
    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValueFaster(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        var array = Array(self)

        array.sort {
            let (lk, lv) = $0
            let (rk, rv) = $1
            return isOrderedBefore(lv, rv)
        }

       return array.map {
            let (k, v) = $0
            return k
        }
    }

}