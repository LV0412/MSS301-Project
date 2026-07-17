part of '../../../app.dart';

class WeeklyAnalysisTopBar extends StatelessWidget {
  const WeeklyAnalysisTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Quay lại',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 20),
        ),
        const Expanded(
          child: Text(
            'NutriChef AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklyDateRangePill extends StatelessWidget {
  const _WeeklyDateRangePill({required this.data});
  final _WeeklyNutritionData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 16,
            color: AppColors.green,
          ),
          const SizedBox(width: 10),
          Text(
            '${_shortDate(data.days.first)} - ${_shortDate(data.days.last)}',
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: .8,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard({required this.data});
  final _WeeklyNutritionData data;

  @override
  Widget build(BuildContext context) {
    return WeeklyCard(
      child: Column(
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 94,
                  height: 94,
                  child: CircularProgressIndicator(
                    value: data.calorieProgress,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    color: AppColors.green,
                    backgroundColor: AppColors.line,
                  ),
                ),
                Text(
                  '${(data.calorieProgress * 100).round()}%\nCALO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Mục tiêu Tuần',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.caloriesTarget == null
                ? 'Chưa thiết lập mục tiêu calories trong hồ sơ.'
                : '${_formatCalories(data.total.calories)} / ${_formatCalories(data.caloriesTarget! * 7)} kcal trong 7 ngày.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieTrendCard extends StatelessWidget {
  const _CalorieTrendCard({required this.data});
  final _WeeklyNutritionData data;

  @override
  Widget build(BuildContext context) {
    return WeeklyCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Xu hướng Calorie',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Icon(Icons.info_outline, size: 18, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _WeeklyTrendPainter(
                data.dailyTotals.map((item) => item.calories).toList(),
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayLabel('T2'),
              _DayLabel('T3'),
              _DayLabel('T4'),
              _DayLabel('T5'),
              _DayLabel('T6'),
              _DayLabel('T7'),
              _DayLabel('CN'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyMacroCard extends StatelessWidget {
  const _WeeklyMacroCard({required this.data});
  final _WeeklyNutritionData data;

  @override
  Widget build(BuildContext context) {
    return WeeklyCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chỉ số Macro',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 18),
          MacroProgressRow(
            label: 'Protein',
            value: _weeklyMacroValue(data.total.protein, data.proteinTarget),
            progress: _weeklyMacroProgress(
              data.total.protein,
              data.proteinTarget,
            ),
            color: AppColors.green,
          ),
          const SizedBox(height: 13),
          MacroProgressRow(
            label: 'Carbs',
            value: _weeklyMacroValue(data.total.carbs, data.carbsTarget),
            progress: _weeklyMacroProgress(data.total.carbs, data.carbsTarget),
            color: const Color(0xFFB8A086),
          ),
          const SizedBox(height: 13),
          MacroProgressRow(
            label: 'Fat',
            value: _weeklyMacroValue(data.total.fat, data.fatTarget),
            progress: _weeklyMacroProgress(data.total.fat, data.fatTarget),
            color: const Color(0xFF5F6057),
          ),
        ],
      ),
    );
  }
}

class WeeklyAiAnalysisCard extends StatelessWidget {
  const WeeklyAiAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.field.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.green,
                child: Icon(
                  Icons.psychology_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Phân tích từ AI\nNutriChef',
                style: TextStyle(
                  fontSize: 19,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          WeeklyInsightLine(
            icon: Icons.check_circle_outline,
            title: 'Bạn đã đạt đủ protein:',
            body:
                'Tuần này mức tiêu thụ protein trung bình là 145g/ngày, rất tốt cho quá trình duy trì cơ bắp.',
          ),
          WeeklyInsightLine(
            icon: Icons.warning_amber_outlined,
            title: 'Lượng chất xơ còn thấp:',
            body:
                'Bạn chỉ đạt 65% mục tiêu chất xơ. Hãy bổ sung thêm các loại rau lá xanh trong bữa tối.',
          ),
          WeeklyInsightLine(
            icon: Icons.lightbulb_outline,
            title: '',
            body:
                'Thời gian ăn tối của bạn đang muộn dần về cuối tuần, có thể ảnh hưởng đến chất lượng giấc ngủ.',
          ),
        ],
      ),
    );
  }
}

class WeeklyInsightLine extends StatelessWidget {
  const WeeklyInsightLine({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.darkGreen),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.ink,
                ),
                children: [
                  if (title.isNotEmpty)
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NextWeekSuggestionsCard extends StatelessWidget {
  const NextWeekSuggestionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WeeklyCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đề xuất tuần tới',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 18),
          const NextSuggestionTile(
            color: Color(0xFFF4D6BA),
            icon: Icons.eco_outlined,
            title: 'Tăng chất xơ',
            subtitle: 'Thêm 10g mỗi ngày',
          ),
          const SizedBox(height: 12),
          const NextSuggestionTile(
            color: Color(0xFFDDEED0),
            icon: Icons.restaurant,
            title: 'Thực đơn Địa Trung Hải',
            subtitle: 'Tối ưu cho sức khỏe tim mạch',
          ),
          const SizedBox(height: 12),
          const NextSuggestionTile(
            color: AppColors.sand,
            icon: Icons.water_drop_outlined,
            title: 'Cấp nước đều đặn',
            subtitle: 'Uống 2.5L nước/ngày',
          ),
        ],
      ),
    );
  }
}

class NextSuggestionTile extends StatelessWidget {
  const NextSuggestionTile({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewWeekMealCard extends StatelessWidget {
  const NewWeekMealCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: AppColors.darkGreen.withValues(alpha: .16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const MealArt(palette: MealPalette.lunch),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .78),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 24,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ExploreTag(label: 'HEALTHY CHOICE', dark: true),
                SizedBox(height: 10),
                Text(
                  'Salad Cầu Vồng\nvới Sốt Tahini\nChanh',
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sự kết hợp hoàn hảo giữa chất xơ và protein thực vật để khởi đầu tuần mới đầy năng lượng.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyCard extends StatelessWidget {
  const WeeklyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: AppColors.darkGreen.withValues(alpha: .035),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
    );
  }
}

class _WeeklyTrendPainter extends CustomPainter {
  const _WeeklyTrendPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.line.withValues(alpha: .45)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final scale = maxValue <= 0 ? 1.0 : maxValue;
    final points = List.generate(values.length, (index) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * index / (values.length - 1);
      final y = size.height - (values[index] / scale * size.height * .82) - 6;
      return Offset(x, y);
    });

    final fill = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fill.lineTo(point.dx, point.dy);
    }
    fill
      ..lineTo(points.last.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = AppColors.mint.withValues(alpha: .48),
    );

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.green
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = AppColors.green);
      canvas.drawCircle(
        point,
        7,
        Paint()..color = AppColors.green.withValues(alpha: .14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyTrendPainter oldDelegate) =>
      oldDelegate.values != values;
}
