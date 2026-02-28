//
//  ContentView.swift
//  app
//
//  Created by Berat PORSUK on 29.06.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        MapView()
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: Text("Item at \(item.timestamp, format: .dateTime)")) {
                        Text(item.timestamp, format: .dateTime)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Öğeler")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: addItem) {
                        Label("Ekle", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

