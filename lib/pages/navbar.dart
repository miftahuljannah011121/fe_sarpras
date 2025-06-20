import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list_barang_page.dart';
import 'pengembalian_form_page.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  int? _userId;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    setState(() {
      _userId = userId;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      const BarangListPage(),
      FormPengembalianPage(userId: _userId!), // Inject userId here
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("SISFO SARPRAS"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pinkAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Pengembalian',
          ),
        ],
      ),
    );
  }
}
