import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DailyPhotoScreen extends StatefulWidget {
  const DailyPhotoScreen({super.key});

  @override
  State<DailyPhotoScreen> createState() => _DailyPhotoScreenState();
}

class _DailyPhotoScreenState extends State<DailyPhotoScreen> {
  final CollectionReference _photosCollection = FirebaseFirestore.instance
      .collection('daily_photos');

  // 🔴 RECUERDA PONER TU CLOUD NAME AQUÍ
  final String cloudName = 'duflvehsk';
  final String uploadPreset = 'jf_preset';

  bool _isUploading = false;

  // Función para abrir el menú de opciones (Cámara o Galería)
  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF3B82F6)),
                title: Text(
                  'Tomar foto ahora',
                  style: GoogleFonts.lato(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF9333EA),
                ),
                title: Text(
                  'Elegir de la galería',
                  style: GoogleFonts.lato(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1080, // ⚡ EL TRUCO DE VELOCIDAD: Limita la resolución a 1080p
    );

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      await _uploadToCloudinary(File(pickedFile.path));
    }
  }

  Future<void> _uploadToCloudinary(File imageFile) async {
    final Uri url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final jsonMap = jsonDecode(responseString);

      final String imageUrl = jsonMap['secure_url'];

      await _photosCollection.add({
        'image_url': imageUrl,
        'uploaded_at': FieldValue.serverTimestamp(),
      });
    }

    setState(() => _isUploading = false);
  }

  void _showFullPhoto(
    BuildContext context,
    String imageUrl,
    DateTime? date,
    String docId,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            if (date != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('d MMMM, yyyy', 'es_ES').format(date),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Agregué también un botón de borrar por si suben una foto por error
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                  onPressed: () {
                    _photosCollection.doc(docId).delete();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Nuestro Álbum',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      // Cambiamos el onTap para que abra el menú de opciones
                      onTap: _isUploading
                          ? null
                          : () => _showPickerOptions(context),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9333EA).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _isUploading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_photo_alternate,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Añadir Recuerdo',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _photosCollection
                      .orderBy('uploaded_at', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error',
                          style: TextStyle(color: Colors.white),
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
                        child: Text(
                          'Aún no hay fotos. ¡Suban la primera! 📸',
                          style: GoogleFonts.lato(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var data = doc.data() as Map<String, dynamic>;
                        DateTime? date = (data['uploaded_at'] as Timestamp?)
                            ?.toDate();

                        return GestureDetector(
                          // Le pasamos el doc.id para poder borrarla si queremos
                          onTap: () => _showFullPhoto(
                            context,
                            data['image_url'],
                            date,
                            doc.id,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF9333EA).withOpacity(0.5),
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(data['image_url']),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
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
    );
  }
}
