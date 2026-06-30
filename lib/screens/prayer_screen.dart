import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final CollectionReference _prayersCollection = FirebaseFirestore.instance
      .collection('prayers');
  final TextEditingController _prayerController = TextEditingController();

  @override
  void dispose() {
    _prayerController.dispose();
    super.dispose();
  }

  void _showAddPrayerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Nuevo Motivo de Oración 🙏',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _prayerController,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            maxLines:
                null, // Permite que el texto ocupe varias líneas si es muy largo
            decoration: InputDecoration(
              hintText: 'Escribe tu agradecimiento o petición...',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3B82F6)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _prayerController.clear();
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF9333EA),
                  ], // Azul a Morado
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_prayerController.text.isNotEmpty) {
                    _prayersCollection.add({
                      'content': _prayerController.text.trim(),
                      'is_answered': false,
                      'created_at': FieldValue.serverTimestamp(),
                    });
                    _prayerController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleAnswered(String docId, bool currentStatus) {
    _prayersCollection.doc(docId).update({'is_answered': !currentStatus});
  }

  void _deletePrayer(String docId) {
    _prayersCollection.doc(docId).delete();
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabecera Elegante
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 20.0,
                  bottom: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oración y Gratitud',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nuestro espacio para conectar con Dios',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Lista de Oraciones
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _prayersCollection
                      .orderBy('created_at', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error',
                          style: GoogleFonts.lato(color: Colors.white70),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF9333EA),
                        ),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.volunteer_activism,
                              size: 80,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Un corazón agradecido',
                              style: GoogleFonts.montserrat(
                                color: Colors.white54,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Añadan su primer motivo de oración.',
                              style: GoogleFonts.lato(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        String docId = snapshot.data!.docs[index].id;
                        bool isAnswered = data['is_answered'] ?? false;
                        DateTime? date = (data['created_at'] as Timestamp?)
                            ?.toDate();

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isAnswered
                                ? Colors.white.withOpacity(0.02)
                                : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isAnswered
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Botón para marcar como oración respondida
                                    GestureDetector(
                                      onTap: () =>
                                          _toggleAnswered(docId, isAnswered),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: 28,
                                        height: 28,
                                        margin: const EdgeInsets.only(
                                          top: 2,
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: isAnswered
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF2563EB),
                                                    Color(0xFF9333EA),
                                                  ],
                                                )
                                              : null,
                                          border: isAnswered
                                              ? null
                                              : Border.all(
                                                  color: const Color(
                                                    0xFF3B82F6,
                                                  ),
                                                  width: 2,
                                                ), // Borde azul
                                        ),
                                        child: isAnswered
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 18,
                                              )
                                            : null,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data['content'],
                                        style: GoogleFonts.lato(
                                          color: isAnswered
                                              ? Colors.white38
                                              : Colors.white,
                                          fontSize: 16,
                                          height: 1.4,
                                          fontStyle: isAnswered
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white.withOpacity(0.2),
                                        size: 20,
                                      ),
                                      onPressed: () => _deletePrayer(docId),
                                    ),
                                  ],
                                ),
                                // Fecha en la parte inferior si existe
                                if (date != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12.0,
                                      left: 40.0,
                                    ),
                                    child: Text(
                                      DateFormat(
                                        'd MMM, yyyy',
                                        'es_ES',
                                      ).format(date),
                                      style: GoogleFonts.montserrat(
                                        color: isAnswered
                                            ? Colors.white24
                                            : const Color(
                                                0xFF9333EA,
                                              ), // Morado suave
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // 3. Botón Flotante
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9333EA).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddPrayerDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.volunteer_activism,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
