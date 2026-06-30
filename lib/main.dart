import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

// Importa todas tus pantallas
import 'screens/login_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/gestor_tasks_screen.dart';
import 'screens/daily_photo_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/amor_screen.dart'; // Nueva Importación

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES', null);

  // Configuración Mágica de OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("a3a7e092-bc97-410c-a58f-a41a1be297b9");
  OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          primary: const Color(0xFF9333EA),
          secondary: const Color(0xFF2563EB),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
        textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainNavigationScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Lista con las 6 pantallas oficiales de JF
  final List<Widget> _screens = [
    const CalendarScreen(),
    const GestorTasksScreen(),
    const DailyPhotoScreen(),
    const WishlistScreen(),
    const PrayerScreen(),
    const AmorScreen(), // Sexta pestaña agregada
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF9333EA) : Colors.transparent,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF9333EA).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 22,
        ), // Reducido levemente para ajustar los 6 iconos con soltura
      ),
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'JF',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          // Mantenemos solo el botón de salida limpio en la esquina
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: Colors.white54),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _screens[_selectedIndex],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white38,
              items: [
                _buildNavItem(Icons.calendar_month, 0),
                _buildNavItem(Icons.playlist_add_check, 1),
                _buildNavItem(Icons.camera_alt, 2),
                _buildNavItem(Icons.star, 3),
                _buildNavItem(Icons.volunteer_activism, 4),
                _buildNavItem(
                  Icons.favorite,
                  5,
                ), // Icono de Corazón para la sección de Amor
              ],
            ),
          ),
        ),
      ),
    );
  }
}
