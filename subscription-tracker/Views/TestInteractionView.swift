//
//  TestInteractionView.swift
//  subscription-tracker
//
//  Test view to verify interactions are working
//

import SwiftUI

struct TestInteractionView: View {
    @State private var counter = 0
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Interaction Test")
                .font(.largeTitle)
            
            Text("Counter: \(counter)")
                .font(.title)
            
            Button("Tap Me!") {
                counter += 1
                print("✅ Button tapped! Counter: \(counter)")
            }
            .buttonStyle(.borderedProminent)
            
            Button("Show Alert") {
                showAlert = true
                print("✅ Alert button tapped!")
            }
            .buttonStyle(.bordered)
        }
        .alert("Test Alert", isPresented: $showAlert) {
            Button("OK") {
                print("✅ Alert dismissed!")
            }
        } message: {
            Text("If you see this, interactions are working!")
        }
    }
}

#Preview {
    TestInteractionView()
}
