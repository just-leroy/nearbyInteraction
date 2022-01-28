//
//  ContentView.swift
//  swiftinteraction
//
//  Created by Leroy on 17/01/2022.
//

import SwiftUI
import NearbyInteraction
import MultipeerConnectivity

struct ContentView: View {
    
    //Door deze te vermelden als @Stateobject wordt de ui geupdate wanneer @Published properties in deze class wordt gewijzigd.
    @StateObject var peerManager: MPCManager = MPCManager()
    var NIManager: NIManager = NIManager()
    
    init() {
        print("app started")
    }
    
    //MARK: - User Interface
    
    var body: some View {
        
        VStack {
            
            Text("Hello, world!")
            
            Button {
                print("Clicked on host")
                peerManager.startAdvertising()
            } label: {
                Text("HOST")
            }
            
            Button {
                print("Clicked on join")
                peerManager.sendInvite()
            } label: {
                Text("JOIN")
            }
            
            Button {
                print("Clicked on send token")
                peerManager.sendToken(token: "Hello there")
            } label: {
                Text("Send Token")
            }
            Text("Distance: ")
            Text("\(peerManager.distance)m").font(.system(size: 40))
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
