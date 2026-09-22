//
//  BusinessProfile.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import Foundation
import SwiftData

@Model
final class BusinessProfile {
    @Attribute(.unique)
    var id: UUID

    var businessName: String
    var email: String
    var phone: String
    var address: String
    var taxID: String
    var defaultCurrencyCode: String

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        businessName: String = "",
        email: String = "",
        phone: String = "",
        address: String = "",
        taxID: String = "",
        defaultCurrencyCode: String = CurrencyCode.idr.rawValue,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.businessName = businessName
        self.email = email
        self.phone = phone
        self.address = address
        self.taxID = taxID
        self.defaultCurrencyCode = defaultCurrencyCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
