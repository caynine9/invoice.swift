//
//  InvoiceStatusService.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 24/09/26.
//

import Foundation
import SwiftData

enum InvoiceStatusServiceError: LocalizedError {
    case cannotSetOverdueDirectly
    case invalidTransition(from: InvoiceStatus, to: InvoiceStatus)
    
    var errorDescription: String? {
        switch self {
        case .cannotSetOverdueDirectly:
            return "Overdue is calculated from the invoice due date."
            
        case let .invalidTransition(from, to):
            return """
                Cannot change status from \
                \(from.rawValue.capitalized) to \(to.rawValue.capitalized).
                """
        }
    }
}

enum InvoiceStatusService {
    static func effectiveStatus(
        for invoice: Invoice,
        asOf now: Date = Date(),
        calendar: Calendar = .current
    ) -> InvoiceStatus {
        InvoiceStatusPolicy.effectiveStatus(
            storedStatusRawValue: invoice.statusRawValue,
            dueDate: invoice.dueDate,
            asOf: now,
            calendar: calendar
        )
    }
    
    static func allowedTransitions(
        for invoice: Invoice,
        asOf now: Date = Date(),
        calendar: Calendar = .current
    ) -> [InvoiceStatus] {
        let currentStatus = effectiveStatus(for: invoice, asOf: now, calendar: calendar)
        return InvoiceStatusPolicy.allowedTransitions(from: currentStatus)
    }
    
    static func transition(
        _ invoice: Invoice,
        to newStatus: InvoiceStatus,
        at now: Date = Date(),
        calendar: Calendar = .current
    ) throws {
        guard newStatus != .overdue else {
            throw InvoiceStatusServiceError.cannotSetOverdueDirectly
        }
        
        let currentStatus = effectiveStatus(
            for: invoice,
            asOf: now,
            calendar: calendar
        )
        
        guard currentStatus != newStatus else {
            return
        }
        
        let allowedStatuses = InvoiceStatusPolicy.allowedTransitions(from: currentStatus)
        
        guard allowedStatuses.contains(newStatus) else {
            throw InvoiceStatusServiceError.invalidTransition(from: currentStatus, to: newStatus)
        }
        
        invoice.statusRawValue = newStatus.rawValue
        
        if newStatus == .paid {
            invoice.paidDate = invoice.paidDate ?? now
        } else {
            invoice.paidDate = nil
        }
        
        invoice.updatedAt = now
    }
}
