//
//  LocationChildViewController.swift
//  GuardX
//
//  Created by Ezer Patlan on 12/24/18.
//  Copyright © 2018 Ezer Patlan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts
import GoogleMaps
import GooglePlaces
import Firebase

struct MyPlace {
    var name: String
    var lat: Double
    var long: Double
}




class LocationChildViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate {
    
    var plistPathInDocument:String = String()
    var crimeStringDictionary: [[String: AnyObject]]?
    
    //var newCrimeDic :[[String: AnyObject]]?
    var newCrimeDic = [[String: AnyObject]].self
    var arrayDic = Array<Any>()
    var databaseRefer : DatabaseReference!
    var coords: CLLocationCoordinate2D?
    let currentLocationMarker = GMSMarker()
    var chosenPlace: MyPlace?
    
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    let radiusInMiles: Double = 2.5
    
    var locationManager = CLLocationManager()
    
    
     var scaleBarView = ScaleBarView()
    
    
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        
        return false
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        //showPartyMarkers(lat: lat, long: long)
        
        
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        myMapView.camera = camera
        txtFieldSearch.text = place.formattedAddress
        chosenPlace = MyPlace(name: place.formattedAddress!, lat: lat, long: long)
        let marker=GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "\(place.name)"
        marker.snippet = "\(place.formattedAddress!)"
        marker.map = myMapView
        let circle = GMSCircle(position: place.coordinate, radius: miles2meters(miles:radiusInMiles))
        circle.map = myMapView
        loadFirebase(latGPS:lat, lonGPS: long)
        loadUserData (latGPS:lat, lonGPS: long)
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let txtFieldSearch: UITextField = {
        let tf=UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .white
        tf.layer.borderColor = UIColor.darkGray.cgColor
        tf.placeholder="Search for a location"
        tf.translatesAutoresizingMaskIntoConstraints=false
        return tf
    }()
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 32.7157, longitude: 117.1611, zoom: 10.0)
        self.myMapView.camera = camera
        self.myMapView.delegate = self
        self.myMapView.isMyLocationEnabled = true
    }
    
    let myMapView: GMSMapView = {
        let v=GMSMapView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    
    
    func deg2rad(deg:Double) -> Double {
        return deg * Double.pi / 180
    }
    
    
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }
    
    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        // M is in Miles
        
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg:lat1)) * cos(deg2rad(deg:lat2)) * cos(deg2rad(deg:theta))
        dist = acos(dist)
        dist = rad2deg(rad:dist)
        if (unit=="M"){
            dist = dist * 60 * 1.1515
        }
        return dist
    }

    
    func miles2meters(miles:Double) -> Double {
        // 1 mile = 1609.34 meters
        let onemile2meters = 1609.34
        let result = miles * onemile2meters
        return result
    }
    
    @objc func btnMyLocationAction() {
        let location: CLLocation? = myMapView.myLocation
        if location != nil {
            // 5 miles = 8046.72 meters
            let circle = GMSCircle(position: (location?.coordinate)!, radius: miles2meters(miles:radiusInMiles))
            circle.map = myMapView
            let latGPS = (location?.coordinate.latitude)!
            let longGPS = (location?.coordinate.longitude)!
            //dataPlist(latGPS:latGPS, lonGPS:longGPS)
            loadFirebase(latGPS: latGPS, lonGPS: longGPS)
            loadUserData (latGPS:latGPS, lonGPS: longGPS)
            myMapView.animate(toLocation: (location?.coordinate)!)
            //self.loadPlist()
        }
    }
    
    let btnMyLocation: UIButton = {
        let btn=UIButton()
        btn.backgroundColor = UIColor.white
        btn.setImage(#imageLiteral(resourceName: "gps-fixed-indicator-6-copy.png"), for: .normal)
        btn.layer.cornerRadius = 25
        btn.clipsToBounds = true
        btn.tintColor = UIColor.gray
        btn.imageView?.tintColor=UIColor.gray
        btn.addTarget(self, action: #selector(btnMyLocationAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        let location = locations.last
        let lat = (location?.coordinate.latitude)!
        let long = (location?.coordinate.longitude)!
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        
        self.myMapView.animate(to: camera)
        
        //showPartyMarkers(lat: lat, long: long)
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error \(error)")
    }
    
    func showCustomMarker(lat: Double, long: Double, address: String, zipcode: String, description: String, dateTime: String, category: String, iconName: String) {
        let marker=GMSMarker()
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y:0, width: customMarkerWidth, height: customMarkerHeight), image: UIImage(named:iconName)!, borderColor: UIColor.darkGray, tag: 1)
        marker.iconView=customMarker
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "\(description)"
        marker.snippet = "Address: \(address + " " + zipcode)\n ActivityDate: \(dateTime)"
        marker.map = self.myMapView
    }
    
    
    
    func showCustomMarkerGoogle(lat: Double, long: Double, address: String, description: String, dateTime: String, category: String, iconName: String) {
        let marker=GMSMarker()
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y:0, width: customMarkerWidth, height: customMarkerHeight), image: UIImage(named:iconName)!, borderColor: UIColor.darkGray, tag: 1)
        marker.iconView=customMarker
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "\(description)"
        marker.snippet = "Address: \(address )\n ActivityDate: \(dateTime)"
        marker.map = self.myMapView
    }
    
    
    func showMarkerGoogle(lat: Double, long: Double, pinAddress: String, description: String, pinDay: String, category: String, iconCode: Int) {
        //myMapView.clear()
        
        
        switch iconCode {
        case 1:
            // Arson icon
            let iconName="icons8-fire-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 2:
            // Assault icon
            let iconName="icons8-fist-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 3:
            //Burglary icon
            let iconName="icons8-black-ski-mask-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
        case 4:
            //Disturbing the Peace icon
            let iconName="icons8-exclamation-mark-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 5:
            //Drugs/ Alcohol Violations icon
            let iconName="icons8-pills-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 6:
            // DUI icon
            let iconName="icons8-people-in-car-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 7:
            // Fraud icon
            let iconName="icons8-credit-card-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 8:
            // Homocide icon
            let iconName="icons8-circled-h-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 9:
            // Motor Vehicle Theft icon
            let iconName="icons8-automotive-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 10:
            // Robbery icon
            let iconName="icons8-bandit-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 11:
            // Sex Crime icon
            let iconName="icons8-circled-s-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 12:
            // Theft / Larceny icon
            let iconName="icons8-money-bag-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 13:
            // Vandalism icon
            let iconName="icons8-spray-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 14:
            // Vehicle Break-In / Theft icon
            let iconName="icons8-crashed-car-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 15:
            // Weapons icon
            let iconName="icons8-gun-filled-50"
            showCustomMarkerGoogle(lat: lat, long: long, address: pinAddress, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        default:
            break;
        }
        
        
    }
    
    
    func showPartyMarkers(lat: Double, long: Double, pinAddress: String, pinZipCode: String, description: String, pinDay: String, category: String, iconCode: Int) {
        //myMapView.clear()
        
        
        switch iconCode {
        case 1:
            // Arson icon
            let iconName="icons8-fire-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 2:
            // Assault icon
            let iconName="icons8-fist-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 3:
            //Burglary icon
            let iconName="icons8-black-ski-mask-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
        case 4:
            //Disturbing the Peace icon
            let iconName="icons8-exclamation-mark-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 5:
            //Drugs/ Alcohol Violations icon
            let iconName="icons8-pills-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 6:
            // DUI icon
            let iconName="icons8-people-in-car-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 7:
            // Fraud icon
            let iconName="icons8-credit-card-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 8:
            // Homocide icon
            let iconName="icons8-circled-h-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 9:
            // Motor Vehicle Theft icon
            let iconName="icons8-automotive-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        case 10:
            // Robbery icon
            let iconName="icons8-bandit-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 11:
            // Sex Crime icon
            let iconName="icons8-circled-s-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 12:
            // Theft / Larceny icon
            let iconName="icons8-money-bag-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 13:
            // Vandalism icon
            let iconName="icons8-spray-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 14:
            // Vehicle Break-In / Theft icon
            let iconName="icons8-crashed-car-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
            
        case 15:
            // Weapons icon
            let iconName="icons8-gun-filled-50"
            showCustomMarker(lat: lat, long: long, address: pinAddress, zipcode: pinZipCode, description: description, dateTime: pinDay, category: category, iconName: iconName)
            break;
        default:
            break;
        }
        
        
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {return false}
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y:0, width: customMarkerWidth, height: customMarkerHeight), image: img, borderColor: UIColor.black, tag: customMarkerView.tag)
        marker.iconView = customMarker
        
        return false
    }
    
    
    
    func setupTextField(textField: UITextField, img: UIImage) {
        textField.leftViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 5, y:5, width:20, height: 20))
        imageView.image = img
        let paddingView = UIView(frame: CGRect(x:0,y:0, width: 30, height: 30))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
    }
    
    func setupViews() {
        view.addSubview(myMapView)
        myMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        myMapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        myMapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        myMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60).isActive=true
        
        self.view.addSubview(txtFieldSearch)
        txtFieldSearch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive=true
        txtFieldSearch.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        txtFieldSearch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        txtFieldSearch.heightAnchor.constraint(equalToConstant: 35).isActive = true
        setupTextField(textField: txtFieldSearch, img: #imageLiteral(resourceName: "map-pin-3.png"))
        
        
        self.view.addSubview(btnMyLocation)
        btnMyLocation.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive=true
        btnMyLocation.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive=true
        btnMyLocation.widthAnchor.constraint(equalToConstant: 50).isActive=true
        btnMyLocation.heightAnchor.constraint(equalTo: btnMyLocation.widthAnchor).isActive=true
        
        
    }
    
    func LocationMap(refLat: Double, refLong: Double, pinAddress: String, pinZipCode: String, pinDescription: String, pinTime: String, pinCategory: String, iconCode: Int) {
       
        let address = pinAddress + " " + pinZipCode
        let coordinateLocation = CLGeocoder()
        coordinateLocation.geocodeAddressString(address) {
            (placemark, errors) in
            if let place = placemark?[0]{
                let lat = (place.location?.coordinate.latitude)!
                let lon = (place.location?.coordinate.longitude)!
                let insideCircle=self.distance(lat1:refLat, lon1:refLong, lat2:lat, lon2:lon, unit:"M")
                if insideCircle <= self.radiusInMiles {
                
                    self.showPartyMarkers(lat: lat, long: lon, pinAddress: pinAddress, pinZipCode: pinZipCode, description: pinDescription, pinDay: pinTime, category: pinCategory, iconCode: iconCode)
                }
                
            } else {
                print(errors!)
            }
        }
        
    }
    
    
    
    func LocationMapGoogle(refLat: Double, refLong: Double, pinAddress: String, pinZipCode: String, pinDescription: String, pinTime: String, pinCategory: String, iconCode: String) {
        
        let address = pinAddress + " " + pinZipCode
        let coordinateLocation = CLGeocoder()
        coordinateLocation.geocodeAddressString(address) {
            (placemark, errors) in
            if let place = placemark?[0]{
                let lat = (place.location?.coordinate.latitude)!
                let lon = (place.location?.coordinate.longitude)!
                let insideCircle=self.distance(lat1:refLat, lon1:refLong, lat2:lat, lon2:lon, unit:"M")
                if insideCircle <= self.radiusInMiles {
                    
                    self.showPartyMarkers(lat: lat, long: lon, pinAddress: pinAddress, pinZipCode: pinZipCode, description: pinDescription, pinDay: pinTime, category: pinCategory, iconCode: Int(iconCode)!)
                }
                
            } else {
                print(errors!)
            }
        }
        
    }
    
    
    
    
    func LocationMapGoogle(refLat: Double, refLong: Double, pinAddress: String, pinDescription: String, pinTime: String, pinCategory: String, iconCode: Int) {
        
        let address = pinAddress
        print("Inside Address:\(pinAddress)")
        let coordinateLocation = CLGeocoder()
        coordinateLocation.geocodeAddressString(address) {
            (placemark, errors) in
            if let place = placemark?[0]{
                let lat = (place.location?.coordinate.latitude)!
                let lon = (place.location?.coordinate.longitude)!
                let insideCircle=self.distance(lat1:refLat, lon1:refLong, lat2:lat, lon2:lon, unit:"M")
                print("\(pinAddress), lat: \(lat), lon: \(lon)")
                if insideCircle <= self.radiusInMiles {
                    
                    self.showMarkerGoogle(lat: lat, long: lon, pinAddress: pinAddress, description: pinDescription, pinDay: pinTime, category: pinCategory, iconCode: iconCode)
                }
                
            } else {
                print(errors!)
            }
        }
        
    }
    
    
    func loadPlist() {
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let dicContent:[String: AnyObject] = ["Data": crimeStringDictionary as AnyObject]
        let path = documentDirectory.appending("updateCrime.plist")
        print(path)
        if (!fileManager.fileExists(atPath: path)) {
            let plistConent = NSDictionary(dictionary: dicContent)
            let success:Bool = plistConent.write(toFile: path, atomically: true)
            
            if success {
                print("file has been created!")
            }else{
                print("unable to create the file")
            }
            
        }else{
            print("file already exist")
        }
        
    }
    
    func loadFirebase(latGPS:Double, lonGPS: Double) {
        var count = 0
        databaseRefer = Database.database().reference()
        let ref = databaseRefer.child("Data")
        ref.observe(.value, with: { ( snapshot: DataSnapshot!) in
            count = Int(snapshot.childrenCount)
        
            for index in 0...count {
            
               
                self.databaseRefer.child("Data").child(String(index)).observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    if Int(snapshot.childrenCount) == 7 {
                    
                        let value = snapshot.value as? NSDictionary
                        
                        let address = value?["BLOCK_ADDRESS"]
                        let description = value?["Charge_Description_Orig"]
                        let zipcode = value?["ZipCode"]
                        let activeTime = value?["activityDate"]
                        let category = value?["category"]
                        let iconNumber = value?["code"]
                        
                        print("index: \(index), address: \(address ?? ""), zipCode: \(zipcode ?? ""), description: \(description ?? ""), category: \(category ?? ""), iconNumber: \(iconNumber ?? "") ")
                        
                        self.LocationMapGoogle(refLat: latGPS, refLong: lonGPS, pinAddress: address as! String, pinZipCode: zipcode as! String, pinDescription: description as! String, pinTime: activeTime as! String, pinCategory: category as! String, iconCode: iconNumber as! String)
                    
                    }
                }) {(error) in
                    print(error.localizedDescription)
                }
                
            }
            
        })
        
    }
    
    
    func loadUserData (latGPS:Double, lonGPS: Double){
        
        let currentUserEmail = Auth.auth().currentUser!.email
        databaseRefer = Database.database().reference()
        let ref = databaseRefer.child("DataUsers").queryOrdered(byChild: "owner").queryEqual(toValue: currentUserEmail)
        ref.observeSingleEvent(of: .value, with: { (snapShot) in
            
            if let snapDict = snapShot.value as? [String:AnyObject]{
                for each in snapDict{
                    
                    
                    let address = each.value["address"] as! String
                    let description = each.value["Charge_Description_Orig"] as! String
                    
                    let activeTime = each.value["activityDate"] as! String
                    let category = each.value["category"] as! String
                    let iconNumber = each.value["code"]
                    
                    
                    print("\(address)")
                    
                    self.LocationMapGoogle(refLat: latGPS, refLong: lonGPS, pinAddress: address, pinDescription: description as! String, pinTime: activeTime as! String, pinCategory: category as! String, iconCode: iconNumber as! Int)
                    
                    
                    
                    
                }
            }
        }) {(error) in
            print(error.localizedDescription)
        }
        
        
        
    }
    
    
    func dataPlist(latGPS:Double, lonGPS:Double) {
        /*
        let docsBaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let customPlistURL = docsBaseURL.appendingPathComponent("updateCrime.plist")
        let newdata = try PropertyListSerialization.data(fromPropertyList: dic, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
        do {
            try newdata.write(to: customPlistURL, options: .atomic)
            print("Successfully write")
        }catch (let err){
            print(err.localizedDescription)
        }
        
        */
        // Load the Plist data
        let data:Bundle = Bundle.main
        let crimePlist: String? = data.path(forResource: "crime", ofType: "plist")
        if crimePlist != nil {
            crimeStringDictionary = (NSArray.init(contentsOfFile: crimePlist!) as? [[String:AnyObject]])
            
            //for items in crimeStringDictionary! {
            //for index in 0..<crimeStringDictionary!.count {
            for index in 0...5 {
                
                /*guard let address = items["BLOCK_ADDRESS"] else {return}
                 guard let zipcode = items["ZipCode"] else {return}
                 guard let iconNumber = items["code"] else {return}
                 */
                
                if crimeStringDictionary![index].count == 7 {
                    
                    guard let address = crimeStringDictionary![index]["BLOCK_ADDRESS"],
                        let description = crimeStringDictionary![index]["Charge_Description_Orig"],
                        let zipcode = crimeStringDictionary![index]["ZipCode"],
                        let activeTime = crimeStringDictionary![index]["activityDate"],
                        let category = crimeStringDictionary![index]["category"],
                        let iconNumber = crimeStringDictionary![index]["code"] else {return}
                    
                    
                    
                    
                    
                    print("index: \(index), address: \(address), zipCode: \(zipcode), description: \(description), category: \(category), iconNumber: \(iconNumber)")
                    
                    LocationMap(refLat: latGPS, refLong: lonGPS, pinAddress: address as! String, pinZipCode: zipcode as! String, pinDescription: description as! String, pinTime: activeTime as! String, pinCategory: category as! String, iconCode: iconNumber as! Int)
                }
                
                
                
                /* guard let addressNumber = address.isEmpty, let zipcodeNumber = zipcode.isEmpty, let iconcodeNumber = iconNumber.isEmpty else {return}
                 
                 LocationMap(pinAddress: addressNumber as! String, pinZipCode: zipcodeNumber as! String, iconCode: iconcodeNumber as! String)
                 
                 */
                
            }
            
            
            
        }
        
        
    }
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        myMapView.delegate=self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        
        setupViews()
        
        initGoogleMaps()
        
        txtFieldSearch.delegate=self
        
        
        //showPartyMarkers(lat: lat, long: long)
        //icon code
        
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
