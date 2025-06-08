import 'package:flutter/material.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController onboardController = PageController();
  int indexPage = 0;
  List<Map<String, String>> pageList = [
    {
      "image": "",
      "subtitle": "Deteksi Instan Penyakit"
    },
    {
      "image": "",
      "subtitle": "Rekomendasi Perawatan"
    },
    {
      "image": "",
      "subtitle": "Tips Pertumbuhan yang Bermanfaat"
    }
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
            controller: onboardController,
            onPageChanged: (page){
              setState(() {
                indexPage = page;
              });
            },
            itemCount: pageList.length,
            itemBuilder: (context, index) {
              
            },
            )
            )
        ],
      ),
    );
  }
}


class OnBoardingData extends StatelessWidget {
  final String image;
  final String subtitle;

  const OnBoardingData(
    {super.key,
    required this.image,
    required this.subtitle
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        
      ],
    );
  }
}