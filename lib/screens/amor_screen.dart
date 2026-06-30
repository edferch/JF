import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'capsule_screen.dart';

class AmorScreen extends StatelessWidget {
  const AmorScreen({super.key});

  Future<void> _triggerPanicButton(BuildContext context) async {
    FirebaseFirestore.instance.collection('panic_alerts').add({
      'triggered_at': FieldValue.serverTimestamp(),
      'message': '¡Necesito amor, abrazos o chocolate urgente! ❤️',
    });

    // 1. Tu App ID listo. Falta que pegues tu REST API Key aquí abajo:
    const String oneSignalAppId = 'a3a7e092-bc97-410c-a58f-a41a1be297b9';
    const String restApiKey = 'Aqui va la clave';

    // 2. Disparamos la notificación Push
    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $restApiKey',
        },
        body: jsonEncode({
          'app_id': oneSignalAppId,
          // Al poner 'All', le enviará la notificación a cualquiera que tenga la app (ustedes dos)
          'included_segments': ['All'],
          'headings': {
            'en': '¡Alerta Romántica! 🚨',
            'es': '¡Alerta Romántica! 🚨',
          },
          'contents': {
            'en': '¡Necesito amor, abrazos o chocolate urgente! ❤️',
            'es': '¡Necesito amor, abrazos o chocolate urgente! ❤️',
          },
        }),
      );
    } catch (e) {
      debugPrint('Error enviando la notificación de OneSignal: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notificación de emergencia romántica enviada 🚨❤️',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEC4899), // Rosa vibrante
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Un día difícil? 🚨',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presiona nuestro logo para avisarle al otro',
                style: GoogleFonts.lato(fontSize: 15, color: Colors.white54),
              ),
              const SizedBox(height: 56),

              // EL LOGO COMO BOTÓN INTERACTIVO
              GestureDetector(
                onTap: () => _triggerPanicButton(context),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.01),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF9333EA,
                          ).withOpacity(0.15), // Resplandor morado
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 200, // Tamaño ideal para que sea el protagonista
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // ⏳ BOTÓN PARA LA CÁPSULA DEL TIEMPO (Idea 3)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CapsuleScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_clock, color: Colors.white70),
                      const SizedBox(width: 12),
                      Text(
                        'Abrir Cápsula del Tiempo',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
