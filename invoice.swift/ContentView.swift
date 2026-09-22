import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case invoices = "Invoices"
    case clients = "Clients"
    case catalog = "Catalog"
    case business = "Business"
    case history = "History"

    var id: String {
        rawValue
    }

    var iconName: String {
        switch self {
        case .invoices:
            return "doc.text"
        case .clients:
            return "person.2"
        case .catalog:
            return "shippingbox"
        case .business:
            return "building.2"
        case .history:
            return "clock.arrow.circlepath"
        }
    }
}

struct ContentView: View {
    @State private var selectedItem: SidebarItem? = .invoices

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedItem) { item in
                Label(item.rawValue, systemImage: item.iconName)
                    .tag(item)
            }
            .navigationTitle("Invoices")
        } detail: {
            if let selectedItems = selectedItem {
                SidebarDetailView(item: selectedItems)
            } else {
                Text("Pilih menu dari sidebar")
            }
        }
    }
}

struct SidebarDetailView: View {
    let item: SidebarItem

    var body: some View {
        Group {
            switch item {
                case .business:
                    BusinessProfileView()

                case .clients:
                    ClientsView()

                default:
                VStack(spacing: 12) {
                    Image(systemName: item.iconName)
                        .font(.system(size: 40))

                    Text(item.rawValue)
                        .font(.title)

                    Text("Konten \(item.rawValue) akan dibuat di sini.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    ContentView()
}
