//
//  InvoiceLineItem.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import Foundation
import SwiftData

@Model
final class InvoiceLineItem {
    @Attribute(.unique)
    var id: UUID

    var sortOrder: Int
    var itemDescription: String
    var quantity: Decimal
    var unitPrice: Decimal
    var unit: String
    var sku: String
    var taxPercentage: Decimal

    var sourceCatalogItemID: UUID?

    var invoice: Invoice?

    init(
        id: UUID = UUID(),
        sortOrder: Int = 0,
        itemDescription: String = "",
        quantity: Decimal = .zero,
        unitPrice: Decimal = .zero,
        unit: String = "",
        sku: String = "",
        taxPercentage: Decimal = .zero,
        sourceCatalogItemID: UUID? = nil,
        invoice: Invoice? = nil
    ) {
        self.id = id
        self.sortOrder = sortOrder
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.unit = unit
        self.sku = sku
        self.taxPercentage = taxPercentage
        self.sourceCatalogItemID = sourceCatalogItemID
        self.invoice = invoice

    }
}
