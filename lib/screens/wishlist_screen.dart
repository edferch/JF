import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final CollectionReference _wishlistCollection = FirebaseFirestore.instance
      .collection('wishlist');

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController =
      TextEditingController(); // Nuevo controlador para la categoría libre

  String _currentFilter = 'Todas';

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // Cuadro de diálogo elegante para crear un deseo y su categoría
  void _showAddWishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Añadir un deseo ✨',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para el Deseo
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: '¿Qué quieren hacer?',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Campo para la Categoría Libre
              TextField(
                controller: _categoryController,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Categoría (Ej: Viajes, Cenas...)',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _titleController.clear();
                _categoryController.clear();
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
                  if (_titleController.text.isNotEmpty &&
                      _categoryController.text.isNotEmpty) {
                    _wishlistCollection.add({
                      'title': _titleController.text.trim(),
                      'category': _categoryController.text.trim(),
                      'is_done': false,
                      'added_at': FieldValue.serverTimestamp(),
                    });
                    _titleController.clear();
                    _categoryController.clear();
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

  void _toggleWishStatus(String docId, bool currentStatus) {
    _wishlistCollection.doc(docId).update({'is_done': !currentStatus});
  }

  void _deleteWish(String docId) {
    _wishlistCollection.doc(docId).delete();
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
                child: Text(
                  'Lista de Deseos',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // 2. Stream principal para obtener TODO y extraer las categorías
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _wishlistCollection
                      .orderBy('added_at', descending: true)
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

                    var allDocs = snapshot.data!.docs;

                    // ✨ MAGIA: Extraemos las categorías únicas de los documentos existentes
                    Set<String> dynamicCategories = allDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['category'] ?? 'Otra').toString();
                    }).toSet();
                    List<String> filterOptions = [
                      'Todas',
                      ...dynamicCategories,
                    ];

                    // Si el filtro actual fue borrado, lo regresamos a 'Todas'
                    if (!filterOptions.contains(_currentFilter)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => _currentFilter = 'Todas');
                      });
                    }

                    // Filtramos la lista localmente según el botón seleccionado
                    var filteredDocs = allDocs;
                    if (_currentFilter != 'Todas') {
                      filteredDocs = allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return (data['category'] ?? 'Otra') == _currentFilter;
                      }).toList();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3. Barra de Filtros Dinámica
                        if (allDocs.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Row(
                              children: filterOptions.map((filter) {
                                bool isSelected = _currentFilter == filter;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Text(
                                      filter,
                                      style: GoogleFonts.lato(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFF9333EA),
                                    backgroundColor: Colors.white.withOpacity(
                                      0.05,
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? const Color(0xFF9333EA)
                                          : Colors.transparent,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _currentFilter = filter);
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 10),

                        // 4. Lista de Deseos (Tarjetas)
                        Expanded(
                          child: filteredDocs.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hay deseos aquí. ¡Añadan uno! 💭',
                                    style: GoogleFonts.lato(
                                      color: Colors.white54,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  itemCount: filteredDocs.length,
                                  itemBuilder: (context, index) {
                                    var data =
                                        filteredDocs[index].data()
                                            as Map<String, dynamic>;
                                    String docId = filteredDocs[index].id;
                                    bool isDone = data['is_done'] ?? false;

                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? Colors.white.withOpacity(0.02)
                                            : Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: isDone
                                              ? Colors.transparent
                                              : Colors.white.withOpacity(0.1),
                                        ),
                                        boxShadow: isDone
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 8,
                                            ),
                                        leading: GestureDetector(
                                          onTap: () =>
                                              _toggleWishStatus(docId, isDone),
                                          child: Icon(
                                            isDone
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isDone
                                                ? Colors.grey[600]
                                                : const Color(
                                                    0xFFEC4899,
                                                  ), // Corazón rosa brillante
                                            size: 28,
                                          ),
                                        ),
                                        title: Text(
                                          data['title'],
                                          style: GoogleFonts.lato(
                                            color: isDone
                                                ? Colors.white38
                                                : Colors.white,
                                            fontSize: 18,
                                            fontWeight: isDone
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        subtitle: Text(
                                          data['category']
                                              .toString()
                                              .toUpperCase(),
                                          style: GoogleFonts.montserrat(
                                            color: isDone
                                                ? Colors.white24
                                                : const Color(
                                                    0xFF3B82F6,
                                                  ), // Azul del logo
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                          onPressed: () => _deleteWish(docId),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // 5. Botón Flotante para Añadir Deseo
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
          onPressed: _showAddWishDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
