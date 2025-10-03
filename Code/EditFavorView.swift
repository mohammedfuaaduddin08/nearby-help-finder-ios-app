import SwiftUI
import SwiftData

struct EditFavorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Accept the Favor reference directly (Favor is a reference type)
    var favor: Favor

    @State private var title: String
    @State private var category: String

    init(favor: Favor) {
        self.favor = favor
        // initialize state from the model values
        _title = State(initialValue: favor.title)
        _category = State(initialValue: favor.category)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Edit") {
                    TextField("Title", text: $title)
                    TextField("Category", text: $category)
                }

                Section {
                    Button("Save") {
                        // Commit changes to the model
                        favor.title = title.trimmingCharacters(in: .whitespaces)
                        favor.category = category.trimmingCharacters(in: .whitespaces)
                        // SwiftData observes changes to model objects; just dismiss
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Favor")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}
