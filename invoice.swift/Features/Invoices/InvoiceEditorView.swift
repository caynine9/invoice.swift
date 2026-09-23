//
//  InvoiceEditorView.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import Foundation
import SwiftData
import SwiftUI

struct InvoiceEditorView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var invoice: Invoice
    
    @State private var shwoingError = false
    @State private var errorMessage = ""
    @State private var isReordering = false
    
    private var sortedLineItems: [InvoiceLineItem] {
        invoice.lineItems.sorted {
            $0.sortOrder = $1.sortOrder
        }
    }
    
    private var clientName: String {
        let companyName = invoice.clientCompanyNameSnapshot
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if companyName.isEmpty {
            return invoice.clientDisplayNameSnapshot
        }
        
        return companyName
    }
    
    var body: some View {
        HSplitView {
            invoiceDetails
                .frame(minWidth: 300)
            
            itemsAndTotals
                .frame(minWidth: 420)
        }
        .navigationTitle(invoice.invoiceNumber)
        .onChange(of: invoice.discountPercentage) { _, _ in
            recalculateTotals()
        }
        .onChange(of: invoice.taxPercentage) { _, _ in
            recalculateTotals()
        }
        .onChange(of: invoice.issueDate) { _, _ in
            invoice.updatedAt = Date()
        }
        .onChange(of: invoice.dueDate) { _, _ in
            invoice.updatedAt = Date()
        }
        .onChange(of: invoice.notes) { _, _ in
            invoice.updatedAt = Date()
        }
        .onDisappear(perform: saveChanges)
        .alert("Invoice error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var invoiceDetails: some View {
        Form {
            Section("Invoice") {
                LabeledContent("Number") {
                    Text(invoice.invoiceNumber)
                        .textSelection(.enabled)
                }
                
                DatePicker(
                    "Issue date",
                    selection: $invoice.issueDate,
                    displayedComponents: .date
                )
            }
        }
    }
}
