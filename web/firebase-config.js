// Firebase configuration for spades-ordering-system
// This file provides the Firebase SDK configuration for the web app

const firebaseConfig = {
  apiKey: "AIzaSyAiFU1ZW9NRhuxI2diPoVAuy9tsX8c3_IE",
  authDomain: "spades-ordering-system.firebaseapp.com",
  projectId: "spades-ordering-system",
  storageBucket: "spades-ordering-system.firebasestorage.app",
  messagingSenderId: "261261806531",
  appId: "1:261261806531:web:fdeac809905aa4d3e70b76",
  measurementId: "G-SD985ZBZ0G"
};

// Initialize Firebase
// The actual initialization is handled by firebase_core in the Flutter app
// This script is provided for any additional Firebase web SDK features if needed

// Export firebaseConfig for use in other scripts
if (typeof window !== 'undefined') {
  window.firebaseConfig = firebaseConfig;
}

