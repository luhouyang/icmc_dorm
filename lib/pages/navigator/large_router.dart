import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icmc_dorm/pages/admin/large_admin_page.dart';
import 'package:icmc_dorm/pages/home/large_home_page.dart';
import 'package:icmc_dorm/pages/profile/large_profile_page.dart';
import 'package:icmc_dorm/states/app_state.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/snack_bar_text.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NavItemModel {
  const NavItemModel({required this.idx, required this.name, required this.icon});

  final int idx;
  final String name;
  final IconData icon;
}

extension on Widget {
  Widget? showOrNull(bool isShow) => isShow ? this : null;
}

class LargeRoutePage extends StatefulWidget {
  const LargeRoutePage({super.key});

  @override
  State<LargeRoutePage> createState() => _LargeRoutePageState();
}

class _LargeRoutePageState extends State<LargeRoutePage> {
  final _sideMenuController = SideMenuController();

  final _navItems = const [
    NavItemModel(idx: 0, name: 'Home', icon: Icons.home_outlined),
    NavItemModel(idx: 1, name: 'Profile', icon: Icons.person_outline),
    NavItemModel(idx: 2, name: 'Admin', icon: Icons.stacked_bar_chart_outlined),
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
            return const LargeHomePage();
          } else if (index == 1) {
            return const LargeProfilePage();
          } else if (index == 2) {
            return const LargeAdminPage();
          }
          return LargeHomePage();
        }

        return Scaffold(
          body: Row(
            children: [
              SideMenu(
                backgroundColor: UIColor().orangeBlack,
                hasResizerToggle: false,
                hasResizer: false,
                controller: _sideMenuController,
                mode: appState.isNavBarCollapsed ? SideMenuMode.compact : SideMenuMode.open,
                minWidth: 75,
                maxWidth: 270,
                builder: (data) {
                  return SideMenuData(
                    header: Column(
                      children: [
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkWell(
                              onHover: (value) {},
                              onTap: () {
                                appState.setNavBarCollapsed(!appState.isNavBarCollapsed);
                              },
                              child:
                                  appState.isNavBarCollapsed
                                      ? Icon(
                                        Icons.menu_outlined,
                                        color: Theme.of(context).iconTheme.color,
                                      )
                                      : Icon(
                                        Icons.menu_open_outlined,
                                        color: Theme.of(context).iconTheme.color,
                                      ),
                            ),
                          ),
                          title: Text(
                            'ICMC Dorm',
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color: UIColor().white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ).showOrNull(!appState.isNavBarCollapsed),
                        ),
                      ],
                    ),
                    items: [
                      ..._navItems.map(
                        (e) => SideMenuItemDataTile(
                          isSelected: e.idx == appState.bottomNavIndex,
                          onTap: () {
                            appState.setBottomNavIndex(e.idx);
                          },
                          title: e.name,
                          titleStyle: GoogleFonts.inter(
                            textStyle: TextStyle(color: UIColor().lightGray, fontSize: 16),
                          ),
                          hoverColor: UIColor().transparentPrimaryOrange,
                          hasSelectedLine: false,
                          highlightSelectedColor: UIColor().transparentPrimaryOrange,
                          selectedTitleStyle: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          icon: Icon(
                            e.icon,
                            color:
                                e.idx == appState.bottomNavIndex
                                    ? Theme.of(context).iconTheme.color
                                    : UIColor().gray,
                          ),
                        ),
                      ),
                    ],
                    footer: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              launchUrlAsync(
                                "https://drive.google.com/file/d/15JMzr2nTlTdD2UmYF_Z5SD_p2-ZYuBJZ/view?usp=sharing",
                              );
                            },
                            icon: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: getPage(appState.bottomNavIndex),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
