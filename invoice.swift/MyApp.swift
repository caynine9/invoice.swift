import SwiftData
import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            BusinessProfile.self,
            Client.self,
            CatalogItem.self,
            Invoice.self,
            InvoiceLineItem.self
            ]
        )
    }
}
