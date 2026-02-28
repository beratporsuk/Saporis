//
//  TTLCache.swift
//  Saporis
//
//  Created by Berat PORSUK on 22.08.2025.
//

import Foundation


final class TTLCache<Key: Hashable, Value> {
    private struct Entry { let key: Key; let value: Value; let expiry: Date }
    private var dict: [Key: Entry] = [:]
    private let capacity: Int

    init(capacity: Int = 200) { self.capacity = capacity }

    func set(_ value: Value, for key: Key, ttl: TimeInterval) {
        cleanup()
        dict[key] = Entry(key: key, value: value, expiry: Date().addingTimeInterval(ttl))
        if dict.count > capacity, let first = dict.keys.first {
            dict.removeValue(forKey: first)
        }
    }

    func get(_ key: Key) -> Value? {
        guard let e = dict[key], e.expiry > Date() else { dict[key] = nil; return nil }
        return e.value
    }

    private func cleanup() {
        let now = Date()
        dict = dict.filter { $0.value.expiry > now }
    }
}

