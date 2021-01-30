//
//  MapChildTapViewController.swift
//  GuardX
//
//  Created by Ezer Patlan on 12/24/18.
//  Copyright © 2018 Ezer Patlan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Foundation
import MapKit
import CoreLocation
import Firebase






class MapChildTapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return self.crimeArray.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 1:
            return crimeArray[row]
        default:
            return "None"
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            crimeTextField.text = self.crimeArray[row]
            self.view.endEditing(true)
        default:
            return ()
        }
    }
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var dateTimeTextField: UITextField!
    @IBOutlet weak var crimeTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet var crimePicker: UIPickerView!
    
   
    @IBOutlet weak var gpsButton: UIButton!
    
    @IBOutlet weak var firebaseButton: UIButton!
    
    
    
    @IBOutlet weak var confirmButton: UIButton!
    var locationManager = CLLocationManager()
    
    
    var chosenPlace: MyPlace?
    var formatSelectedDate = String()
    var databaseRefer : DatabaseReference!
    var extractedData = [String]()
    var myCrimeList = [CrimeCatalog]()
    var crimeArray = [String]()
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        
        
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        myMapView.camera = camera
        addressTextField.text = place.formattedAddress
        chosenPlace = MyPlace(name: place.formattedAddress!, lat: lat, long: long)
        let marker=GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        //marker.title = "\(place.name)"
        //marker.snippet = "\(place.formattedAddress!)"
        marker.map = myMapView
        
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let myMapView: GMSMapView = {
        let v=GMSMapView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        
        return false
    }
    
    @objc func setDate(_sender: UIDatePicker) {
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY HH:mm"
        let selectedDate: String = dateFormatter.string(from: _sender.date)
        
        
        
        if (_sender.tag == 2) {
            self.formatSelectedDate = selectedDate.replacingOccurrences(of: ":", with: "")
            dateTimeTextField.text = "\(selectedDate)"
            print("Selected value \(formatSelectedDate)")
        }
        self.view.endEditing(true)
    }
    
    func loadPlist() {
        
        let data:Bundle = Bundle.main
        let crimePlist: String? = data.path(forResource: "crimeCatalog", ofType: "plist")
        if crimePlist != nil {
            crimeArray = ((NSArray.init(contentsOfFile: crimePlist!) as? [String])!)
            
            }
        
    }
    
    
    
    @IBAction func gpsButton(_ sender: Any) {
        
        //self.myMapView.isMyLocationEnabled = true
        let location: CLLocation? = myMapView.myLocation
        if location != nil {
            
            let latGPS = (location?.coordinate.latitude)!
            let longGPS = (location?.coordinate.longitude)!
            let coordinate = location?.coordinate
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(coordinate!) { response , error in
                
                //Add this line
                if let address = response!.firstResult() {
                    let lines = address.lines! as [String]
                    self.addressTextField.text = lines[0]
                    print(lines)
                    
                }
            }
        }
    }
    
    
    
    @IBAction func firebaseButton(_ sender: UIButton) {
        
        let currentUserId = Auth.auth().currentUser!.uid
        databaseRefer = Database.database().reference()
        let ref = databaseRefer.child("users").queryOrdered(byChild: "userid").queryEqual(toValue: currentUserId)
        ref.observeSingleEvent(of: .value, with: { (snapShot) in
            
                    if let snapDict = snapShot.value as? [String:AnyObject]{
                        for each in snapDict{
                            let address = each.value["address"] as! String
                            let city = each.value["city"] as! String
                            let state = each.value["state"] as! String
                            let zipcode = each.value["zipcode"] as! String
                            let fulladdress = address + " " + city + " " + state + " " + zipcode
                            self.addressTextField.text = fulladdress
                            print(fulladdress)
                        }
            }
                }) {(error) in
                    print(error.localizedDescription)
                }
        
                
            
            
            
        
    
    }
    
    
    
    func crimeCode(crime: String) -> [String:AnyObject] {
        var crimeDic = [String:AnyObject]()
        switch crime {
        case "Arson":
            // Arson icon
            let iconCode=1
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        case "Assault":
            // Assault icon
            let iconCode=2
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        case "Burglary":
            //Burglary icon
            let iconCode=3
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
        case "Disturbing the Peace":
            //Disturbing the Peace icon
            let iconCode=4
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        case "Drugs / Alcohol Violations":
            //Drugs/ Alcohol Violations icon
            let iconCode=5
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        case "DUI":
            // DUI icon
            let iconCode=6
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        case "Fraud":
            // Fraud icon
            let iconCode=7
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        case "Homocide":
            // Homocide icon
            let iconCode=8
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        case "Motor Vehicle Theft":
            // Motor Vehicle Theft icon
            let iconCode=9
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        case "Robbery":
            // Robbery icon
            let iconCode=10
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
            
        case "Sex Crime":
            // Sex Crime icon
            let iconCode=11
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
            
        case "Theft / Larceny":
            // Theft / Larceny icon
            let iconCode=12
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
            
        case "Vandalism":
            // Vandalism icon
            let iconCode=13
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
            
        case "Vehicle Break-In":
            // Vehicle Break-In / Theft icon
            let iconCode=14
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
            
        case "Weapons":
            // Weapons icon
            let iconCode=15
            let category=crime
            crimeDic = ["code": iconCode,"category":category] as [String : AnyObject]
            break;
        default:
            break;
        }
        
        return crimeDic
    }
    
    @IBAction func confirmButton(_ sender: UIButton) {
        
        
        
        databaseRefer = Database.database().reference()
        let username = Auth.auth().currentUser!.email
        guard let address =  self.addressTextField.text else {return}
        guard let crime = self.crimeTextField.text else {return}
        guard let timeDay = self.dateTimeTextField.text else {return}
        guard let description = self.descriptionTextView.text else {return}
        
        var crimeDic = [String:AnyObject]()
        crimeDic = crimeCode(crime: crime)
        
        
        //databaseRefer.child("users")
        
        let userDictionary : NSDictionary = [
            "BLOCK_ADDRESS": Auth.auth().currentUser!.email as String! as Any,
            "Charge_Description_Orig":description,
            "activityDate": timeDay,
            "owner": username as Any,
            "address": address,
            "category": crimeDic["category"] as Any,
            "code": crimeDic["code"] as Any]
        
            //print("Data Index: \(indexNumber)");
            self.databaseRefer.child("DataUsers").childByAutoId().setValue(userDictionary)
            
            
            {
            (error, ref) in
            if error != nil {
                print(error!)
            } else {
                print("User saved successfully!")
            }
        }
        
        let title = "Hi \(username)"
        let message = "Upload Crime: \(crimeDic["category"])"
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionAlert)
        present(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.crimePicker = UIPickerView()
        self.crimePicker.delegate = self
        self.crimePicker.dataSource = self
        self.crimeTextField.inputView = crimePicker
        self.crimePicker.tag = 1
        
        
        // Do any additional setup after loading the view.
        self.datePicker = UIDatePicker()
        self.datePicker.datePickerMode = UIDatePicker.Mode.time
        self.datePicker.minuteInterval = 30
        self.datePicker.addTarget(self, action:#selector(self.setDate(_sender:)), for: .valueChanged)
        //self.datePicker.timeZone = TimeZone.current
        self.dateTimeTextField.inputView = datePicker
        self.datePicker.tag = 2
        
        
        
        self.myMapView.isMyLocationEnabled = true
        myMapView.delegate=self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        addressTextField.delegate=self
        //loadCrimeFirebase()
        //print("Crime Catalog: \(self.extractedData)")
        loadPlist()
        
        let kLoginButtonBackgroundColor = UIColor.blue
        let kLoginButtonTintColor = UIColor.white
        let kLoginButtonCornerRadius: CGFloat = 13.0
        let kLoginButtonFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        let kLoginButtonLength = CGSize(width: 100.0, height: 30.0)
        
        
        gpsButton.layer.cornerRadius = kLoginButtonCornerRadius
        gpsButton.backgroundColor = kLoginButtonBackgroundColor
        gpsButton.tintColor = kLoginButtonTintColor
        gpsButton.titleLabel?.font = kLoginButtonFont
        
        gpsButton.frame.size = kLoginButtonLength
        
        firebaseButton.layer.cornerRadius = kLoginButtonCornerRadius
        firebaseButton.backgroundColor = kLoginButtonBackgroundColor
        firebaseButton.tintColor = kLoginButtonTintColor
        firebaseButton.titleLabel?.font = kLoginButtonFont
        
        firebaseButton.frame.size = kLoginButtonLength
        
        confirmButton.layer.cornerRadius = kLoginButtonCornerRadius
        confirmButton.backgroundColor = kLoginButtonBackgroundColor
        confirmButton.tintColor = kLoginButtonTintColor
        confirmButton.titleLabel?.font = kLoginButtonFont
        
        confirmButton.frame.size = kLoginButtonLength
        
        
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
