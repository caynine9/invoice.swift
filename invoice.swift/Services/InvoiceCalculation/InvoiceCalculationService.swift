//
//  InvoiceCalculationService.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import Foundation

enum InvoiceCalculationServiceError: Error, Equatable {
    case unsupportedCurrencyCode(String)
}

enum InvoiceCalculationService {
    static func calculate(invoice: Invoice) throws -> InvoiceCalculationResult {
        guard let currency = CurrencyCode(rawValue: invoice.currencyCode) else {
            throw InvoiceCalculationServiceError.unsupportedCurrencyCode(
                invoice.currencyCode
            )
        }

        let sortedItems = invoice.lineItems.sorted {
            $0.sortOrder < $1.sortOrder
        }

        let input = InvoiceCalculationInput(
            lines: sortedItems.map { item in
                InvoiceLineInput(
                    quantity: item.quantity,
                    unitPrice: item.unitPrice
                )
            },
            currency: currency,
            discountPercentage: invoice.discountPercentage,
            taxPercentage: invoice.taxPercentage
        )

        return try InvoiceCalculator.calculate(input)
    }

    static func apply(
        _ result: InvoiceCalculationResult,
        to invoice: Invoice,
        updatedAt: Date = Date()
    ) {
        invoice.subtotal = result.subtotal
        invoice.discountAmount = result.discountAmount
        invoice.taxableAmount = result.taxableAmount
        invoice.taxAmount = result.taxAmount
        invoice.total = result.total
        invoice.updatedAt = updatedAt
    }
}
