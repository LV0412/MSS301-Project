part of '../../../app.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    this.totalSteps = 4,
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.children,
    this.next,
    this.buttonLabel = 'Tiếp tục',
    this.complete = false,
    this.completeDestination = const MainShell(),
    this.onComplete,
    this.resolveCompleteDestination,
  });

  final int step;
  final int totalSteps;
  final double progress;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? next;
  final String buttonLabel;
  final bool complete;
  final Widget completeDestination;
  final Future<void> Function(BuildContext context)? onComplete;
  final Future<Widget> Function(BuildContext context)?
  resolveCompleteDestination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leadingWidth: 42,
        leading: IconButton(
          icon: Icon(step == 1 ? Icons.close : Icons.arrow_back, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'NutriChef AI',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (step == 4)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: CircleAvatar(
                radius: 14,
                child: Icon(Icons.person, size: 16),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => Navigator.maybePop(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'BƯỚC $step TRÊN $totalSteps',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}% Hoàn tất',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.line,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: buttonLabel,
                  icon: Icons.arrow_forward,
                  onPressed: () async {
                    if (complete) {
                      try {
                        await onComplete?.call(context);
                      } on ApiException catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error.message)));
                        return;
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Không thể lưu hồ sơ: $error'),
                          ),
                        );
                        return;
                      }
                      if (!context.mounted) return;
                      final destination = resolveCompleteDestination == null
                          ? completeDestination
                          : await resolveCompleteDestination!(context);
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => destination),
                        (route) => false,
                      );
                    } else if (next != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => next!),
                      );
                    }
                  },
                ),
                if (step > 1) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Quay lại'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFrame extends StatelessWidget {
  const AuthFrame({super.key, required this.child, this.topLabel, this.footer});

  final Widget child;
  final String? topLabel;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          children: [
            if (topLabel != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  topLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 58),
            ],
            Container(
              padding: const EdgeInsets.fromLTRB(18, 30, 18, 24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: AppColors.darkGreen.withValues(alpha: .08),
                  ),
                ],
              ),
              child: child,
            ),
            if (footer != null) ...[
              const SizedBox(height: 28),
              Text(
                footer!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB8BDAF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.trailing,
    this.compact = false,
    this.controller,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final IconData? trailing;
  final bool compact;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: compact ? 52 : 48,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.muted),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    fontSize: compact ? 14 : 13,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: compact ? 14 : 13,
                      color: compact ? AppColors.darkGreen : AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (trailing != null)
                Icon(trailing, size: 17, color: AppColors.muted),
            ],
          ),
        ),
      ],
    );
  }
}

class SelectField extends StatelessWidget {
  const SelectField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 14)),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class GenderToggle extends StatefulWidget {
  const GenderToggle({super.key});

  @override
  State<GenderToggle> createState() => _GenderToggleState();
}

class _GenderToggleState extends State<GenderToggle> {
  bool _isMale = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Giới tính'),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(7),
                  onTap: () => setState(() => _isMale = true),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isMale ? AppColors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Nam',
                      style: TextStyle(
                        color: _isMale ? Colors.white : AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(7),
                  onTap: () => setState(() => _isMale = false),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isMale ? Colors.transparent : AppColors.green,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Nữ',
                      style: TextStyle(
                        color: _isMale ? AppColors.ink : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChoiceCard extends StatefulWidget {
  const ChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard> {
  late bool _selected = widget.selected;

  @override
  void didUpdateWidget(covariant ChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _selected = widget.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          setState(() => _selected = !_selected);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _selected ? AppColors.mint : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selected ? AppColors.green : AppColors.line,
            width: _selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _selected ? Colors.white : AppColors.field,
              child: Icon(widget.icon, size: 19, color: AppColors.green),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 19,
              color: _selected ? AppColors.green : const Color(0xFFB9C1B5),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.line)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'HOẶC',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.line)),
        ],
      ),
    );
  }
}

class AuthSwitchText extends StatelessWidget {
  const AuthSwitchText({
    super.key,
    required this.normal,
    required this.action,
    required this.onTap,
  });

