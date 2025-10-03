import SwiftUI
import SwiftData
import CoreLocation

struct AddFavorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()

    @State private var title = ""
    @State private var category = ""

    // Completion to inform ContentView
    var onAddFavor: ((Favor) -> Void)? = nil

    var body: some View {
        NavigationView {
            Form {
                Section("Favor Details") {
                    TextField("Title", text: $title)
                    TextField("Category", text: $category)
                }

                Section("Location") {
                    if let loc = locationManager.userLocation {
                        Text("Latitude: \(loc.coordinate.latitude)")
                        Text("Longitude: \(loc.coordinate.longitude)")
                    } else {
                        Text("Waiting for location…")
                    }
                }

                Section {
                    Button("Add Favor") { addFavor() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty ||
                                  category.trimmingCharacters(in: .whitespaces).isEmpty ||
                                  locationManager.userLocation == nil)
                }
            }
            .navigationTitle("Add Favor")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }

    private func addFavor() {
        guard let loc = locationManager.userLocation else { return }
        let newFavor = Favor(
            title: title.trimmingCharacters(in: .whitespaces),
            category: category.trimmingCharacters(in: .whitespaces),
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude
        )

        modelContext.insert(newFavor)
        print("Inserted favor: \(newFavor.title) at \(newFavor.latitude),\(newFavor.longitude)")

        onAddFavor?(newFavor)
        dismiss()
    }
}
