import SwiftUI

struct RenameSheet: View {
    @Binding var isPresented: Bool
    var currentName: String
    var onRename: (String) -> Void

    @State private var newName: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Rename Light")
                .font(.headline)

            TextField("Enter a new name", text: $newName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Button("OK") {
                    let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        onRename(trimmed)
                    }
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .onAppear {
            newName = currentName
        }
    }
}
