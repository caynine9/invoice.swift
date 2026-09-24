//
//  InvoicesView.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import SwiftData
import SwiftUI

struct InvoicesView: View {
    @Query(sort: \Invoice.updatedAt, order: .reverse)
    private var invoices: [Invoice]
    
    @Query(sort: \Client.displayName)
    private var clients: [Client]
    
    @Query(sort: \BusinessProfile.createdAt)
    private var businessProfiles: [BusinessProfile]
    
    @State private var showingNewInvoice = false
    
    var body: some View {
        NavigationStack {
            invoiceList
                .navigationTitle("Invoices")
                .toolbar {
                    Button {
                        showingNewInvoice = true
                    } label: {
                        Label("New Invoice", systemImage: "plus")
                    }
                }
                .sheet(isPresented: $showingNewInvoice) {
                    NewInvoiceSheet(
                        businessProfile: businessProfiles.first,
                        clients: clients
                    )
                }
        }
    }
    
    private var invoiceList: some View {
        List {
            if invoices.isEmpty {
                ContentUnavailableView(
                    "No invoices yet",
                    systemImage: "doc.text",
                    description: Text("Use + to create an invoice.")
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(invoices, id: \.id) { invoice in
                    NavigationLink {
                        InvoiceEditorView(invoice: invoice)
                    } label: {
                        InvoiceListRow(invoice: invoice)
                    }
                }
            }
        }
    }
}
