import 'package:flutter/material.dart';
import 'package:frontend/homepage.dart';
import 'package:frontend/komunitas.dart';
import 'package:frontend/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myIndex = 0;
  late List<Widget> widgetList;

  @override
  void initState(){
    super.initState();
    widgetList = [
      HomePage(),
      KomunitasScreen(),
      ProfileScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widgetList[myIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index){
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image_search), label: 'Cek Kesehatan'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Komunitas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'user'),
        ],
      ),
    );
  }
}