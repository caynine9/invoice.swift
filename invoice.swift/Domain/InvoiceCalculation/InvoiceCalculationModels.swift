//
//  InvoiceCalculationModels.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 21/09/26.
//

import Foundation

struct InvoiceLineInput: Equatable {
    let quantity: Decimal
    let unitPrice: Decimal

    var rawAmount: Decimal {
        quantity * unitPrice
    }
}

struct InvoiceCalculationInput: Equatable {
    let lines: [InvoiceLineInput]
    let currency: CurrencyCode
    let discountPercentage: Decimal
    let taxPercentage: Decimal
}

struct InvoiceCalculationResult: Equatable {
    let subtotal: Decimal
    let discountAmount: Decimal
    let taxableAmount: Decimal
    let taxAmount: Decimal
    let total: Decimal
}

enum InvoiceCalculationError: Error, Equatable {
    case negativeQuantity(lineIndex: Int)
    case negativeUnitPrice(lineIndex: Int)
    case invalidDiscountPercentage
    case invalidTaxPercentage
}
