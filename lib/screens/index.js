const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Inicializamos el SDK de administrador de Firebase
admin.initializeApp();

// Esta función se dispara automáticamente cada vez que se crea un documento en "panic_alerts"
exports.sendPanicNotification = functions.firestore
    .document("panic_alerts/{docId}")
    .onCreate(async (snap, context) => {
        const data = snap.data();
        const mensaje = data.message || "¡Necesito amor, abrazos o chocolate urgente! ❤️";

        // Preparamos la notificación Push
        const messagePayload = {
            notification: {
                title: "¡Alerta Romántica! 🚨",
                body: mensaje,
            },
            topic: "couple_alerts", // Este es el canal al que ambos teléfonos se suscribieron
        };

        try {
            const response = await admin.messaging().send(messagePayload);
            console.log("Notificación enviada con éxito:", response);
        } catch (error) {
            console.error("Error al enviar la notificación push:", error);
        }
        return null;
    });