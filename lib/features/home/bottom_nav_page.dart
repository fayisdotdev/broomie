import 'package:broomie/features/account/presentation/accounts.dart';
import 'package:broomie/features/bookings/presentation/bookings.dart';
import 'package:broomie/features/home/home_page.dart';
import 'package:broomie/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BookingsScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // allows floating bar to overlay content
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: AppColorsPage.primaryColor.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) {
                  IconData icon;
                  String label;
                  switch (index) {
                    case 0:
                      icon = Icons.home;
                      label = 'Home';
                      break;
                    case 1:
                      icon = Icons.calendar_today;
                      label = 'Bookings';
                      break;
                    case 2:
                    default:
                      icon = Icons.person;
                      label = 'Account';
                      break;
                  }
                  final isActive = _currentIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = index),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: isActive
                                ? AppColorsPage.secondaryColor
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive
                                  ? AppColorsPage.secondaryColor
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 3,
                            width: isActive ? 20 : 0,
                            decoration: BoxDecoration(
                              color: AppColorsPage.secondaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
