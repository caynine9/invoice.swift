//
//  InvoicesView.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import SwiftData
import SwiftUI

struct InvoicesView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Invoice.updatedAt, order: .reverse)
    private var invoices: [Invoice]
    
    @Query(sort: \Client.displayName)
    private var clients: [Client]
    
    @Query(sort: \BusinessProfile.createdAt)
    private var businessProfiles: [BusinessProfile]
    
    @State private var showingNewInvoice = false
    
    @State private var pendingDeletionInvoiceID: UUID?
    @State private var showingDeleteConfirmation = false
    @State private var showingActionError = false
    @State private var actionErrorMessage = ""
    
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
                .alert(
                    "Invoice action failed",
                    isPresented: $showingActionError
                ) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(actionErrorMessage)
                }
                .confirmationDialog(
                    "Delete this invoice?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Invoice", role: .destructive) {
                        if let invoice = pendingDeletionInvoice {
                            deleteInvoice(invoice)
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {
                        pendingDeletionInvoiceID = nil
                    }
                } message: {
                    Text("This also deletes the invoice's line items.")
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
                    .contextMenu {
                        Button {
                            duplicateInvoice(invoice)
                        } label: {
                            Label("Duplicate Invoice", systemImage: "plus.square.on.square")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            pendingDeletionInvoiceID = invoice.id
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete Invoice", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    private var pendingDeletionInvoice: Invoice? {
        guard let pendingDeletionInvoiceID else {
            return nil
        }
        
        return invoices.first { $0.id == pendingDeletionInvoiceID }
    }
    
    private func duplicateInvoice(_ invoice: Invoice) {
        do {
            try InvoiceDuplicationService.duplicate(
                invoice,
                in: modelContext
            )
        } catch {
            actionErrorMessage =
                "The duplicate could not be saved. An invoice number may be skipped. \(error.localizedDescription)"
            showingActionError = true
        }
    }

    private func deleteInvoice(_ invoice: Invoice) {
        modelContext.delete(invoice)

        do {
            try modelContext.save()
            pendingDeletionInvoiceID = nil
        } catch {
            actionErrorMessage =
                "The invoice could not be deleted: \(error.localizedDescription)"
            showingActionError = true
        }
    }
}
