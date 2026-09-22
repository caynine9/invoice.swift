//
//  InvoiceStatus.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import Foundation

enum InvoiceStatus: String, Codable, CaseIterable {
    case draft
    case unpaid
    case paid
    case overdue
    case cancelled
}
