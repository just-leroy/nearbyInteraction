import NearbyInteraction
import MultipeerConnectivity

protocol NearbyInteractionManagerDelegate: AnyObject {
    func didUpdateNearbyObjects(objects: [NINearbyObject])
}

final class NearbyInteractionManager: NSObject {
    static let instance = NearbyInteractionManager()
    var session: NISession?
    weak var delegate: NearbyInteractionManagerDelegate?
    
    func start() {
        session = NISession()
        session?.delegate = self
        MultipeerConnectivityManager.instance.delegate = self
        MultipeerConnectivityManager.instance.startBrowsingForPeers()
    }
        
    private var discoveryTokenData: Data {
        guard let token = session?.discoveryToken,
              let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            fatalError("can't convert token to data")
        }
        
        return data
    }
}