  final String normal;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
          children: [
            TextSpan(text: normal),
            TextSpan(
              text: action,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            size: 20,
            color: AppColors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.muted,
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

class GoalMetricsCard extends StatelessWidget {
  const GoalMetricsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'Chỉ số mục tiêu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricCircle(value: '2.2k', label: 'CALO'),
              MetricCircle(value: '3.0L', label: 'NƯỚC'),
            ],
          ),
          const SizedBox(height: 22),
          const _MetricField(
            label: 'CALO MỖI NGÀY',
            value: '2200',
            suffix: 'kcal',
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _MacroBox(label: 'PROTEIN', value: '150g'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MacroBox(label: 'CARBS', value: '250g'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MacroBox(label: 'FAT', value: '70g'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _MetricField(
            label: 'LƯỢNG NƯỚC MỤC TIÊU',
            value: '3.0',
            suffix: 'Liters',
          ),
          const SizedBox(height: 16),
          const InfoPanel(
            title: 'Gợi ý từ NutriChef AI',
            text:
                'Dựa trên mục tiêu tăng cơ của bạn, chúng tôi sẽ tập trung vào lượng đạm cao trong từng bữa ăn.',
          ),
        ],
      ),
    );
  }
}

class MetricCircle extends StatelessWidget {
  const MetricCircle({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.green, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  const _MetricField({
    required this.label,
    required this.value,
    required this.suffix,
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(suffix, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroBox extends StatelessWidget {
  const _MacroBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.muted),
          ),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class TagPanel extends StatefulWidget {
  const TagPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.tags,
  });

  final String title;
  final IconData icon;
  final List<String> tags;

  @override
  State<TagPanel> createState() => _TagPanelState();
}

class _TagPanelState extends State<TagPanel> {
  final Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 18, color: AppColors.green),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in widget.tags)
                FilterChip(
                  selected: _selectedTags.contains(tag),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  }),
                  avatar: Icon(
                    _selectedTags.contains(tag) ? Icons.check : Icons.add,
                    size: 14,
                  ),
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.field,
                  selectedColor: AppColors.mint,
                  checkmarkColor: AppColors.green,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DietPanel extends StatefulWidget {
  const DietPanel({super.key});

  @override
  State<DietPanel> createState() => _DietPanelState();
}

class _DietPanelState extends State<DietPanel> {
  final Set<String> _selectedDiets = {};

  @override
  Widget build(BuildContext context) {
    final diets = [
      (Icons.block, 'Vegan'),
      (Icons.flash_on, 'Keto'),
      (Icons.star_border, 'Halal'),
      (Icons.table_restaurant_outlined, 'Địa Trung Hải'),
      (Icons.hiking, 'Paleo'),
      (Icons.all_inclusive, 'Ăn chay'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'Chế độ ăn uống',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: diets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.25,
            ),
            itemBuilder: (context, index) {
              final diet = diets[index];
              final selected = _selectedDiets.contains(diet.$2);
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() {
                  if (!selected) {
                    _selectedDiets.add(diet.$2);
                  } else {
                    _selectedDiets.remove(diet.$2);
                  }
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.mint : AppColors.field,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? AppColors.green : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(diet.$1, size: 17, color: AppColors.darkGreen),
                      const SizedBox(height: 4),
                      Text(
                        diet.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CuisinePanel extends StatefulWidget {
  const CuisinePanel({super.key});

  @override
  State<CuisinePanel> createState() => _CuisinePanelState();
}

class _CuisinePanelState extends State<CuisinePanel> {
  final Set<String> _selectedCuisines = {};

  @override
  Widget build(BuildContext context) {
    const cuisines = ['Việt Nam', 'Nhật Bản', 'Hàn Quốc', 'Ý'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.public, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'Ẩm thực yêu thích',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cuisines.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.85,
            ),
            itemBuilder: (context, index) {
              final cuisine = cuisines[index];
              final selected = _selectedCuisines.contains(cuisine);
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() {
                  if (!selected) {
                    _selectedCuisines.add(cuisine);
                  } else {
                    _selectedCuisines.remove(cuisine);
                  }
                }),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.green : Colors.transparent,
                      width: 2,
                    ),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E2B22), Color(0xFF8A6C37)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        cuisine,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tóm tắt hồ sơ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          _SummaryRow(label: 'Dị ứng', value: 'Chưa chọn'),
          _SummaryRow(label: 'Chế độ ăn', value: 'Chưa chọn'),
          _SummaryRow(label: 'Ẩm thực', value: 'Chưa chọn'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class PromoImage extends StatelessWidget {
  const PromoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 122,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF223729), Color(0xFFC99A39)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _FoodPattern()),
            Container(color: Colors.black.withValues(alpha: .24)),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Việc hiểu rõ cơ thể bạn là bước đầu tiên để AI của chúng tôi kiến tạo thực đơn hoàn hảo.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _foodLogIsoDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _mealTypeLabel(String value) {
  return switch (value) {
    'BREAKFAST' => 'Bữa sáng',
    'LUNCH' => 'Bữa trưa',
    'DINNER' => 'Bữa tối',
    'SNACK' => 'Bữa phụ',
    _ => value,
  };
}
