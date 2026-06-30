import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class GestorTasksScreen extends StatefulWidget {
  const GestorTasksScreen({super.key});

  @override
  State<GestorTasksScreen> createState() => _GestorTasksScreenState();
}

class _GestorTasksScreenState extends State<GestorTasksScreen> {
  final TextEditingController _taskController = TextEditingController();
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('shared_tasks');

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      _tasksCollection.add({
        'title': _taskController.text,
        'is_completed': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      _taskController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _toggleTaskStatus(String docId, bool currentStatus) {
    _tasksCollection.doc(docId).update({'is_completed': !currentStatus});
  }

  void _deleteTask(String docId) {
    _tasksCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo oscuro para mantener la cohesión visual
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
                child: Text(
                  'Nuestros Pendientes',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // 2. Input para agregar tareas
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        style: const TextStyle(color: Colors.white),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Agregar nueva tarea...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFF8B5CF6),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón de agregar con degradado del logo
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF9333EA),
                          ], // Azul a Morado
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9333EA).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _addTask,
                        icon: const Icon(Icons.add, color: Colors.white),
                        iconSize: 28,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 3. Lista de tareas en tiempo real
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _tasksCollection
                      .orderBy('created_at', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar.',
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
                              Icons.check_circle_outline,
                              size: 80,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '¡Todo al día!',
                              style: GoogleFonts.montserrat(
                                color: Colors.white54,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No hay pendientes por ahora.',
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
                        Map<String, dynamic> data =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        String docId = snapshot.data!.docs[index].id;
                        bool isCompleted = data['is_completed'] ?? false;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.white.withOpacity(0.02)
                                : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isCompleted
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: GestureDetector(
                              onTap: () =>
                                  _toggleTaskStatus(docId, isCompleted),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isCompleted
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF2563EB),
                                            Color(0xFF9333EA),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  border: isCompleted
                                      ? null
                                      : Border.all(
                                          color: Colors.white54,
                                          width: 2,
                                        ),
                                ),
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            ),
                            title: Text(
                              data['title'],
                              style: GoogleFonts.lato(
                                color: isCompleted
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: isCompleted
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              onPressed: () => _deleteTask(docId),
                              highlightColor: Colors.redAccent.withOpacity(0.2),
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
    );
  }
}
