const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateChatMessage = functions
  .firestore
  .document('/chats/{userId}/conversations/{conversationId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const doc = await userRef.get();
    const androidNotificationToken = doc.data().androidNotificationToken;
    if (androidNotificationToken) {
      return admin.messaging().sendToTopic(`${context.params.conversationId}`, {
        notification: {
          title: doc.data().displayName,
          body: snapshot.data().text,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        },
        token: androidNotificationToken
      });
    } else {
      console.log("No token for user, cannot send notification");
    }
  });
