//
//  NewInvoiceSheet.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 23/09/26.
//

import Foundation
import SwiftData
import SwiftUI

struct NewInvoiceSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let businessProfile: BusinessProfile?
    let clients: [Client]

    @State private var selectedClientID: UUID?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    private var selectedClient: Client? {
        guard let selectedClientID else {
            return nil
        }

        return clients.first { $0.id == selectedClientID }
    }

    private var hasBusinessName: Bool {
        guard let businessProfile else {
            return false
        }

        return !businessProfile.businessName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    private var canCreate: Bool {
        hasBusinessName && selectedClient != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Business") {
                    if hasBusinessName, let businessProfile {
                        Text(businessProfile.businessName)
                    } else {
                        Text("Add a business name in the Business section first.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Client") {
                    if clients.isEmpty {
                        Text("Add a client in the Clients section first.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Client", selection: $selectedClientID) {
                            Text("Choose a client")
                                .tag(Optional<UUID>.none)

                            ForEach(clients) { client in
                                Text(client.displayName)
                                    .tag(Optional(client.id))
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Invoice")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create Draft", action: createDraft)
                        .disabled(!canCreate || isSaving)
                }
            }
        }
        .frame(minWidth: 460, minHeight: 280)
        .onAppear(perform: selectInitialClient)
        .alert("Could not create invoice", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func selectInitialClient() {
        if selectedClientID == nil {
            selectedClientID = clients.first?.id
        }
    }

    private func createDraft() {
        guard
            !isSaving,
            let businessProfile,
            let selectedClient
        else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        let now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let year = calendar.component(.year, from: now)
        let dueDate = calendar.date(byAdding: .day, value: 14, to: now) ?? now

        var createdInvoice: Invoice?

        do {
            let number = try InvoiceNumberAllocator.allocate(
                year: year,
                in: modelContext
            )

            let invoice = Invoice(
                invoiceNumber: number,
                issueDate: now,
                dueDate: dueDate,
                currencyCode: businessProfile.defaultCurrencyCode,
                status: .draft,
                businessProfile: businessProfile,
                client: selectedClient,
                createdAt: now,
                updatedAt: now
            )

            createdInvoice = invoice
            modelContext.insert(invoice)
            try modelContext.save()
            dismiss()
        } catch {
            if let createdInvoice {
                modelContext.delete(createdInvoice)
            }

            errorMessage =
                "The draft could not be saved. Try again; an allocated number may be skipped."
            showingError = true
        }
    }
}
