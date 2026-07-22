part of '../../../app.dart';

class EditBasicProfileScreen extends StatefulWidget {
  const EditBasicProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditBasicProfileScreen> createState() => _EditBasicProfileScreenState();
}

class _EditBasicProfileScreenState extends State<EditBasicProfileScreen> {
  late final TextEditingController _fullNameController = TextEditingController(
    text: widget.profile.fullName,
  );
  late DateTime? _dob = DateTime.tryParse(widget.profile.dob ?? '');
  late String _gender = widget.profile.gender ?? 'OTHER';
  bool _saving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  String get _dobLabel {
    final value = _dob;
    if (value == null) return 'Chưa cập nhật';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String? get _dobApiValue {
    final value = _dob;
    if (value == null) return null;
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now.subtract(const Duration(days: 1)),
    );
    if (selected != null && mounted) setState(() => _dob = selected);
  }

  Future<void> _save() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ và tên.')));
      return;
    }

    setState(() => _saving = true);
    try {
      await AuthDependencies.instance.userRepository.updateCurrentUser(
        fullName: fullName,
        dob: _dobApiValue,
        gender: _gender,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Chỉnh sửa thông tin cá nhân',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppTextField(
            label: 'HỌ VÀ TÊN',
            hint: 'Nhập họ và tên',
            controller: _fullNameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 18),
          const SectionLabel('NGÀY SINH'),
          const SizedBox(height: 7),
          InkWell(
            onTap: _pickDob,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _dobLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_calendar, color: AppColors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const SectionLabel('GIỚI TÍNH'),
          const SizedBox(height: 7),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'MALE', label: Text('Nam')),
              ButtonSegment(value: 'FEMALE', label: Text('Nữ')),
              ButtonSegment(value: 'OTHER', label: Text('Khác')),
            ],
            selected: {_gender},
            onSelectionChanged: (selection) =>
                setState(() => _gender = selection.first),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Đang lưu...' : 'Lưu thay đổi'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
