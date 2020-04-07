import UIKit

class RegisterViewController: UIViewController {

    // Outlet declaration
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var driverRegister: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Dismiss the keyboard when a user taps anywhere
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)))
        
        driverRegister.isUserInteractionEnabled = true
        
        driverRegister.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dRegister)))
    }
    
    @IBAction func register(_ sender: UIButton) {
        dismissKeyboard()
        
        // Get input
        let name: String = nameText.text!
        let lastName: String = lastNameText.text!
        let email: String = emailText.text!
        let password: String = passwordText.text!
        
        if(name.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty){
            print("Error! Some values are empty")
            return
        }
        
        print("Performing registering with name: " + name + " " + lastName + ", email: " + email + ", password: " + password)
        
        // TODO register request to the API
    }

    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func dRegister(){
        performSegue(withIdentifier: "driverRegister", sender: self)
    }
}
