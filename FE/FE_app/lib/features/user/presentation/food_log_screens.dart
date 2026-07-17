part of '../../../app.dart';

class FoodLogButton extends StatelessWidget {
  const FoodLogButton({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
    this.compact = false,
  });

  final int recipeId;
  final String recipeTitle;
  final bool compact;

  Future<void> _openEditor(BuildContext context) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          FoodLogEditorDialog(recipeId: recipeId, recipeTitle: recipeTitle),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm món vào nhật ký ăn uống.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        tooltip: 'Đã ăn / thêm vào bữa',
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.restaurant_menu, color: AppColors.green),
      );
    }
    return FilledButton.icon(
      onPressed: () => _openEditor(context),
      icon: const Icon(Icons.add_circle_outline, size: 17),
      label: const Text('Đã ăn'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 42),
      ),
    );
  }
}

class FoodLogEditorDialog extends StatefulWidget {
  const FoodLogEditorDialog({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
    this.entry,
  });

  final int recipeId;
  final String recipeTitle;
  final FoodLogEntry? entry;

  @override
  State<FoodLogEditorDialog> createState() => _FoodLogEditorDialogState();
}

class _FoodLogEditorDialogState extends State<FoodLogEditorDialog> {
  late final TextEditingController _quantityController = TextEditingController(
    text: widget.entry?.quantity.toString() ?? '1',
  );
  late String _mealType = widget.entry?.mealType ?? 'LUNCH';
  late DateTime _date =
      DateTime.tryParse(widget.entry?.logDate ?? '') ?? DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _save() async {
    final quantity = double.tryParse(
      _quantityController.text.trim().replaceAll(',', '.'),
    );
    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Quantity phải lớn hơn 0.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final store = AuthDependencies.instance.foodLogStore;
      final entry = widget.entry;
      if (entry == null) {
        await store.create(
          recipeId: widget.recipeId,
          quantity: quantity,
          mealType: _mealType,
          logDate: _foodLogIsoDate(_date),
        );
      } else {
        await store.update(
          logId: entry.logId,
          recipeId: entry.recipeId,
          quantity: quantity,
          mealType: _mealType,
          logDate: _foodLogIsoDate(_date),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.entry == null ? 'Thêm vào bữa' : 'Sửa food log'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipeTitle,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _mealType,
              decoration: const InputDecoration(
                labelText: 'Bữa ăn',
                border: OutlineInputBorder(),
              ),
              items: const ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK']
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_mealTypeLabel(value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _mealType = value!),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: const Text('Ngày ăn'),
              subtitle: Text(_foodLogIsoDate(_date)),
              onTap: _pickDate,
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Đang lưu...' : 'Lưu'),
        ),
      ],
    );
  }
}

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  DateTime _date = DateTime.now();
  String? _mealType;
  late Future<List<FoodLogEntry>> _logsFuture = _load();

  Future<List<FoodLogEntry>> _load() {
    return AuthDependencies.instance.foodLogStore.load(
      date: _foodLogIsoDate(_date),
      mealType: _mealType,
    );
  }

  void _reload() => setState(() => _logsFuture = _load());

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null && mounted) {
      setState(() {
        _date = selected;
        _logsFuture = _load();
      });
    }
  }

  Future<void> _edit(FoodLogEntry entry) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => FoodLogEditorDialog(
        recipeId: entry.recipeId,
        recipeTitle: entry.recipe?.title ?? 'Recipe #${entry.recipeId}',
        entry: entry,
      ),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(FoodLogEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa food log?'),
        content: Text(entry.recipe?.title ?? 'Recipe #${entry.recipeId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AuthDependencies.instance.foodLogStore.delete(entry.logId);
      if (mounted) _reload();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Nhật ký ăn uống',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(_foodLogIsoDate(_date)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _mealType,
                    decoration: const InputDecoration(
                      labelText: 'Bữa ăn',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ...const ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'].map(
                        (value) => DropdownMenuItem<String?>(
                          value: value,
                          child: Text(_mealTypeLabel(value)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      _mealType = value;
                      _reload();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FoodLogEntry>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: FilledButton(
                      onPressed: _reload,
                      child: const Text('Không thể tải - Thử lại'),
                    ),
                  );
                }
                final logs = snapshot.data ?? const [];
                if (logs.isEmpty) {
                  return const Center(
                    child: Text('Chưa có món nào trong ngày.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  itemCount: logs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = logs[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.restaurant_menu),
                        ),
                        title: Text(
                          entry.recipe?.title ?? 'Recipe #${entry.recipeId}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${_mealTypeLabel(entry.mealType)} • Quantity: ${entry.quantity} • ${entry.logDate}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Sửa',
                              onPressed: () => _edit(entry),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Xóa',
                              onPressed: () => _delete(entry),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
