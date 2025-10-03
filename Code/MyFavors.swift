import SwiftUI
import SwiftData
import CoreLocation

struct MyFavorsView: View {
    @Query(sort: [SortDescriptor(\Favor.timestamp, order: .reverse)]) private var favors: [Favor]
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        List {
            ForEach(favors) { favor in
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(favor.title).font(.headline)
                        Text("Category: \(favor.category)").font(.subheadline)
                        Text("Added: \(favor.timestamp.formatted(date: .numeric, time: .shortened))").font(.caption)
                    }
                    Spacer()
                    Text(distanceText(for: favor)).font(.caption2).foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("My Favors")
    }

    private func distanceText(for favor: Favor) -> String {
        guard let user = locationManager.userLocation else { return "—" }
        let fLoc = CLLocation(latitude: favor.latitude, longitude: favor.longitude)
        let d = user.distance(from: fLoc)
        if d < 1000 { return String(format: "%.0fm", d) }
        return String(format: "%.2fkm", d / 1000)
    }
}
