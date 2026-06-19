//
//  ContentView.swift
//  fitnote
//
//  Created by Hiroyuki Kubo on 2026/06/18.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        WorkoutSessionListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewContainer.container)
}
