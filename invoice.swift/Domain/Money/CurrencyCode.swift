//
//  CurrencyCode.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 21/09/26.
//

import Foundation

enum CurrencyCode: String, CaseIterable, Codable, Identifiable {
    case idr = "IDR"
    case usd = "USD"
    case eur = "EUR"
    case sgd = "SGD"
    case myr = "MYR"

    var id: String {
        rawValue
    }

    var fractionDigits: Int {
        switch self {
        case .idr:
            return 0

        case .usd, .eur, .sgd, .myr:
            return 2
        }
    }
}
