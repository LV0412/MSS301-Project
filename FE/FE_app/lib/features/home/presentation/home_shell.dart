part of '../../../app.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = HomeTab.home});

  final HomeTab initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late HomeTab _selected;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTab;
    _screens = [
      HomeScreen(onTabSelected: _selectTab),
      ExploreRecipesScreen(onTabSelected: _selectTab),
      ApiUserProfileScreen(onTabSelected: _selectTab),
    ];
  }

  void _selectTab(HomeTab tab) {
    if (tab != _selected) setState(() => _selected = tab);
  }

  int get _selectedIndex => switch (_selected) {
    HomeTab.home => 0,
    HomeTab.explore => 1,
    HomeTab.profile => 2,
  };

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: _selectedIndex, children: _screens);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onTabSelected});

  final ValueChanged<HomeTab>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              children: [
                const HomeHeader(),
                const SizedBox(height: 28),
                const DailyCaloriesCard(),
                const SizedBox(height: 18),
                const MacroSummaryCard(),
                const SizedBox(height: 26),
                const TodayMenuHeader(),
                const SizedBox(height: 12),
                const ApiTodayMealList(),
                const SizedBox(height: 18),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(onSelected: onTabSelected),
            ),
          ],
        ),
      ),
    );
  }
}
