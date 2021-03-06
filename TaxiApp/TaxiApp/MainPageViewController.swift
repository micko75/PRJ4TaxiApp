import UIKit
import MapKit

class MainPageViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var pickupInput: UITextField!
    @IBOutlet weak var destinationInput: UITextField!
    
    var locations: [CLPlacemark] = []
    
    @IBAction func searchLocation(_ sender: UIButton) {
        
        let pickup: String = pickupInput.text!
        let destination: String = destinationInput.text!
        
        print("Searching for location: " + pickup)
        
        if (pickup.isEmpty){
            print("Pickup is empty!")
            return
        }
        
        if (destination.isEmpty){
            print("Destination is empty!")
            return
        }
        
        getLocation(pickup)
        getLocation(destination)
    }
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true;
        mapKit.delegate = self;
        setUpMapView()
    }
    
    func setUpMapView() {
        mapKit.showsUserLocation = true
        mapKit.showsCompass = true
        mapKit.showsScale = true
        currentLocation()
    }
    
    func currentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
    }
    
    func getLocation(_ address: String){
        
        let geoCoder = CLGeocoder()
        
        print(address)
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    print("ERROR! No locations found")
                    return
            }
            
            print(address)
            self.locations.append(placemarks.first!)
            self.createRoute(self.locations)
        }
        
    }
    
    func createRoute(_ placemarks: [CLPlacemark]) {
        
        if (locations.count != 2) { return }
        
        let pickupCoordinates: CLLocationCoordinate2D = placemarks[0].location!.coordinate
        let destinationCoordinates: CLLocationCoordinate2D = placemarks[1].location!.coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinates, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = placemarks[0].name
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = placemarks[1].name
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapKit.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                print("Error")
                return
            }
            
            let route = response.routes[0]
            self.mapKit.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            
            mapKit.setRegion(, animated: <#T##Bool#>)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
    
        return renderer
    }
    
    func getAddress(_ location: CLLocation) -> String {
        var address: String = ""
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
                
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    address = placemark.name!
                } else {
                    print("No Matching Addresses Found")
                }
            }
        }
        return address;
    }
}

extension MainPageViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 400, longitudinalMeters: 400)
        mapKit.setRegion(coordinateRegion, animated: true)
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
                
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    self.pickupInput.text = placemark.name!
                } else {
                    print("No Matching Addresses Found")
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
