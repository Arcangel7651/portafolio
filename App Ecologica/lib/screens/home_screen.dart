// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'events_screen.dart';
import 'marketplace_screen.dart';
import 'profile_screen.dart';
import 'my_publication_screen.dart';
import 'forum_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const EventsScreen(),
    const MarketplaceScreen(),
    const ForumScreen(), // Placeholder para la sección de preguntas
    const ProfileScreen(),
    const MyPublicationsScreen(), // Placeholder para mis publicaciones
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Mercado',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Preguntas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Mis Pub.',
          ),
        ],
      ),
    );
  }
}
