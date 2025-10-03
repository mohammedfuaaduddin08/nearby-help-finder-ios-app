import SwiftUI
import SwiftData
import CoreLocation

extension Notification.Name {
    static let navigateToMyFavors = Notification.Name("navigateToMyFavors")
}

struct FavorDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    // Use a plain reference to the model object (Favor)
    var favor: Favor

    @State private var showingEdit = false

    private func distanceText() -> String {
        guard let userLoc = locationManager.userLocation else { return "—" }
        let fLoc = CLLocation(latitude: favor.latitude, longitude: favor.longitude)
        let dist = userLoc.distance(from: fLoc)
        if dist < 1000 { return String(format: "%.0f m", dist) }
        return String(format: "%.2f km", dist / 1000)
    }

    private func formattedLat() -> String {
        String(format: "%.5f", favor.latitude)
    }

    private func formattedLon() -> String {
        String(format: "%.5f", favor.longitude)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Favor") {
                    Text(favor.title).font(.title2).bold()
                    Text("Category: \(favor.category)").font(.subheadline)
                    Text("Added: \(favor.timestamp.formatted(date: .numeric, time: .shortened))")
                        .font(.caption)
                }

                Section("Location") {
                    Text("Lat: \(formattedLat())")
                    Text("Lon: \(formattedLon())")
                    HStack {
                        Text("Distance:")
                        Spacer()
                        Text(distanceText()).foregroundColor(.secondary)
                    }
                }

                Section {
                    Button("Go to My Favors") {
                        NotificationCenter.default.post(name: .navigateToMyFavors, object: nil)
                        dismiss()
                    }

                    Button(role: .destructive) {
                        modelContext.delete(favor)
                        dismiss()
                    } label: {
                        Text("Delete Favor")
                    }
                }
            }
            .navigationTitle("Details")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button("Edit") { showingEdit = true }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingEdit) {
                EditFavorView(favor: favor)
                    .environment(\.modelContext, modelContext)
            }
        }
    }
}
