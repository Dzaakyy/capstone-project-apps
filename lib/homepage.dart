import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Container(
                  height: 280,
                  padding: const EdgeInsets.fromLTRB(16, 70, 16, 0),
                  decoration: BoxDecoration(
                      color: Colors.indigo.shade300,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      )),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'Cek Kesehatan Tanaman Anda',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Image.asset('./lib/assets/mango.png',
                                height: 120),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 220, bottom: 30),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.photo_camera_outlined),
                                    SizedBox(height: 4),
                                    Text(
                                      'Ambil\nGambar',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right_rounded),
                                Column(
                                  children: [
                                    Icon(Icons.note_add_outlined),
                                    SizedBox(height: 4),
                                    Text(
                                      'Cek\nDiagnosis',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right_rounded),
                                Column(
                                  children: [
                                    Icon(Icons.energy_savings_leaf_outlined),
                                    SizedBox(height: 4),
                                    Text(
                                      'Rekomendasi\nPerawatan',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    minimumSize: const Size(200, 50),
                                  ),
                                  child: const Text(
                                    'Ambil Gambar',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 500,
              child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Diagnosis Anda',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                    child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: AssetImage('./lib/assets/gambar3.jpeg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '11 Maret',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Berack Hitam Bakteri',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded)
                        ],
                      ),
                    );
                  },
                ),
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}
