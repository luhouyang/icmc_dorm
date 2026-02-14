import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/pages/admin/small_admin_page.dart';
import 'package:icmc_dorm/pages/home/small_home_page.dart';
import 'package:icmc_dorm/pages/profile/small_profile_page.dart';
import 'package:icmc_dorm/states/app_state.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/snack_bar_text.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SmallRoutePage extends StatefulWidget {
  const SmallRoutePage({super.key});

  @override
  State<SmallRoutePage> createState() => _SmallRoutePageState();
}

class _SmallRoutePageState extends State<SmallRoutePage> {
  final iconList = <IconData>[
    Icons.home_outlined,
    Icons.person_outline,
    Icons.stacked_bar_chart_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    Future<void> launchUrlAsync(String urlString) async {
      final Uri url = Uri.parse(urlString);

      if (!await launchUrl(url)) {
        if (context.mounted) {
          SnackBarText().showBanner(msg: 'Could not launch $url', context: context);
        }
        throw Exception('Could not launch $url');
      }
    }

    return Consumer2<AppState, UserState>(
      builder: (context, appState, userState, child) {
        Widget getPage(int index) {
          if (index == 0) {
            return const SmallHomePage();
          } else if (index == 1) {
            return const SmallProfilePage();
          } else if (index == 2) {
            return const SmallAdminPage();
          }
          return const SmallHomePage();
        }

        return Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 54,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Image.asset('assets/profile_placeholder.jpg'),
                      const SizedBox(width: 12),
                      Text("ICMC Dorm", style: Theme.of(context).textTheme.displayMedium),
                      const Expanded(child: SizedBox()),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          launchUrlAsync(
                            "https://drive.google.com/file/d/15JMzr2nTlTdD2UmYF_Z5SD_p2-ZYuBJZ/view?usp=sharing",
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: getPage(appState.bottomNavIndex)),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            itemCount: iconList.length,
            tabBuilder: (int index, bool isActive) {
              final color = isActive ? Theme.of(context).iconTheme.color : UIColor().gray;

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(iconList[index], size: 24, color: color)],
              );
            },
            backgroundColor: UIColor().orangeBlack,
            activeIndex: appState.bottomNavIndex,
            splashColor: UIColor().transparentPrimaryOrange,
            gapLocation: GapLocation.none,
            onTap: (index) => appState.setBottomNavIndex(index),
          ),
        );
      },
    );
  }
}
