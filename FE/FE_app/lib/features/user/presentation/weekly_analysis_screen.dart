part of '../../../app.dart';

class WeeklyAnalysisScreen extends StatefulWidget {
  const WeeklyAnalysisScreen({super.key});

  @override
  State<WeeklyAnalysisScreen> createState() => _WeeklyAnalysisScreenState();
}

class _WeeklyAnalysisScreenState extends State<WeeklyAnalysisScreen> {
  late Future<_WeeklyNutritionData> _future = _load();

  Future<_WeeklyNutritionData> _load() async {
    final dependencies = AuthDependencies.instance;
    final account = await dependencies.repository.me();
    final end = DateTime.now();
    final days = List.generate(
      7,
      (index) => DateTime(end.year, end.month, end.day - 6 + index),
    );
    final goalFuture = dependencies.userRepository.getNutritionGoal(
      account.userId,
    );
    final logsByDay = await Future.wait(
      days.map(
        (day) => dependencies.foodLogStore.load(date: _foodLogIsoDate(day)),
      ),
    );
    final goal = await goalFuture;
    final dailyTotals = logsByDay.map(_NutritionTotals.fromLogs).toList();
    final total = dailyTotals.fold(
      const _NutritionTotals(),
      (sum, item) => sum + item,
    );
    return _WeeklyNutritionData(
      days: days,
      dailyTotals: dailyTotals,
      total: total,
      caloriesTarget: _asDouble(goal?['calories']),
      proteinTarget: _asDouble(goal?['protein']),
      carbsTarget: _asDouble(goal?['carbs']),
      fatTarget: _asDouble(goal?['fat']),
    );
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            FutureBuilder<_WeeklyNutritionData>(
              future: _future,
              builder: (context, snapshot) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 112),
                  children: [
                    const WeeklyAnalysisTopBar(),
                    const SizedBox(height: 22),
                    const Text(
                      'Tổng quan dinh dưỡng\n7 ngày',
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tổng hợp từ nhật ký ăn uống và mục tiêu dinh dưỡng.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (snapshot.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 100),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.green,
                          ),
                        ),
                      )
                    else if (snapshot.hasError)
                      ApiMessageBanner(
                        message: 'Không thể tải dữ liệu dinh dưỡng 7 ngày.',
                        isError: true,
                        actionLabel: 'Thử lại',
                        onAction: _retry,
                      )
                    else ...[
                      _WeeklyDateRangePill(data: snapshot.requireData),
                      const SizedBox(height: 28),
                      _WeeklyGoalCard(data: snapshot.requireData),
                      const SizedBox(height: 16),
                      _CalorieTrendCard(data: snapshot.requireData),
                      const SizedBox(height: 16),
                      _WeeklyMacroCard(data: snapshot.requireData),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
