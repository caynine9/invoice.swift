//
//  InvoiceCalculator.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 21/09/26.
//

import Foundation

enum InvoiceCalculator {
    static func calculate(
        _ input: InvoiceCalculationInput
    ) throws -> InvoiceCalculationResult {
        guard input.discountPercentage >= Decimal.zero,
              input.discountPercentage <= Decimal(100) else {
            throw InvoiceCalculationError.invalidDiscountPercentage
        }

        guard input.taxPercentage >= Decimal.zero,
              input.taxPercentage <= Decimal(100) else {
            throw InvoiceCalculationError.invalidTaxPercentage
        }

        let scale = input.currency.fractionDigits

        var subtotal = Decimal.zero

        for (index, line) in input.lines.enumerated() {
            guard line.quantity >= Decimal.zero else {
                throw InvoiceCalculationError.negativeQuantity(lineIndex: index)
            }

            guard line.unitPrice >= Decimal.zero else {
                throw InvoiceCalculationError.negativeUnitPrice(lineIndex: index)
            }

            let lineAmount = line.rawAmount.rounded(scale: scale)
            subtotal += lineAmount

        }

        subtotal = subtotal.rounded(scale: scale)

        let discountAmount = (
            subtotal * input.discountPercentage / Decimal(100)
        ).rounded(scale: scale)

        let taxableAmount = (
            subtotal - discountAmount
        ).rounded(scale: scale)

        let taxAmount = (
            taxableAmount * input.taxPercentage / Decimal(100)
        ).rounded(scale: scale)

        let total = (
            taxableAmount + taxAmount
        ).rounded(scale: scale)

        return InvoiceCalculationResult(subtotal: subtotal, discountAmount: discountAmount, taxableAmount: taxableAmount, taxAmount: taxAmount, total: total)

    }
}
