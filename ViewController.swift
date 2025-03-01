import UIKit
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {
    @IBOutlet weak var pseudoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messagesListView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Vérifie si un utilisateur est déjà connecté
        if let user = Auth.auth().currentUser {
            loadChat()
        }
    }

    @IBAction func signInOrSignUp(_ sender: UIButton) {
        let email = pseudoTextField.text! + "@example.com" // Utilise le pseudo comme email
        let password = passwordTextField.text!
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print("Erreur : \(error.localizedDescription)")
                return
            }
            // Connexion réussie
            self.loadChat()
        }
    }

    func loadChat() {
        // Charger la zone de discussion
        self.messagesListView.text = "Bienvenue dans le chat !"
        listenForMessages()
    }

    func listenForMessages() {
        let db = Firestore.firestore()
        
        db.collection("messages").order(by: "timestamp").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Erreur : \(error.localizedDescription)")
                return
            }
            
            self.messagesListView.text = "" // Réinitialiser la vue avant d'ajouter de nouveaux messages
            for document in snapshot!.documents {
                let messageData = document.data()
                let sender = messageData["sender"] as? String ?? "Anonyme"
                let message = messageData["message"] as? String ?? ""
                self.messagesListView.text.append("\(sender): \(message)\n")
            }
        }
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        let db = Firestore.firestore()
        let message = messageTextField.text!

        if let user = Auth.auth().currentUser, !message.isEmpty {
            db.collection("messages").addDocument(data: [
                "message": message,
                "sender": user.email ?? "Anonyme",
                "timestamp": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    print("Erreur lors de l'envoi du message : \(error.localizedDescription)")
                } else {
                    self.messageTextField.text = ""
                }
            }
        }
    }
}