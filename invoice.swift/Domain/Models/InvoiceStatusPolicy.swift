//
//  InvoiceStatusPolicy.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import Foundation

enum InvoiceStatusPolicy {
    static func effectiveStatus(
        storedStatusRawValue: String,
        dueDate: Date,
        asOf now: Date = Date(),
        calendar: Calendar = .current
    ) -> InvoiceStatus {
        guard let storedStatus = InvoiceStatus(
            rawValue: storedStatusRawValue
        ) else {
            return .draft
        }
        
        switch storedStatus {
        case .draft, .paid, .cancelled:
            return storedStatus
            
        case .unpaid, .overdue:
            let today = calendar.startOfDay(for: now)
            let dueDay = calendar.startOfDay(for: dueDate)
            
            return dueDay < today ? .overdue : .unpaid
        }
    }
    
    static func allowedTransitions(
        from status: InvoiceStatus
    ) -> [InvoiceStatus] {
        switch status {
        case .draft:
            return [.unpaid, .paid, .cancelled]
            
        case .unpaid, .overdue:
            return [.draft, .paid, .cancelled]
            
        case .paid:
            return [.unpaid]
            
        case .cancelled:
            return [.draft]
        }
    }
}
