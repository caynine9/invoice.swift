//
//  InvoiceNumberPolicy.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import Foundation

enum InvoiceNumberPolicyError: Error {
    case invalidYear
    case invalidSequence
}

struct InvoiceNumberPolicy {
    static func format(year: Int, sequence: Int) throws -> String {
        guard year > 0 else {
            throw InvoiceNumberPolicyError.invalidYear
        }

        guard sequence > 0 else {
            throw InvoiceNumberPolicyError.invalidSequence
        }

        let paddedSequence = String(format: "%04d", sequence)
        return "INV-\(year)-\(paddedSequence)"
    }
}
