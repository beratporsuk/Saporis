//
//  RateLimiter.swift
//  Saporis
//
//  Created by Berat PORSUK on 22.08.2025.
//

import Foundation

final class RateLimiter {
    private var lastFire = Date.distantPast
    private let minInterval: TimeInterval
    init(minInterval: TimeInterval) { self.minInterval = minInterval }
    func canFire() -> Bool {
        let now = Date()
        if now.timeIntervalSince(lastFire) >= minInterval {
            lastFire = now; return true
        }
        return false
    }
}

final class BudgetManager: ObservableObject {
    @Published var dailyRemaining: Int
    @Published var degradeMode: Bool = false

    init(dailyBudget: Int = 1000) { self.dailyRemaining = dailyBudget }
    func consume(_ n: Int = 1) { dailyRemaining = max(0, dailyRemaining - n); updateDegrade() }
    private func updateDegrade() { degradeMode = dailyRemaining < 100 }
}
