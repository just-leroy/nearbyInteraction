//
//  swiftinteractionApp.swift
//  swiftinteraction
//
//  Created by Leroy on 17/01/2022.
//

import SwiftUI
import NearbyInteraction
import MultipeerConnectivity

@main
struct swiftinteractionApp: App{

    init() {
        print("test")
        
        guard NISession.isSupported else {
            print("This device doesn't support Nearby Interaction.")
            return
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
