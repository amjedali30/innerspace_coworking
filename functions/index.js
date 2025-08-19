const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Trigger when a new booking is created
exports.sendBookingConfirmation = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap, context) => {
    const booking = snap.data();

    if (!booking.deviceToken) {
      console.log("❌ No device token found");
      return null;
    }

    const payload = {
      notification: {
        title: "Booking Confirmed ✅",
        body: `Hi ${booking.username}, your booking at ${booking.branchName} is confirmed!`,
      },
    };

    try {
      await admin.messaging().sendToDevice(booking.deviceToken, payload);
      console.log("✅ Notification sent to", booking.username);
    } catch (error) {
      console.error("❌ Error sending notification:", error);
    }
  });
