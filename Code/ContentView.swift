import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Favor.timestamp, order: .reverse)]) private var favors: [Favor]

    @StateObject private var locationManager = LocationManager()
    @State private var showingAddFavor = false
    @State private var showingMyFavors = false

    @State private var selectedCategory = "All"
    private let categories = ["All", "Tools", "Books", "Errands", "Other"]

    @State private var followUser = false
    @State private var selectedFavor: Favor? = nil

    @State private var cameraPosition: MapCameraPosition = .camera(
        .init(centerCoordinate: CLLocationCoordinate2D(latitude: 25.276987, longitude: 55.296249), distance: 2500)
    )

    var body: some View {
        NavigationView {
            ZStack {
                mapView

                floatingButtons()

                NavigationLink(destination: MyFavorsView().environmentObject(locationManager),
                               isActive: $showingMyFavors) {
                    EmptyView()
                }
            }
            .navigationTitle("Nearby Helper Finder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("My Favors") { showingMyFavors = true }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 320)
                }
            }
            .sheet(isPresented: $showingAddFavor) {
                AddFavorView { newFavor in
                    centerMapOnFavor(newFavor)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showingMyFavors = true }
                }
                .environment(\.modelContext, modelContext)
            }
            .sheet(item: $selectedFavor) { favor in
                FavorDetailView(favor: favor)
                    .environment(\.modelContext, modelContext)
                    .environmentObject(locationManager)
            }
        }
    }

    // MARK: - Filtered Favors
    private var filteredFavors: [Favor] {
        if selectedCategory == "All" { return favors }
        return favors.filter { $0.category == selectedCategory }
    }

    // MARK: - Map View
    private var mapView: some View {
        Map(position: $cameraPosition) {
            // Show user location if available
            if let userLocation = locationManager.userLocation {
                Annotation("user-dot", coordinate: userLocation.coordinate) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.blue)
                }
            }

            // Show all favors
            ForEach(filteredFavors) { favor in
                Annotation(favor.title, coordinate: CLLocationCoordinate2D(latitude: favor.latitude, longitude: favor.longitude)) {
                    Button {
                        selectedFavor = favor
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Floating Buttons
    private func floatingButtons() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                Button(action: { followUser.toggle() }) {
                    Image(systemName: followUser ? "location.circle.fill" : "location.circle")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .padding(8)
                        .background(followUser ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding(.trailing, 8)

                if let loc = locationManager.userLocation {
                    Button(action: { centerMapOnCoordinate(loc.coordinate, distance: 1000) }) {
                        Image(systemName: "location.fill")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .padding(10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.trailing, 10)
                }

                Button(action: { showingAddFavor = true }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding()
            }
        }
    }

    // MARK: - Helper Methods
    private func centerMapOnFavor(_ favor: Favor) {
        centerMapOnCoordinate(CLLocationCoordinate2D(latitude: favor.latitude, longitude: favor.longitude), distance: 1200)
    }

    private func centerMapOnCoordinate(_ coordinate: CLLocationCoordinate2D, distance: CLLocationDistance) {
        withAnimation { cameraPosition = .camera(.init(centerCoordinate: coordinate, distance: distance)) }
    }
}
