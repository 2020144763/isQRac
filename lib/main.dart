import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

import 'QRScanner.dart';
import 'reports_page.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IsQRac',
      theme: ThemeData(
        primaryColor: Colors.white,
        backgroundColor: Colors.grey[200],
        accentColor: Colors.grey,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.grey[800]),
          bodyText2: TextStyle(color: Colors.grey[700]),
          headline1: TextStyle(color: Colors.grey[900]),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final String email;
  final int selectedIndex;

  HomePage({required this.email, this.selectedIndex = 1});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  List<Widget> _pages() => [
        QRScanner(),
        ReportsPage(),
      ];

  List<String> _appBarTitles() => [
        'IsQRac',
        'IsQRac - Relatórios',
      ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1
          ? AppBar(
              title: Text(_appBarTitles()[_selectedIndex]),
            )
          : null,
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.align_horizontal_right_rounded),
            label: 'Relatórios',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
