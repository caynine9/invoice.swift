//
//  CatalogItem.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import Foundation
import SwiftData

@Model
final class CatalogItem {
    @Attribute(.unique)
    var id: UUID

    var name: String
    var itemDescription: String
    var sku: String
    var unit: String

    var defaultPrice: Decimal
    var defaultTaxPercentage: Decimal

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        itemDescription: String = "",
        sku: String = "",
        unit: String = "",
        defaultPrice: Decimal = .zero,
        defaultTaxPercentage: Decimal = .zero,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.sku = sku
        self.unit = unit
        self.defaultPrice = defaultPrice
        self.defaultTaxPercentage = defaultTaxPercentage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
