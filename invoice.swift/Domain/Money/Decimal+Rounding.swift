//
//  Decimal+Rounding.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 21/09/26.
//

import Foundation

extension Decimal {
    func rounded(
        scale: Int,
        mode: Decimal.RoundingMode = .plain
    ) -> Decimal {
        var source = self
        var result = Decimal.zero

        NSDecimalRound(
            &result,
            &source,
            scale,
            mode
        )

        return result
    }
}
