//
//  InvoiceCalculationServiceTests.swift
//  invoice.swiftTests
//

import Foundation
import Testing

@testable import invoice_swift

@MainActor
struct InvoiceCalculationServiceTests {
    @Test
    func calculatesInvoiceFromPersistedLineItems() throws {
        let invoice = makeInvoice(currency: .usd)
        invoice.discountPercentage = decimal("10")
        invoice.taxPercentage = decimal("11")

        invoice.lineItems = [
            InvoiceLineItem(
                sortOrder: 1,
                itemDescription: "Second item",
                quantity: decimal("1"),
                unitPrice: decimal("50.00"),
                invoice: invoice
            ),
            InvoiceLineItem(
                sortOrder: 0,
                itemDescription: "First item",
                quantity: decimal("2"),
                unitPrice: decimal("100.00"),
                invoice: invoice
            )
        ]

        let result = try InvoiceCalculationService.calculate(invoice: invoice)

        #expect(result.subtotal == decimal("250.00"))
        #expect(result.discountAmount == decimal("25.00"))
        #expect(result.taxableAmount == decimal("225.00"))
        #expect(result.taxAmount == decimal("24.75"))
        #expect(result.total == decimal("249.75"))
    }

    @Test
    func appliesCalculationResultToInvoiceTotals() throws {
        let invoice = makeInvoice(currency: .eur)
        invoice.lineItems = [
            InvoiceLineItem(
                quantity: decimal("3"),
                unitPrice: decimal("12.345"),
                invoice: invoice
            )
        ]

        let result = try InvoiceCalculationService.calculate(invoice: invoice)
        let updateDate = Date(timeIntervalSince1970: 1_000)

        InvoiceCalculationService.apply(
            result,
            to: invoice,
            updatedAt: updateDate
        )

        #expect(invoice.subtotal == decimal("37.04"))
        #expect(invoice.discountAmount == Decimal.zero)
        #expect(invoice.taxableAmount == decimal("37.04"))
        #expect(invoice.taxAmount == Decimal.zero)
        #expect(invoice.total == decimal("37.04"))
        #expect(invoice.updatedAt == updateDate)
    }

    @Test
    func rejectsUnsupportedCurrencyCode() {
        let invoice = makeInvoice(currency: .usd)
        invoice.currencyCode = "JPY"

        do {
            _ = try InvoiceCalculationService.calculate(invoice: invoice)
            Issue.record("Expected an unsupported currency code to be rejected")
        } catch let error as InvoiceCalculationServiceError {
            #expect(error == .unsupportedCurrencyCode("JPY"))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func propagatesInvalidLineItemWithoutChangingPersistedTotals() {
        let invoice = makeInvoice(currency: .usd)
        invoice.subtotal = decimal("123.45")
        invoice.total = decimal("123.45")
        invoice.lineItems = [
            InvoiceLineItem(
                quantity: decimal("-1"),
                unitPrice: decimal("100.00"),
                invoice: invoice
            )
        ]

        do {
            _ = try InvoiceCalculationService.calculate(invoice: invoice)
            Issue.record("Expected a negative quantity to be rejected")
        } catch let error as InvoiceCalculationError {
            #expect(error == .negativeQuantity(lineIndex: 0))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(invoice.subtotal == decimal("123.45"))
        #expect(invoice.total == decimal("123.45"))
    }

    @Test
    func calculatesInvoiceWithoutLineItemsAsZero() throws {
        let invoice = makeInvoice(currency: .idr)

        let result = try InvoiceCalculationService.calculate(invoice: invoice)

        #expect(result.subtotal == Decimal.zero)
        #expect(result.discountAmount == Decimal.zero)
        #expect(result.taxableAmount == Decimal.zero)
        #expect(result.taxAmount == Decimal.zero)
        #expect(result.total == Decimal.zero)
    }

    private func makeInvoice(currency: CurrencyCode) -> Invoice {
        let businessProfile = BusinessProfile(businessName: "Test Business")
        let client = Client(displayName: "Test Client")

        return Invoice(
            invoiceNumber: "INV-TEST-001",
            currencyCode: currency.rawValue,
            businessProfile: businessProfile,
            client: client
        )
    }

    private func decimal(_ value: String) -> Decimal {
        Decimal(
            string: value,
            locale: Locale(identifier: "en_US_POSIX")
        )!
    }
}
