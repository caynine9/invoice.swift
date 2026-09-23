//
//  InvoiceSnapshotTests.swift
//  invoice.swiftTests
//

import Foundation
import SwiftData
import Testing

@testable import invoice_swift

@MainActor
struct InvoiceSnapshotTests {
    @Test
    func copiesBusinessAndClientDataWhenInvoiceIsCreated() {
        let businessProfile = BusinessProfile(
            businessName: "Northwind Studio",
            email: "hello@northwind.example",
            phone: "+1 555 0100",
            address: "500 Howard Street",
            taxID: "BUS-001"
        )

        let client = Client(
            displayName: "Leo Lee",
            companyName: "Leo Lee Design",
            email: "leo@example.com",
            phone: "+1 555 0200",
            billingAddress: "524 Lake Drive",
            taxID: "CLIENT-001"
        )

        let invoice = Invoice(
            invoiceNumber: "INV-2026-001",
            businessProfile: businessProfile,
            client: client
        )

        #expect(invoice.businessNameSnapshot == "Northwind Studio")
        #expect(invoice.businessEmailSnapshot == "hello@northwind.example")
        #expect(invoice.businessTaxIDSnapshot == "BUS-001")
        #expect(invoice.clientDisplayNameSnapshot == "Leo Lee")
        #expect(invoice.clientCompanyNameSnapshot == "Leo Lee Design")
        #expect(invoice.clientEmailSnapshot == "leo@example.com")
        #expect(invoice.clientTaxIDSnapshot == "CLIENT-001")
    }

    @Test
    func sourceChangesDoNotModifyHistoricalInvoiceSnapshot() {
        let businessProfile = BusinessProfile(
            businessName: "Original Business",
            email: "original-business@example.com"
        )

        let client = Client(
            displayName: "Original Client",
            companyName: "Original Company",
            email: "original-client@example.com"
        )

        let invoice = Invoice(
            invoiceNumber: "INV-2026-002",
            businessProfile: businessProfile,
            client: client
        )

        businessProfile.businessName = "Updated Business"
        businessProfile.email = "updated-business@example.com"
        client.displayName = "Updated Client"
        client.companyName = "Updated Company"
        client.email = "updated-client@example.com"

        #expect(invoice.businessNameSnapshot == "Original Business")
        #expect(invoice.businessEmailSnapshot == "original-business@example.com")
        #expect(invoice.clientDisplayNameSnapshot == "Original Client")
        #expect(invoice.clientCompanyNameSnapshot == "Original Company")
        #expect(invoice.clientEmailSnapshot == "original-client@example.com")
    }

    @Test
    func catalogChangesDoNotModifyCopiedInvoiceLineItem() {
        let catalogItem = CatalogItem(
            name: "Backend development",
            itemDescription: "API implementation",
            sku: "DEV-001",
            unit: "project",
            defaultPrice: decimal("4200.00"),
            defaultTaxPercentage: decimal("10")
        )

        let lineItem = InvoiceLineItem(
            itemDescription: catalogItem.itemDescription,
            quantity: decimal("1"),
            unitPrice: catalogItem.defaultPrice,
            unit: catalogItem.unit,
            sku: catalogItem.sku,
            taxPercentage: catalogItem.defaultTaxPercentage,
            sourceCatalogItemID: catalogItem.id
        )

        catalogItem.itemDescription = "Updated API implementation"
        catalogItem.defaultPrice = decimal("5000.00")
        catalogItem.defaultTaxPercentage = decimal("11")

        #expect(lineItem.itemDescription == "API implementation")
        #expect(lineItem.unitPrice == decimal("4200.00"))
        #expect(lineItem.taxPercentage == decimal("10"))
        #expect(lineItem.sourceCatalogItemID == catalogItem.id)
    }

    @Test
    func deletingInvoiceCascadesToLineItems() throws {
        let schema = Schema([
            BusinessProfile.self,
            Client.self,
            CatalogItem.self,
            Invoice.self,
            InvoiceLineItem.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: schema,
            configurations: configuration
        )
        let context = ModelContext(container)

        let businessProfile = BusinessProfile(businessName: "Test Business")
        let client = Client(displayName: "Test Client")
        let invoice = Invoice(
            invoiceNumber: "INV-2026-003",
            businessProfile: businessProfile,
            client: client
        )
        let lineItem = InvoiceLineItem(
            itemDescription: "Test service",
            quantity: decimal("1"),
            unitPrice: decimal("100.00"),
            invoice: invoice
        )

        invoice.lineItems.append(lineItem)

        context.insert(businessProfile)
        context.insert(client)
        context.insert(invoice)
        context.insert(lineItem)
        try context.save()

        context.delete(invoice)
        try context.save()

        let remainingLineItems = try context.fetch(
            FetchDescriptor<InvoiceLineItem>()
        )

        #expect(remainingLineItems.isEmpty)
    }

    private func decimal(_ value: String) -> Decimal {
        Decimal(
            string: value,
            locale: Locale(identifier: "en_US_POSIX")
        )!
    }
}
