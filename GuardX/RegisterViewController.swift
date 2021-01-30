//
//  RegisterViewController.swift
//  GuardX
//
//  Created by Ezer Patlan on 12/21/18.
//  Copyright © 2018 Ezer Patlan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth







class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!
    
    
    var databaseRefer : DatabaseReference!
    var databaseHandler : DatabaseHandle!
    
    @IBOutlet var genderPicker: UIPickerView!
    @IBOutlet var statePicker: UIPickerView!
    
    
    var gender = [String]()
    var state = [String]()
    
    //didTapSignUp
    
    @IBOutlet weak var didTapSignUp: UIButton!
    //didTapBackToLogin
    
    @IBOutlet weak var didTapBackToLogin: UIButton!
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return gender.count
        case 2:
            return state.count
        default:
            return 1
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 1:
            return gender[row]
        case 2:
            return state[row]
        default:
            return "None"
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            genderTextField.text = self.gender[row]
            self.view.endEditing(true)
        case 2:
            stateTextField.text = self.state[row]
            self.view.endEditing(true)
        default:
            return ()
        }
    }
    
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        let email = emailField.text
        let password = passwordField.text
        Auth.auth().createUser(withEmail: email!, password: password!, completion: {(user, error) in
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.showAlert("Enter a valid email.")
                    //case .emailAlreadyInUse:
                    //    self.showAlert("Email already in use.")
                    default:
                        self.showAlert("Error: \(error.localizedDescription)")
                    }
                }
                return
            }
            
            
            self.signUp()
            
        })
    }

    
    func databaseUser() {
        databaseRefer = Database.database().reference()
        //databaseRefer.child("users")
        let userid = Auth.auth().currentUser!.uid
        let userDictionary : NSDictionary = [
            "username": Auth.auth().currentUser!.email as String! as Any,
            "gender": genderTextField.text!,
            "firstname": firstnameTextField.text!,
            "lastname": lastnameTextField.text!,
            "address": addressTextField.text!,
            "city": cityTextField.text!,
            "state": stateTextField.text!,
            "zipcode": zipcodeTextField.text!,
            "userid": userid]
        
        databaseRefer.child("users").childByAutoId().setValue(userDictionary) {
            (error, ref) in
            if error != nil {
                print(error!)
            } else {
                print("User saved successfully!")
            }
        }
            
        
    }
    
    @IBAction func didTapBackToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "GuardX App", message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func signUp() {
        //performSegue(withIdentifier: "SignInFromSignUp", sender: nil)
        self.databaseUser()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignIn")
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //let kLoginButtonBackgroundColor = UIColor(displayP3Red: 31/255, green: 75/255, blue: 164/255, alpha: 1)
        let kLoginButtonBackgroundColor = UIColor.blue
        let kLoginButtonTintColor = UIColor.white
        let kLoginButtonCornerRadius: CGFloat = 13.0
        let kLoginButtonFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        let kLoginButtonLength = CGSize(width: 100.0, height: 30.0)

        
        didTapSignUp.layer.cornerRadius = kLoginButtonCornerRadius
        didTapSignUp.backgroundColor = kLoginButtonBackgroundColor
        didTapSignUp.tintColor = kLoginButtonTintColor
        didTapSignUp.titleLabel?.font = kLoginButtonFont
        
        didTapSignUp.frame.size = kLoginButtonLength
        didTapBackToLogin.layer.cornerRadius = kLoginButtonCornerRadius
        
       
        didTapBackToLogin.backgroundColor = kLoginButtonBackgroundColor
        didTapBackToLogin.tintColor = kLoginButtonTintColor
        didTapBackToLogin.titleLabel?.font = kLoginButtonFont
        didTapBackToLogin.frame.size = kLoginButtonLength
        
        
        self.genderPicker = UIPickerView()
        self.genderPicker.delegate = self
        self.genderPicker.dataSource = self
        self.genderTextField.inputView = genderPicker
        self.genderPicker.tag = 1
        
        
        self.statePicker = UIPickerView()
        self.statePicker.delegate = self
        self.statePicker.dataSource = self
        self.stateTextField.inputView = statePicker
        self.statePicker.tag = 2
        
        
        let data:Bundle = Bundle.main
        let genderPlist:String? = data.path(forResource:"gender", ofType: "plist")
        let statePlist:String? = data.path(forResource:"states", ofType: "plist")
        if genderPlist != nil {
            gender = NSArray(contentsOfFile: genderPlist!) as! [String]
        }
        if statePlist != nil {
            state = NSArray(contentsOfFile: statePlist!) as! [String]
        }
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
