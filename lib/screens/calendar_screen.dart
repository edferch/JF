import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CollectionReference _eventsCollection = FirebaseFirestore.instance
      .collection('calendar_events');
  final TextEditingController _eventController = TextEditingController();

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // ❤️ TODO: ¡Cambia esta fecha por el día exacto de su aniversario!
  final DateTime _anniversaryDate = DateTime(2023, 5, 14);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Plan para el ${DateFormat('dd MMM', 'es_ES').format(_selectedDay!)}',
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
          ),
          content: TextField(
            controller: _eventController,
            style: const TextStyle(color: Colors.white),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: '¿Qué haremos este día?',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9333EA)),
              ), // Morado
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
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF9333EA),
                  ], // Azul a Morado del Logo
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_eventController.text.isNotEmpty) {
                    _eventsCollection.add({
                      'title': _eventController.text,
                      'event_date': Timestamp.fromDate(
                        DateTime(
                          _selectedDay!.year,
                          _selectedDay!.month,
                          _selectedDay!.day,
                        ),
                      ),
                      'created_at': FieldValue.serverTimestamp(),
                    });
                    _eventController.clear();
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

  void _deleteEvent(String docId) {
    _eventsCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateStart = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final selectedDateEnd = selectedDateStart.add(const Duration(days: 1));

    // Calculamos los días juntos
    final int daysTogether = DateTime.now().difference(_anniversaryDate).inDays;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E1B4B),
            ], // Fondo oscuro elegante
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ❤️ CONTADOR DE DÍAS (Idea 4)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEC4899),
                      Color(0xFF9333EA),
                    ], // Rosa a Morado
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      '$daysTogether días de aventuras juntos',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              // 1. El widget del Calendario (Ahora en Español)
              TableCalendar(
                locale: 'es_ES', // FUERZA EL IDIOMA ESPAÑOL
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.lato(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: GoogleFonts.lato(
                    color: const Color(0xFF9333EA),
                    fontWeight: FontWeight.bold,
                  ), // Fin de semana morado
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  weekendTextStyle: GoogleFonts.lato(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  outsideTextStyle: GoogleFonts.lato(
                    color: Colors.white24,
                    fontSize: 16,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(
                      0xFF9333EA,
                    ), // Círculo Morado para el día seleccionado
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(
                      0xFF2563EB,
                    ).withOpacity(0.5), // Círculo Azul para hoy
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const Spacer(),

              // 2. La "Tarjeta Blanca Flotante"
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('d').format(_selectedDay!),
                      style: GoogleFonts.montserrat(
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[400],
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _eventsCollection
                              .where(
                                'event_date',
                                isGreaterThanOrEqualTo: Timestamp.fromDate(
                                  selectedDateStart,
                                ),
                              )
                              .where(
                                'event_date',
                                isLessThan: Timestamp.fromDate(selectedDateEnd),
                              )
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF9333EA),
                                ),
                              );
                            }

                            if (snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'Día libre',
                                  style: GoogleFonts.lato(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            return ListView(
                              padding: EdgeInsets.zero,
                              children: snapshot.data!.docs.map((
                                DocumentSnapshot document,
                              ) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                String docId = document.id;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        color: Color(0xFF9333EA),
                                        size: 16,
                                      ), // Corazón Morado
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          data['title'],
                                          style: GoogleFonts.lato(
                                            color: const Color(0xFF2D2D2D),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _deleteEvent(docId),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.grey[300],
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Barra inferior con la fecha y el botón "Añadir plan"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // Formato de fecha en español (ej: 28 febrero, 2024)
                      DateFormat('d MMMM, yyyy', 'es_ES').format(_selectedDay!),
                      style: GoogleFonts.lato(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
                      onTap: _showAddEventDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF9333EA),
                            ], // Degradado del logo
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9333EA).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Añadir plan',
                              style: GoogleFonts.lato(
                                color: Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }
}
