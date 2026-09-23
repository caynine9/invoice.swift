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

    @State private var showingError = false
    @State private var errorMessage = ""

    private var sortedLineItems: [InvoiceLineItem] {
        invoice.lineItems.sorted {
            $0.sortOrder < $1.sortOrder
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

                DatePicker(
                    "Due date",
                    selection: $invoice.dueDate,
                    displayedComponents: .date
                )

                TextField(
                    "Discount (%)",
                    value: $invoice.discountPercentage,
                    format: .number
                )

                TextField(
                    "Tax (%)",
                    value: $invoice.taxPercentage,
                    format: .number
                )

                LabeledContent("Currency") {
                    Text(invoice.currencyCode)
                }

                LabeledContent("Status") {
                    Text(invoice.statusRawValue.capitalized)
                }
            }

            Section("Client") {
                Text(clientName)

                if !invoice.clientEmailSnapshot.isEmpty {
                    Text(invoice.clientEmailSnapshot)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Notes") {
                TextEditor(text: $invoice.notes)
                    .frame(minHeight: 100)
            }
        }
    }

    private var itemsAndTotals: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Line Items")
                    .font(.title2)

                Spacer()

                Button(action: addLineItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            .padding(.horizontal)

            List {
                if sortedLineItems.isEmpty {
                    ContentUnavailableView(
                        "No items yet",
                        systemImage: "list.bullet",
                        description: Text(
                            "Use Add Item to add a manual line item."
                        )
                    )
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(sortedLineItems, id: \.id) { item in
                        InvoiceLineItemEditorRow(
                            item: item,
                            onChanged: recalculateTotals,
                            onDelete: {
                                removeLineItem(item)
                            }
                        )
                    }
                    .onMove(perform: moveLineItems)
                }
            }
            
            totalsSummary
                .padding()
        }
    }

    private var totalsSummary: some View {
        VStack(spacing: 8) {
            LabeledContent(
                "Subtotal",
                value: formattedAmount(invoice.subtotal)
            )

            LabeledContent(
                "Discount",
                value: formattedAmount(invoice.discountAmount)
            )

            LabeledContent(
                "Tax",
                value: formattedAmount(invoice.taxAmount)
            )

            Divider()

            LabeledContent(
                "Total",
                value: formattedAmount(invoice.total)
            )
            .fontWeight(.semibold)
        }
        .padding()
    }

    private func formattedAmount(_ amount: Decimal) -> String {
        amount.formatted(
            .currency(code: invoice.currencyCode)
        )
    }

    private func addLineItem() {
        let item = InvoiceLineItem(
            sortOrder: sortedLineItems.count,
            itemDescription: "",
            quantity: 1,
            unitPrice: .zero,
            invoice: invoice
        )

        modelContext.insert(item)
        recalculateTotals()
        saveChanges()
    }

    private func removeLineItem(_ item: InvoiceLineItem) {
        item.invoice = nil
        modelContext.delete(item)

        recalculateTotals()
        saveChanges()
    }

    private func moveLineItems(
        from source: IndexSet,
        to destination: Int
    ) {
        var reorderedItems = sortedLineItems
        reorderedItems.move(
            fromOffsets: source,
            toOffset: destination
        )

        for (index, item) in reorderedItems.enumerated() {
            item.sortOrder = index
        }

        recalculateTotals()
        saveChanges()
    }

    private func recalculateTotals() {
        do {
            let result = try InvoiceCalculationService.calculate(
                invoice: invoice
            )

            InvoiceCalculationService.apply(
                result,
                to: invoice
            )
        } catch {
            errorMessage =
                "Could not recalculate invoice totals: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            errorMessage =
                "Could not save invoice changes: \(error.localizedDescription)"
            showingError = true
        }
    }
}
