//
//  ViewController.swift
//  SAFF
//
//  Created by Abdullah Alseddiq on 26/09/2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField! {
        didSet {
            self.phoneNumberTextField.delegate = self
            self.phoneNumberTextField.addTarget(self, action: #selector(self.isValidPhoneNumber), for: .editingChanged)
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            self.loginButton.isHidden = true
        }
    }
    
    //location manager to get last location and to monitor region
    let locationManager = CLLocationManager()
    //flag used to detect if user is in the region
    var userInsideRegion = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpLocationManager()
        setUpStyle()
        
        //Define geoFencing region
        let geoFence: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 24.830742, longitude: 46.637326), radius: 10, identifier: "SAFF")
        locationManager.startMonitoring(for: geoFence)
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }

    func setUpStyle() {
        self.phoneNumberTextField.layer.borderWidth = 1
        self.phoneNumberTextField.layer.cornerRadius = 5
        self.loginButton.layer.cornerRadius = 5

    }
    
    @IBAction func handleLoginAction(_ sender: Any) {
        if !userInsideRegion {
            showLocationAlert()
            return
        }
        
    }

    func showLocationAlert() {
        let alert = UIAlertController(title: "You're not in SAFF location", message: "You need to be inside SAFF region to login", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { _ in
               }))
               self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? HomeViewController
        self.present(viewController!, animated: true)
    }
    
    /// To validate phone number using simple regex
    /// - Parameter number: the number to be validated
    /// - Returns: return true if number is valid
    @objc func isValidPhoneNumber(){
        let number = self.phoneNumberTextField.text
        let expression = "^05{1}[0-9]{8}$"
       let testNumber = NSPredicate(format:"SELF MATCHES %@", expression)
        if testNumber.evaluate(with: number) == false {
            self.loginButton.isHidden = true
        }
        else {
            self.loginButton.isHidden = false
        }
   }
    
}


extension ViewController: CLLocationManagerDelegate, UITextFieldDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location")
        //To allow user login if already inside region
        let location = locations.last
        let lat = location?.coordinate.latitude
        let long = location?.coordinate.longitude
        let userLocation = CGPoint(x: lat ?? 0, y: long ?? 0)
        let SAFFLocation = CGPoint(x: 24.830742, y: 46.637326)
        
        //check if user is within the region
        if CGPointDistanceSquared(from: userLocation, to: SAFFLocation) < 15 {
            self.userInsideRegion = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("entered SAFF Region")
       userInsideRegion = true

    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("existed SAFF region")
        userInsideRegion = false
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        let maxLength = 10
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= maxLength
    }
    
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
}

