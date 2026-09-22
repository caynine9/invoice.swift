//
//  CatalogView.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import SwiftData
import SwiftUI

struct CatalogView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CatalogItem.name)
    private var items: [CatalogItem]

    @State private var showingAddItem = false
    @State private var feedbackMessage: String?

    var body: some View {
        VStack {
            if items.isEmpty {
                emptyState
            } else {
                itemList
            }
        }
        .padding()
        .navigationTitle("Catalog")
        .toolbar {
            Button {
                showingAddItem = true
            } label: {
                Label("Add Item", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddItem) {
            CatalogItemFormView()
        }
        .overlay(alignment: .bottom) {
            if let feedbackMessage = feedbackMessage {
                Text(feedbackMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.system(size: 40))

            Text("No catalog items yet")
                .font(.title2)

            Text("Add products or services for future invoices.")
                .foregroundStyle(.secondary)

            Button("Add First Item") {
                showingAddItem = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var itemList: some View {
        List {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)

                    if !item.itemDescription.isEmpty {
                        Text(item.itemDescription)
                            .foregroundStyle(.secondary)
                    }

                    Text("Price: \(item.defaultPrice.description)")
                        .font(.callout)

                    if item.defaultTaxPercentage > Decimal.zero {
                        Text("Tax: \(item.defaultTaxPercentage.description)%")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                .contextMenu {
                    Button("Delete Item", role: .destructive) {
                        deleteItem(item)
                    }
                }
            }
        }
    }

    private func deleteItem(_ item: CatalogItem) {
        modelContext.delete(item)

        do {
            try modelContext.save()
            feedbackMessage = "Catalog item deleted."
        } catch {
            feedbackMessage = "Could not delete item: \(error.localizedDescription)"
        }
    }
}

private struct CatalogItemFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var itemDescription = ""
    @State private var sku = ""
    @State private var unit = ""
    @State private var priceText = ""
    @State private var taxPercentageText = "0"
    @State private var validationMessage: String?

    var body: some View {
        VStack {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $itemDescription)
                    TextField("SKU", text: $sku)
                    TextField("Unit", text: $unit)
                }

                Section("Pricing") {
                    TextField("Default price", text: $priceText)
                    TextField(
                        "Default tax percentage",
                        text: $taxPercentageText
                    )
                }

                if let validationMessage = validationMessage {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                }
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Spacer()

                Button("Save Item") {
                    saveItem()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }

    private func saveItem() {
        let trimmedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            validationMessage = "Item name is required."
            return
        }

        guard let defaultPrice = parseDecimal(priceText),
              defaultPrice >= Decimal.zero else {
            validationMessage = "Enter a valid non-negative price."
            return
        }

        guard let defaultTaxPercentage = parseDecimal(
            taxPercentageText
        ),
        defaultTaxPercentage >= Decimal.zero,
        defaultTaxPercentage <= Decimal(100) else {
            validationMessage = "Tax percentage must be between 0 and 100."
            return
        }

        let item = CatalogItem(
            name: trimmedName,
            itemDescription: itemDescription,
            sku: sku,
            unit: unit,
            defaultPrice: defaultPrice,
            defaultTaxPercentage: defaultTaxPercentage
        )

        modelContext.insert(item)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            validationMessage = "Could not save item: \(error.localizedDescription)"
        }
    }

    private func parseDecimal(_ value: String) -> Decimal? {
        Decimal(
            string: value.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            locale: Locale(identifier: "en_US_POSIX")
        )
    }
}
