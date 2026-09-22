//
//  invoice_swiftTests.swift
//  invoice.swiftTests
//
//  Created by Muhammad Tantowi Jauhari on 21/09/26.
//

import Foundation
import Testing

@testable import invoice_swift

struct InvoiceCalculatorTests {
    @Test
    func calculatesUSDWithDiscountAndTax() throws {
        let input = InvoiceCalculationInput(
            lines: [
                InvoiceLineInput(
                    quantity: decimal("2"),
                    unitPrice: decimal("100.00")
                ),
                InvoiceLineInput(
                    quantity: decimal("1"),
                    unitPrice: decimal("50.00")
                )
            ],
            currency: .usd,
            discountPercentage: decimal("10"),
            taxPercentage: decimal("11")
        )

        let result = try InvoiceCalculator.calculate(input)

        #expect(result.subtotal == decimal("250.00"))
        #expect(result.discountAmount == decimal("25.00"))
        #expect(result.taxableAmount == decimal("225.00"))
        #expect(result.taxAmount == decimal("24.75"))
        #expect(result.total == decimal("249.75"))
    }

    @Test
    func roundsIDRToWholeRupiah() throws {
        let input = InvoiceCalculationInput(
            lines: [
                InvoiceLineInput(
                    quantity: decimal("1"),
                    unitPrice: decimal("1000.6")
                )
            ],
            currency: .idr,
            discountPercentage: Decimal.zero,
            taxPercentage: Decimal.zero
        )

        let result = try InvoiceCalculator.calculate(input)

        #expect(result.subtotal == decimal("1001"))
        #expect(result.total == decimal("1001"))
    }

    @Test
    func supportsEURWithTwoFractionDigits() throws {
        let input = InvoiceCalculationInput(
            lines: [
                InvoiceLineInput(
                    quantity: decimal("3"),
                    unitPrice: decimal("12.345")
                )
            ],
            currency: .eur,
            discountPercentage: Decimal.zero,
            taxPercentage: Decimal.zero
        )

        let result = try InvoiceCalculator.calculate(input)

        #expect(result.subtotal == decimal("37.04"))
        #expect(result.total == decimal("37.04"))
    }

    @Test
    func allowsZeroQuantityAndZeroPrice() throws {
        let input = InvoiceCalculationInput(
            lines: [
                InvoiceLineInput(
                    quantity: Decimal.zero,
                    unitPrice: decimal("100.00")
                ),
                InvoiceLineInput(
                    quantity: decimal("2"),
                    unitPrice: Decimal.zero
                )
            ],
            currency: .usd,
            discountPercentage: Decimal.zero,
            taxPercentage: Decimal.zero
        )

        let result = try InvoiceCalculator.calculate(input)

        #expect(result.subtotal == Decimal.zero)
        #expect(result.total == Decimal.zero)
    }

    @Test
    func rejectsNegativeQuantity() throws {
        let input = InvoiceCalculationInput(
            lines: [
                InvoiceLineInput(
                    quantity: decimal("-1"),
                    unitPrice: decimal("100.00")
                )
            ],
            currency: .usd,
            discountPercentage: Decimal.zero,
            taxPercentage: Decimal.zero
        )

        do {
            _ = try InvoiceCalculator.calculate(input)
            Issue.record("Expected negative quantity to be rejected")
        } catch let error as InvoiceCalculationError {
            #expect(error == .negativeQuantity(lineIndex: 0))
        }
    }

    @Test
    func rejectsPercentageOutsideZeroToOneHundred() throws {
        let input = InvoiceCalculationInput(
            lines: [],
            currency: .usd,
            discountPercentage: decimal("100.01"),
            taxPercentage: Decimal.zero
        )

        do {
            _ = try InvoiceCalculator.calculate(input)
            Issue.record("Expected invalid discount percentage to be rejected")
        } catch let error as InvoiceCalculationError {
            #expect(error == .invalidDiscountPercentage)
        }
    }

    private func decimal(_ value: String) -> Decimal {
        Decimal(
            string: value,
            locale: Locale(identifier: "en_US_POSIX")
        )!
    }
}
