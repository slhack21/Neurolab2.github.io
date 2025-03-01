// Configuration de Firebase
const firebaseConfig = {
  apiKey: "AIzaSyBmOFNz8eAamiAF0290tk3NQeQjk4EHpDs",
  authDomain: "neurolab-24244.firebaseapp.com",
  projectId: "neurolab-24244",
  storageBucket: "neurolab-24244.appspot.com",
  messagingSenderId: "642655436205",
  appId: "1:642655436205:web:ccacee2e544f8009443524"
};

// Initialisation de Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

// Fonction d'authentification
function signInOrSignUp() {
  const pseudo = document.getElementById("pseudo-input").value;
  const password = document.getElementById("password-input").value;
  const email = pseudo + "@example.com"; // Utiliser le pseudo comme email

  auth.createUserWithEmailAndPassword(email, password)
    .then(() => {
      loadChat();
    })
    .catch(error => {
      alert("Erreur : " + error.message);
    });
}

// Charger la section du chat
function loadChat() {
  document.getElementById("chat-area").style.display = "block";
  document.getElementById("login-form").style.display = "none";
}

// Envoyer un message
function sendMessage() {
  const message = document.getElementById("message-input").value;
  const user = auth.currentUser;

  if (message && user) {
    db.collection("messages").add({
      message: message,
      sender: user.email,
      timestamp: firebase.firestore.FieldValue.serverTimestamp()
    });

    document.getElementById("message-input").value = "";
  }
}

// Afficher les messages en temps réel
db.collection("messages").orderBy("timestamp").onSnapshot(snapshot => {
  const messagesList = document.getElementById("messages-list");
  messagesList.innerHTML = ""; // Vider la liste avant d'ajouter les nouveaux messages

  snapshot.docs.forEach(doc => {
    const messageData = doc.data();
    const messageDiv = document.createElement("div");
    messageDiv.textContent = `${messageData.sender}: ${messageData.message}`;
    messagesList.appendChild(messageDiv);
});