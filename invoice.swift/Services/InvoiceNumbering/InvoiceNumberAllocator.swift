//
//  InvoiceNumberAllocator.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import Foundation
import SwiftData

enum InvoiceNumberAllocatorError: Error {
    case invalidSequence
    case sequenceExhausted
}

@MainActor
enum InvoiceNumberAllocator {
    static func allocate(year: Int, in context: ModelContext) throws -> String {
        let descriptor = FetchDescriptor<InvoiceNumberSequence>(
            predicate: #Predicate { $0.year == year }
        )

        let matches = try context.fetch(descriptor)

        let sequence: InvoiceNumberSequence

        if let existingSequence = matches.first {
            sequence = existingSequence
        } else {
            sequence = InvoiceNumberSequence(year: year)
            context.insert(sequence)
        }

        let invoices = try context.fetch(FetchDescriptor<Invoice>())
        let usedNumbers = Set(invoices.map(\.invoiceNumber))

        var numberToTry = sequence.nextValue

        while true {
            guard numberToTry > 0 else {
                throw InvoiceNumberAllocatorError.invalidSequence
            }

            guard numberToTry < Int.max else {
                throw InvoiceNumberAllocatorError.sequenceExhausted
            }

            let candidate = try InvoiceNumberPolicy.format(
                year: year,
                sequence: numberToTry
            )

            if !usedNumbers.contains(candidate) {
                sequence.nextValue = numberToTry + 1
                try context.save()
                return candidate
            }

            numberToTry += 1
        }
    }
}
