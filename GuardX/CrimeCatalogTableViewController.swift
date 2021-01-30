//
//  CrimeCatalogTableViewController.swift
//  GuardX
//
//  Created by Ezer Patlan on 12/30/18.
//  Copyright © 2018 Ezer Patlan. All rights reserved.
//

import UIKit
import Firebase

protocol ReusableViewEnum {}

extension ReusableViewEnum where Self: RawRepresentable, Self.RawValue == Int {
    static var all: [Self] {
        var index = 0
        var allItems = [Self]()
        while let item = Self(rawValue: index) {
            allItems.append(item)
            index += 1
        }
        
        return allItems
    }
    
    
    static func build(with value: Int) -> Self {
        guard let row = Self(rawValue: value) else {
            fatalError("Uimplememted value: \(value)")
        }
        return row
    }
    
}

class CrimeCatalog {
    var crimeArson: String?
    var crimeAssault: String?
    var crimeBurglary: String?
    var crimeDisturbing: String?
    var crimeDrugs: String?
    var crimeDUI: String?
    var crimeFraud: String?
    var crimeHomocide: String?
    var crimeMotorTheft: String?
    var crimeRobbery: String?
    var crimeSex: String?
    var crimeTheft: String?
    var crimeVandalism: String?
    var crimeVehicleBreakIn: String?
    var crimeWeapons: String?
    
    init(crimeArson: String?, crimeAssault: String?, crimeBurglary: String?, crimeDisturbing: String?,crimeDrugs: String?, crimeDUI: String?, crimeFraud: String?, crimeHomocide: String?, crimeMotorTheft: String?, crimeRobbery: String?, crimeSex: String?, crimeTheft: String?, crimeVandalism: String?, crimeVehicleBreakIn: String?,  crimeWeapons: String? ) {
        
        self.crimeArson = crimeArson
        self.crimeAssault = crimeAssault
        self.crimeBurglary = crimeBurglary
        self.crimeDisturbing = crimeDisturbing
        self.crimeDrugs = crimeDrugs
        self.crimeDUI = crimeDUI
        self.crimeFraud = crimeFraud
        self.crimeHomocide = crimeHomocide
        self.crimeMotorTheft = crimeMotorTheft
        self.crimeRobbery = crimeRobbery
        self.crimeSex = crimeSex
        self.crimeTheft = crimeTheft
        self.crimeVandalism = crimeVandalism
        self.crimeVehicleBreakIn = crimeVehicleBreakIn
        self.crimeWeapons = crimeWeapons
        
    }
}



class CrimeCatalogTableViewController: UITableViewController {

    var databaseRefer : DatabaseReference!
    var extractedData = [String]()
    var myCrimeList = [CrimeCatalog]()
    
    @IBOutlet weak var crimeListTableView: UITableView!
    
    fileprivate enum ProfileSections: Int, ReusableViewEnum {
        case arson
        case assault
        case burglary
        case disturbing
        case drugs
        case dui
        case fraud
        case homocide
        case motortheft
        case robbery
        case sex
        case theft
        case vandalism
        case vehiclebreakin
        case weapons
    
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "arsonCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "assaultCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "burglaryCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "disturbingCell")
        self.tableView.register(UITableViewCell.self,
            forCellReuseIdentifier: "drugsCell")
        self.tableView.register(UITableViewCell.self,
            forCellReuseIdentifier: "duiCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "fraudCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "homocideCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "motortheftCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "robberyCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sexCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "theftCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vandalismCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vehiclebreakinCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weaponsCell")
        
        
        crimeListTableView.dataSource = self
        crimeListTableView.delegate = self
        loadCrimeFirebase()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.myCrimeList.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch ProfileSections.build(with: indexPath.section) {
            
        case .arson:
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "arsonCell", for: indexPath) as? UITableViewCell {
        
            let catalog = myCrimeList[indexPath.row]
            cell.textLabel?.text = catalog.crimeArson
            
            return cell
        }
        
        case .assault:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "assaultCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeAssault
                
                return cell
            }
            
        case .burglary:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "burglaryCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeBurglary
                
                return cell
            }
        case .disturbing:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "disturbingCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeDisturbing
                
                return cell
            }
        case .drugs:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "drugCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeDrugs
                
                return cell
            }
        case .dui:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "duiCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeDUI
                
                return cell
            }
        case .fraud:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "fraudCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeFraud
                
                return cell
            }
        case .homocide:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "homocideCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeHomocide
                
                return cell
            }
        case .motortheft:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "motortheftCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeMotorTheft
                
                return cell
            }
        case .robbery:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "robberyCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeRobbery
                
                return cell
            }
        case .sex:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "sexCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeSex
                
                return cell
            }
        case .theft:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "theftCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeTheft
                
                return cell
            }
        case .vandalism:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "vandalismCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeVandalism
                
                return cell
            }
        case .vehiclebreakin:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "vehiclebreakinCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeVehicleBreakIn
                
                return cell
            }
        case .weapons:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "weaponsCell", for: indexPath) as? UITableViewCell {
                
                let catalog = myCrimeList[indexPath.row]
                cell.textLabel?.text = catalog.crimeWeapons
                
                return cell
            }
        }
        
        
    }
    
    func loadCrimeFirebase() {
        
        databaseRefer = Database.database().reference()
        self.databaseRefer.child("CrimeCatalog").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            
            let crimeArson = value?["0"]
            let crimeAssault = value?["1"]
            let crimeBurglary = value?["2"]
            let crimeDisturbing = value?["3"]
            let crimeDrugs = value?["4"]
            let crimeDUI = value?["5"]
            let crimeFraud = value?["6"]
            let crimeHomocide = value?["7"]
            let crimeMotorTheft = value?["8"]
            let crimeRobbery = value?["9"]
            let crimeSex = value?["10"]
            let crimeTheft = value?["11"]
            let crimeVandalism = value?["12"]
            let crimeVehicleBreakIn = value?["13"]
            let crimeWeapons = value?["14"]
            
            let crimes = CrimeCatalog(crimeArson: (crimeArson as! String), crimeAssault: (crimeAssault as! String), crimeBurglary: (crimeBurglary as! String), crimeDisturbing: (crimeDisturbing as! String), crimeDrugs: (crimeDrugs as! String), crimeDUI: (crimeDUI as! String), crimeFraud: (crimeFraud as! String), crimeHomocide: (crimeHomocide as! String), crimeMotorTheft: (crimeMotorTheft as! String), crimeRobbery: (crimeRobbery as! String), crimeSex: (crimeSex as! String), crimeTheft: (crimeTheft as! String), crimeVandalism: (crimeVandalism as! String), crimeVehicleBreakIn: (crimeVehicleBreakIn as! String), crimeWeapons: (crimeWeapons as! String))
            
            self.myCrimeList.append(crimes)
            /*for result in snapshot.children.allObjects as! [DataSnapshot]{
             
             let  results = result.value as? [String: AnyObject]
             
             }*/
            
            
            self.crimeListTableView.reloadData();
            
            
        }) {(error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
