//
//  Invoice.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import Foundation
import SwiftData

@Model
final class Invoice {
    @Attribute(.unique)
    var id: UUID

    var invoiceNumber: String
    var issueDate: Date
    var dueDate: Date
    var currencyCode: String
    var statusRawValue: String

    var businessNameSnapshot: String
    var businessEmailSnapshot: String
    var businessPhoneSnapshot: String
    var businessAddressSnapshot: String
    var businessTaxIDSnapshot: String

    var clientDisplayNameSnapshot: String
    var clientCompanyNameSnapshot: String
    var clientEmailSnapshot: String
    var clientPhoneSnapshot: String
    var clientBillingAddressSnapshot: String
    var clientTaxIDSnapshot: String

    var discountPercentage: Decimal
    var taxPercentage: Decimal

    var subtotal: Decimal
    var discountAmount: Decimal
    var taxableAmount: Decimal
    var taxAmount: Decimal
    var total: Decimal

    var notes: String
    var paymentDetails: String
    var paidDate: Date?

    @Relationship(
        deleteRule: .cascade,
        inverse: \InvoiceLineItem.invoice
    )
    var lineItems: [InvoiceLineItem] = []

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        invoiceNumber: String,
        issueDate: Date = Date(),
        dueDate: Date = Date(),
        currencyCode: String = CurrencyCode.idr.rawValue,
        status: InvoiceStatus = .draft,
        businessProfile: BusinessProfile,
        client: Client,
        discountPercentage: Decimal = .zero,
        taxPercentage: Decimal = .zero,
        notes: String = "",
        paymentDetails: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.invoiceNumber = invoiceNumber
        self.issueDate = issueDate
        self.dueDate = dueDate
        self.currencyCode = currencyCode
        self.statusRawValue = status.rawValue

        self.businessNameSnapshot = businessProfile.businessName
        self.businessEmailSnapshot = businessProfile.email
        self.businessPhoneSnapshot = businessProfile.phone
        self.businessAddressSnapshot = businessProfile.address
        self.businessTaxIDSnapshot = businessProfile.taxID

        self.clientDisplayNameSnapshot = client.displayName
        self.clientCompanyNameSnapshot = client.companyName
        self.clientEmailSnapshot = client.email
        self.clientPhoneSnapshot = client.phone
        self.clientBillingAddressSnapshot = client.billingAddress
        self.clientTaxIDSnapshot = client.taxID

        self.discountPercentage = discountPercentage
        self.taxPercentage = taxPercentage

        self.subtotal = .zero
        self.discountAmount = .zero
        self.taxableAmount = .zero
        self.taxAmount = .zero
        self.total = .zero

        self.notes = notes
        self.paymentDetails = paymentDetails
        self.paidDate = nil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

}
