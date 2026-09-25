//
//  InvoiceDuplicationService.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 24/09/26.
//

import Foundation
import SwiftData

@MainActor
enum InvoiceDuplicationService {
    static func duplicate(
        _ source: Invoice,
        in context: ModelContext,
        now: Date = Date()
    ) throws -> Invoice {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        
        let year = calendar.component(.year, from: now)
        
        let newNumber = try InvoiceNumberAllocator.allocate(year: year, in: context)
        
        let newDueDate = calendar.date(
            byAdding: .day,
            value: 14,
            to: now
        ) ?? now
        
        let duplicate = Invoice(
            duplicating: source,
            invoiceNumber: newNumber,
            issueDate: now,
            dueDate: newDueDate,
            now: now
        )
        
        context.insert(duplicate)
        
        for sourceItem in source.lineItems.sorted(by: { $0.sortOrder < $1.sortOrder }
        ) {
            let copiedItem = InvoiceLineItem(
                sortOrder: sourceItem.sortOrder,
                itemDescription: sourceItem.itemDescription,
                quantity: sourceItem.quantity,
                unitPrice: sourceItem.unitPrice,
                unit: sourceItem.unit,
                sku: sourceItem.sku,
                taxPercentage: sourceItem.taxPercentage,
                sourceCatalogItemID: sourceItem.sourceCatalogItemID,
                invoice: duplicate
            )
            
            context.insert(copiedItem)
        }
        
        do {
            let result = try InvoiceCalculationService.calculate(invoice: duplicate)
            
            InvoiceCalculationService.apply(
                result,
                to:duplicate,
                updatedAt: now
            )
            
            try context.save()
            return duplicate
        } catch {
            context.delete(duplicate)
            throw error
        }
    }
}
