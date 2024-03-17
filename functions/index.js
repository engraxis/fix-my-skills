const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp(functions.config().firebase);

exports.deleteAuthInstructor = functions.firestore.document("instructors/{i}")
    .onDelete((snapshot, context)=>{
      admin.auth().deleteUser(snapshot.id)
          .then(function() {
            console.log("Successfully deleted user");
            return "success";
          })
          .catch(function(error) {
            console.log("Error deleting user:", error);
          });

      return true;
    });
