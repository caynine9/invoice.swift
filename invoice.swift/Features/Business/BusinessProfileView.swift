//
//  BusinessProfileView.swift
//  invoice.swift
//
//  Created by Muhammad Tantowi Jauhari on 22/09/26.
//

import SwiftData
import SwiftUI

struct BusinessProfileView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BusinessProfile.createdAt)
    private var profiles: [BusinessProfile]

    @State private var feedbackMessage: String?

    var body: some View {
        Group {
            if let profile = profiles.first {
                BusinessProfileForm(
                    profile: profile,
                    onSave: saveProfile
                )
            } else {
                emptyProfileView
            }
        }
        .padding()
        .navigationTitle("Business")
        .overlay(alignment: .bottom) {
            if let feedbackMessage = feedbackMessage {
                Text(feedbackMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
        }
    }

    private var emptyProfileView: some View {
            VStack(spacing: 16) {
                Image(systemName: "building.2")
                    .font(.system(size: 40))

                Text("No business profile yet")
                    .font(.title2)

                Text("Create a profile to use on your invoices.")
                    .foregroundStyle(.secondary)

                Button("Create Business Profile") {
                    createProfile()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

    private func saveProfile(_ profile: BusinessProfile) {
        profile.updatedAt = Date()
        saveContext()
    }

    private func createProfile() {
        guard profiles.isEmpty else {
            return
        }

        let profile = BusinessProfile()

        modelContext.insert(profile)
        saveContext()
    }


    private func saveContext() {
        do {
            try modelContext.save()
            feedbackMessage = "Saved locally."
        } catch {
            feedbackMessage = "Could not save profile: \(error.localizedDescription)"
        }
    }
}

private struct BusinessProfileForm: View {
    @Bindable var profile: BusinessProfile

    let onSave: (BusinessProfile) -> Void

    var body: some View {
        Form {
            Section("Business Details") {
                TextField(
                    "Business name",
                    text: $profile.businessName
                )

                TextField(
                    "Email",
                    text: $profile.email
                )

                TextField(
                    "Phone",
                    text: $profile.phone
                )

                TextField(
                    "Tax ID",
                    text: $profile.taxID
                )

                TextEditor(
                    text: $profile.address
                )
                .frame(minHeight: 90)
            }

            Section("Default Currency") {
                Picker(
                    "Currency",
                    selection: $profile.defaultCurrencyCode
                ) {
                    ForEach(CurrencyCode.allCases) { currency in
                        Text(currency.rawValue)
                            .tag(currency.rawValue)
                    }
                }
            }

            Section {
                Button("Save Changes") {
                    onSave(profile)
                }
            }
            .formStyle(.grouped)
        }
    }
}
