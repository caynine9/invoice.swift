//
//  Client.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import Foundation
import SwiftData

@Model
final class Client {
    @Attribute(.unique)
    var id: UUID

    var displayName: String
    var companyName: String
    var email: String
    var phone: String
    var billingAddress: String
    var taxID: String
    var notes: String

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String = "",
        companyName: String = "",
        email: String = "",
        phone: String = "",
        billingAddress: String = "",
        taxID: String = "",
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.companyName = companyName
        self.email = email
        self.phone = phone
        self.billingAddress = billingAddress
        self.taxID = taxID
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
