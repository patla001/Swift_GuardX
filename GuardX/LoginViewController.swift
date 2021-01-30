//
//  LoginViewController.swift
//  GuardX
//
//  Created by Ezer Patlan on 12/21/18.
//  Copyright © 2018 Ezer Patlan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    //didTapSignIn
    @IBOutlet weak var didTapSignIn: UIButton!
    
    //didRequestPasswordReset
    @IBOutlet weak var didRequestPasswordReset: UIButton!
    
    //didTapBackToLogin
    @IBOutlet weak var didTapBackToLogin: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = Auth.auth().currentUser {
            self.logIn()
        }
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        let email = emailField.text
        let password = passwordField.text
        
        Auth.auth().signIn(withEmail: email!, password: password!,
                               completion: {(user, error) in
                                guard let _ = user else {
                                    if let error = error {
                                        if let errCode = AuthErrorCode(rawValue: error._code){
                                            switch errCode {
                                            case .userNotFound:
                                                self.showAlert("User account not found. Try registering")
                                            case .wrongPassword:
                                                self.showAlert("Incorrect username/password combination")
                                            default:
                                                self.showAlert("Error: \(error.localizedDescription)")
                                            
                                            
                                        }
                                    }
                                        return
                                }
                                    assertionFailure("user and error are nil")
                                    return 
                                }
                                self.logIn()
    })
    }
    
    
    @IBAction func didRequestPasswordReset(_ sender: UIButton) {
        let prompt = UIAlertController(title: "GuardX App", message: "Email:", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let  userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: userInput!, completion: { (error) in
                if let error = error {
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .userNotFound:
                            DispatchQueue.main.async {
                                self.showAlert("User account not found. Try registering")
                            }
                        default:
                            DispatchQueue.main.async {
                                self.showAlert("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    return
                } else {
                    DispatchQueue.main.async {
                        self.showAlert("You'll receive an email shortly to reset your password.")
                    }
                }
            })
        }
        
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapBackToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "GuardX App", message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logIn() {
        //performSegue(withIdentifier: "SignInFromLogin", sender: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignIn")
        self.present(vc!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let kLoginButtonBackgroundColor = UIColor.blue
        let kLoginButtonTintColor = UIColor.white
        let kLoginButtonCornerRadius: CGFloat = 13.0
        let kLoginButtonFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        let kLoginButtonLength = CGSize(width: 100.0, height: 30.0)
        
        
        didTapSignIn.layer.cornerRadius = kLoginButtonCornerRadius
        didTapSignIn.backgroundColor = kLoginButtonBackgroundColor
        didTapSignIn.tintColor = kLoginButtonTintColor
        didTapSignIn.titleLabel?.font = kLoginButtonFont
        didTapSignIn.frame.size = kLoginButtonLength
        
        didTapBackToLogin.layer.cornerRadius = kLoginButtonCornerRadius
        didTapBackToLogin.backgroundColor = kLoginButtonBackgroundColor
        didTapBackToLogin.tintColor = kLoginButtonTintColor
        didTapBackToLogin.titleLabel?.font = kLoginButtonFont
        didTapBackToLogin.frame.size = kLoginButtonLength
        
        
        didRequestPasswordReset.layer.cornerRadius = kLoginButtonCornerRadius
        didRequestPasswordReset.backgroundColor = kLoginButtonBackgroundColor
        didRequestPasswordReset.tintColor = kLoginButtonTintColor
        didRequestPasswordReset.titleLabel?.font = kLoginButtonFont
        didRequestPasswordReset.frame.size = kLoginButtonLength
        
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
