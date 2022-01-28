//
//  MPCManager.swift
//  swiftinteraction
//
//  Created by Leroy on 18/01/2022.
//

import Foundation
import MultipeerConnectivity //framework that uses wifi/bluetooth to connect
import NearbyInteraction

//
class MPCManager: NSObject, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate, ObservableObject, NISessionDelegate {
    
    var peerID: MCPeerID
    var niSession: NISession? //uwb
    //NISession toevoegen
    var mcSession: MCSession
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser?
    var peerConnected = false
    
    //Aan de hand van een @published wordt de ui geupdate wanneer deze property veranderd. Dit kan omdat deze class een observableObject protocol bevat.
    @Published var distance: String = "0"
    
    override init(){
        print("mpcManager started")
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        super.init()
        mcSession.delegate = self
        //uwb
    }
    
    //MARK: - MPC Connect Functions
    
    func startAdvertising() {
        print("Started advertising")
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "mpc-connect")
        mcAdvertiserAssistant?.delegate = self
        mcAdvertiserAssistant?.startAdvertisingPeer()
    }
    
    func sendInvite() {
        print("invite send")
        let browser = MCBrowserViewController(serviceType: "mpc-connect", session: mcSession)
        browser.delegate = self
        
        //present the browser to the viewcontroller
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        window?.rootViewController?.present(browser, animated: true, completion: nil)
    }
    
    func sendToken(token: String){
        print("Trying to send test token")
        if mcSession.connectedPeers.count > 0 {
            let dataToken = Data(token.utf8)
            do {
                try mcSession.send(dataToken, toPeers: mcSession.connectedPeers, with: .reliable)
                print("Test token send")
            } catch {
                fatalError("Could not send test token")
            }
        } else {
            print("You are not connected to other devices")
        }
    }
    
    //MARK: - MPC Functions
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //check the connected state
        switch state {
        case.connecting:
            print("\(peerID) state: connecting")
        case.connected:
            print("\(peerID) state: connected")
            
            //TODO: //stopadvertising/stopbrowsing (ff checken waar dit moet)
            if niSession == nil {
                print("creating niSession")
                niSession = NISession()
                niSession?.delegate = self
                sendDiscoveryToken()
            }
            //zodra er een connectie is hier een NIsession initialiseren.
            //Discovery token verzenden.
            //Token omzetten naar NSData object kan met NSKeyedarchiver
            
        case.notConnected:
            print("\(peerID) state: not connected")
        @unknown default:
            print("\(peerID) state: unkown")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // deze gebruiken om data te ontvangen
        print("Token recieved")
        
        receivedDiscoveryToken(data: data)
        //        let str = String(decoding: data, as: UTF8.self)
        //        token = str
        //        print(str)
        //if Nisession is nill and config is nill
        //uncrypt token met NSKeyedunarchiver
        //sendToken terug als ik token nog niet heb geintialliseerd.
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        //zodra er een peer gevonden is stuur een invite
        //om een invite te sturen gebruik de volgende methode
        //MCNearbyServiceBrowser.invitePeer(<#T##self: MCNearbyServiceBrowser##MCNearbyServiceBrowser#>)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        //
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // accept invite
        invitationHandler(true, mcSession)
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        //dismiss browser when done
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        //dismiss browser when cancelled
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Nearby Interaction Functions
    
    func sendDiscoveryToken(){
        print("Trying to send discoverytoken")
        if mcSession.connectedPeers.count > 0 {
            
            guard let dataToken = niSession?.discoveryToken,
                  let data = try? NSKeyedArchiver.archivedData(withRootObject: dataToken, requiringSecureCoding: true) else {
                      fatalError("can't convert token to data")
                  }
            do {
                try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
                print("Token send")
            } catch {
                fatalError("Could not send discovery token")
            }
        } else {
            print("You are not connected to other devices")
        }
    }
    
    func receivedDiscoveryToken(data: Data) {
        print("Trying to setup ni-connection")
        guard let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
            fatalError("Unexpectedly failed to encode discovery token.")
        }
        let configuration = NINearbyPeerConfiguration(peerToken: token)
        niSession?.run(configuration)
    }
    
    // MARK: - NISessionDelegate functions
    
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        print(nearbyObjects)
        
        distance = String(nearbyObjects.first?.distance ?? 0)
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        
    }
    
    func sessionWasSuspended(_ session: NISession) {
        
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        
    }
}


