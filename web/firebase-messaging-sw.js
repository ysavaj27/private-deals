importScripts("https://www.gstatic.com/firebasejs/12.17.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.17.1/firebase-messaging-compat.js");

firebase.initializeApp({
      apiKey: "AIzaSyD9jj5g7MKEbagYkiKSAuC5e3yManx5YDY",
      authDomain: "private-deals-e672b.firebaseapp.com",
      projectId: "private-deals-e672b",
      storageBucket: "private-deals-e672b.firebasestorage.app",
      messagingSenderId: "749470263169",
      appId: "1:749470263169:web:c36d2fd936afca1c4e2a80",
      measurementId: "G-HS6FVQDDFE"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);
});
