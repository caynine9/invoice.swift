//
//  ClientsView.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import SwiftData
import SwiftUI

struct ClientsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Client.displayName)
    private var clients: [Client]

    @State private var showingAddClient = false
    @State private var feedbackMessage: String?

    var body: some View {
        VStack {
            if clients.isEmpty {
                emptyState
            } else {
                clientList
            }
        }
        .padding()
        .navigationTitle("Clients")
        .toolbar {
            Button {
                showingAddClient = true
            } label: {
                Label("Add Client", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddClient) {
            ClientFormView()
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
            Image(systemName: "person.2")
                .font(.system(size: 40))

            Text("No clients yet")
                .font(.title2)

            Text("Add a client to use on your invoices.")
                .foregroundStyle(.secondary)

            Button("Add First Client") {
                showingAddClient = true

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var clientList: some View {
        List {
            ForEach(clients) { client in
                VStack(alignment: .leading, spacing: 4) {
                    Text(client.displayName)
                        .font(.headline)

                    if !client.companyName.isEmpty {
                        Text(client.companyName)
                            .foregroundStyle(.secondary)
                    }

                    if !client.email.isEmpty {
                        Text(client.email)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                .contextMenu {
                    Button("Delete Client", role: .destructive) {
                        deleteClient(client)
                    }
                }
            }
        }
    }

    private func deleteClient(_ client: Client) {

        do {
            try modelContext.save()
            feedbackMessage = "Client deleted."
        } catch {
            feedbackMessage = "Could not delete client: \(error.localizedDescription)"
        }
    }
}

private struct ClientFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var companyName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var billingAddress = ""
    @State private var taxID = ""
    @State private var notes = ""
    @State private var validationMessage: String?

    var body: some View {
        VStack {
            Form {
                Section("Client Details") {
                    TextField("Display name", text: $displayName)
                    TextField("Company name", text: $companyName)
                    TextField("Email", text: $email)
                    TextField("Phone", text: $phone)
                    TextField("Tax ID", text: $taxID)

                    TextEditor(text: $billingAddress)
                        .frame(minHeight: 80)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
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

                Button("Save Client") {
                    saveClient()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }

    private func saveClient() {
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedDisplayName.isEmpty else {
            validationMessage = "Display name is required."
            return
        }

        let client = Client(
            displayName: trimmedDisplayName,
            companyName: companyName,
            email: email,
            phone: phone,
            billingAddress: billingAddress,
            taxID: taxID,
            notes: notes
            )

        modelContext.insert(client)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            validationMessage = "Could not save client: \(error.localizedDescription)"
        }
    }
}
