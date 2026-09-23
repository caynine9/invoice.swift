//
//  InvoiceLineItemEditorRow.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import SwiftData
import SwiftUI

struct InvoiceLineItemEditorRow: View {
    @Bindable var item: InvoiceLineItem
    
    let onChanged: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Description", text: $item.itemDescription)
            
            HStack {
                TextField(
                    "Quantity",
                    value: $item.quantity,
                    format: .number
                )
                .frame(minWidth: 75)
                
                TextField("Unit", text: $item.unit)
                    .frame(minWidth: 75)
                
                TextField(
                    "Unit price",
                    value: $item.unitPrice,
                    format: .number
                )
                .frame(minWidth: 120)
            }
            
            HStack {
                Spacer()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Remove Item", systemImage: "trash")
                }
            }
        }
        .padding(.vertical, 6)
        .onChange(of: item.itemDescription) { _, _ in onChanged() }
        .onChange(of: item.quantity) { _, _ in onChanged() }
        .onChange(of: item.unit) { _, _ in onChanged() }
        .onChange(of: item.unitPrice) { _, _ in onChanged() }
    }
}
