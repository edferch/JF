import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CapsuleScreen extends StatefulWidget {
  const CapsuleScreen({super.key});

  @override
  State<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends State<CapsuleScreen> {
  final CollectionReference _capsulesCollection = FirebaseFirestore.instance
      .collection('time_capsules');

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _selectedUnlockDate;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showAddCapsuleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Sellar Mensaje ⏳',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Título (Ej: Feliz Aniversario)',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Tu mensaje secreto...',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 1),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _selectedUnlockDate = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _selectedUnlockDate == null
                            ? 'Elegir fecha de apertura'
                            : 'Se abre el: ${DateFormat('dd MMM yyyy').format(_selectedUnlockDate!)}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _messageController.text.isNotEmpty &&
                        _selectedUnlockDate != null) {
                      _capsulesCollection.add({
                        'title': _titleController.text.trim(),
                        'message': _messageController.text.trim(),
                        'unlock_date': Timestamp.fromDate(_selectedUnlockDate!),
                        'created_at': FieldValue.serverTimestamp(),
                      });
                      _titleController.clear();
                      _messageController.clear();
                      _selectedUnlockDate = null;
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9333EA),
                  ),
                  child: const Text(
                    'Sellar Cápsula',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Text(
          'Cápsula del Tiempo',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _capsulesCollection
              .orderBy('unlock_date', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF9333EA)),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No hay mensajes ocultos aún.',
                  style: GoogleFonts.lato(color: Colors.white54, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                DateTime unlockDate = (data['unlock_date'] as Timestamp)
                    .toDate();
                bool isLocked = DateTime.now().isBefore(unlockDate);

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? Colors.white.withOpacity(0.03)
                        : const Color(0xFF2563EB).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isLocked
                          ? Colors.white12
                          : const Color(0xFF3B82F6),
                      width: isLocked ? 1 : 2,
                    ),
                    boxShadow: isLocked
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              blurRadius: 15,
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['title'],
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            isLocked ? Icons.lock : Icons.lock_open,
                            color: isLocked
                                ? Colors.white38
                                : const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer,
                                color: Colors.white54,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Disponible el ${DateFormat('dd MMM, yyyy').format(unlockDate)}',
                                style: GoogleFonts.lato(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          data['message'],
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
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
          onPressed: _showAddCapsuleDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
