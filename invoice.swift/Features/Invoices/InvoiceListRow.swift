//
//  InvoiceListRow.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import SwiftUI

struct InvoiceListRow: View {
    let invoice: Invoice
    
    private var clientName: String {
        if invoice.clientCompanyNameSnapshot.isEmpty {
            return invoice.clientDisplayNameSnapshot
        }
        
        return invoice.clientCompanyNameSnapshot
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.invoiceNumber)
                    .font(.headline)
                
                Text(clientName)
                    .foregroundStyle(.secondary)
                
                Text(
                    invoice.issueDate.formatted(
                        date: .abbreviated,
                        time: .omitted
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(
                    invoice.total.formatted(
                        .currency(code: invoice.currencyCode)
                    )
                )
                
                Text(invoice.statusRawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 4)
    }
}
