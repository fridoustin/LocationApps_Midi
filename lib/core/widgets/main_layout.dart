// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/formkplt_screen.dart';
import 'package:midi_location/features/home/presentation/pages/home_screen.dart';
import 'package:midi_location/features/profile/presentation/pages/profile_screen.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_screen.dart';
import 'package:midi_location/core/widgets/navigation/navigation_bar.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_form_page.dart';

class MainLayout extends StatefulWidget {
  final int currentIndex;
  final PreferredSizeWidget? appBar;

  const MainLayout({super.key, required this.currentIndex, this.appBar});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    ULOKPage(),
    FormKPLTPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: widget.appBar,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: NavigationBarWidget(
          currentIndex: _currentIndex,
          onItemTapped: _onItemTapped,
          onCenterButtonTapped: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UlokFormPage()),
            );
          },
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
    );
  }
}
