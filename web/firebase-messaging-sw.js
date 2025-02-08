importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: 'AIzaSyBpxgdvKdrS8mIjlOMeI0hYb339eR4d_mE',
  appId: '1:250504410817:web:190e01b2afba936e144640',
  messagingSenderId: '250504410817',
  projectId: 'abibo-37551',
  authDomain: 'bibo-37551.firebaseapp.com',
  databaseURL: 'https://ammart-8885e-default-rtdb.firebaseio.com', 
  storageBucket: 'bibo-37551.firebasestorage.app',
  measurementId: 'G-KF0NG9D7BM',
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});