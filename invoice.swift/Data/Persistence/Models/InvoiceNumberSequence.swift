//
//  InvoiceNumberSequence.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import Foundation
import SwiftData

@Model
final class InvoiceNumberSequence {
    @Attribute(.unique)
    var year: Int

    var nextValue: Int

    init(year: Int, nextValue: Int = 1) {
        self.year = year
        self.nextValue = nextValue
    }
}
