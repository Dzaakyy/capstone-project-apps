import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; 
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/community/presentation/pages/community_screen.dart';
import 'package:frontend/features/community/presentation/pages/ask_community_screen.dart';
import 'package:frontend/features/profile/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myIndex = 1;
  late List<Widget> widgetList;

  @override
  void initState(){
    super.initState();
    widgetList = [
      const KomunitasScreen(),
      HomePage(cameras: widget.cameras), 
      ProfileScreen(cameras: widget.cameras)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double bottomNavHeight = 90; // perkiraan tinggi floating nav
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: myIndex,
        children: widgetList,
      ),
      // FAB hanya muncul saat tab Komunitas (index 0)
      floatingActionButton: myIndex == 0
          ? Padding(
              // Angkat FAB di atas bottom nav bar (tinggi nav + margin)
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TanyaKomunitasPage()),
                  ).then((_) {
                    // Refresh komunitas setelah post dibuat
                    setState(() {});
                  });
                },
                backgroundColor: const Color(0xFF2563EB),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'Buat Post',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            showUnselectedLabels: false,
            showSelectedLabels: true,
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                myIndex = index;
              });
            },
            currentIndex: myIndex,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.people_alt_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.people_alt),
                ),
                label: 'Komunitas',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_rounded),
                ),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
