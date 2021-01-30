//
//  StartViewController.swift
//  GuardX
//
//  Created by Ezer Patlan on 12/22/18.
//  Copyright © 2018 Ezer Patlan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class StartViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    func logIn() {
        //performSegue(withIdentifier: "StartViewFromLogin", sender: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StartViewFromLogin")
        self.present(vc!, animated: true, completion: nil)
    }
    
    func signUp() {
        //performSegue(withIdentifier: "StartViewFromSignUp", sender: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StartViewFromSignUp")
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    /*override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "alreadyLoggedIn", sender: nil)
        }
    }*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let kLoginButtonBackgroundColor = UIColor.blue
        let kLoginButtonTintColor = UIColor.white
        let kLoginButtonCornerRadius: CGFloat = 13.0
        let kLoginButtonFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        let kLoginButtonLength = CGSize(width: 100.0, height: 30.0)
        
        loginButton.layer.cornerRadius = kLoginButtonCornerRadius
        loginButton.backgroundColor = kLoginButtonBackgroundColor
        loginButton.tintColor = kLoginButtonTintColor
        loginButton.titleLabel?.font = kLoginButtonFont
        loginButton.frame.size = kLoginButtonLength
        
        signupButton.layer.cornerRadius = kLoginButtonCornerRadius
        signupButton.backgroundColor = kLoginButtonBackgroundColor
        signupButton.tintColor = kLoginButtonTintColor
        signupButton.titleLabel?.font = kLoginButtonFont
        signupButton.frame.size = kLoginButtonLength
        
        nameLabel.font = UIFont(name: "Helvetica", size: 32)
        nameLabel.tintColor = kLoginButtonTintColor
        nameLabel.textColor = kLoginButtonTintColor
        nameLabel.frame.size = CGSize(width: 150.0, height: 50.0)
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "night-stars-wallpaper.png")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        
        /*
         let data:Bundle = Bundle.main
         let statePlist:String? = data.path(forResource:"states", ofType: "plist")
         if statePlist != nil {
         typeAndState = NSDictionary(contentsOfFile: statePlist!) as? Dictionary<String, Array<String>>
         stateTypes = typeAndState?.keys.sorted()
         selectedType = stateTypes![0]
         state = typeAndState![selectedType!]!.sorted()
         */
        
        
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
