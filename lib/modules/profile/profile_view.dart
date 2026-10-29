import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:viet_tour/core/utils/responsive.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Tài khoản',
        style: TextStyle(
          fontSize: Responsive.font(18),
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.loadProfile,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Tải lại hồ sơ',
        ),
      ],
    ),
    body: Obx(
      () => ListView(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
        children: [
          if (controller.loading.value && controller.profile.value == null)
            const LinearProgressIndicator(),
          if (controller.errorMessage.value.isNotEmpty &&
              controller.profile.value == null)
            Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: Responsive.font(10),
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(Responsive.radius(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    controller.initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.font(14),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.fullName.isEmpty
                            ? 'Khách hàng'
                            : controller.fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.font(14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        controller.email,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: Responsive.font(10),
                        ),
                      ),
                      if (controller.phone.isNotEmpty) ...[
                        SizedBox(height: 0.4.h),
                        Text(
                          controller.phone,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: Responsive.font(9.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editProfile(context),
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: 'Sửa hồ sơ',
                ),
              ],
            ),
          ),
          SizedBox(height: 2.5.h),
          _group('TÀI KHOẢN CỦA TÔI', [
            _item(
              Icons.person_outline_rounded,
              'Thông tin cá nhân',
              () => _editProfile(context),
            ),
            _item(
              Icons.lock_outline_rounded,
              'Đổi mật khẩu',
              () => _changePassword(context),
            ),
            _item(
              Icons.language_rounded,
              'Ngôn ngữ',
              () => controller.showFeature('Ngôn ngữ'),
            ),
          ]),
          SizedBox(height: 2.h),
          _group('HỖ TRỢ', [
            _item(
              Icons.support_agent_rounded,
              'Trung tâm trợ giúp',
              () => controller.showFeature(
                'Hỗ trợ VietTour · ${controller.hotline}',
              ),
            ),
            _item(
              Icons.call_outlined,
              'Hotline ${controller.hotline}',
              () => controller.showFeature('Hotline VietTour'),
            ),
          ]),
          SizedBox(height: 2.h),
          _item(
            Icons.logout_rounded,
            'Đăng xuất',
            controller.logout,
            color: AppColors.primary,
          ),
          SizedBox(height: 2.h),
          Center(
            child: Text(
              'VietTour · Phiên bản 1.0.0',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: Responsive.font(9),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _editProfile(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: controller.fullName);
    final email = TextEditingController(text: controller.email);
    final phone = TextEditingController(text: controller.phone);
    final existingDate = DateTime.tryParse(controller.birthDate);
    DateTime? birthDate = existingDate;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thông tin cá nhân'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Họ và tên'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập họ tên'
                        : null,
                  ),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value == null || !GetUtils.isEmail(value.trim())
                        ? 'Vui lòng nhập email hợp lệ'
                        : null,
                  ),
                  TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                    ),
                    validator: (value) =>
                        value == null ||
                            !RegExp(
                              r'^[0-9+().\-\s]{9,20}$',
                            ).hasMatch(value.trim())
                        ? 'Vui lòng nhập số điện thoại hợp lệ'
                        : null,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      birthDate == null
                          ? 'Ngày sinh (không bắt buộc)'
                          : 'Ngày sinh: ${Formatters.date(birthDate!)}',
                    ),
                    trailing: const Icon(Icons.calendar_month_outlined),
                    onTap: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate:
                            birthDate ?? DateTime(DateTime.now().year - 18),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (selected != null) {
                        setState(() => birthDate = selected);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            Obx(
              () => FilledButton(
                onPressed: controller.saving.value
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final saved = await controller.updateProfile(
                          name: name.text,
                          emailAddress: email.text,
                          phoneNumber: phone.text,
                          dateOfBirth: birthDate,
                        );
                        if (saved && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: controller.saving.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    email.dispose();
    phone.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmation = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập mật khẩu hiện tại'
                    : null,
              ),
              TextFormField(
                controller: newPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                validator: (value) => value == null || value.length < 8
                    ? 'Mật khẩu mới cần ít nhất 8 ký tự'
                    : null,
              ),
              TextFormField(
                controller: confirmation,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nhập lại mật khẩu mới',
                ),
                validator: (value) => value != newPassword.text
                    ? 'Mật khẩu xác nhận không khớp'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          Obx(
            () => FilledButton(
              onPressed: controller.saving.value
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      final changed = await controller.changePassword(
                        currentPassword: currentPassword.text,
                        newPassword: newPassword.text,
                      );
                      if (changed && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: controller.saving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Đổi mật khẩu'),
            ),
          ),
        ],
      ),
    );
    currentPassword.dispose();
    newPassword.dispose();
    confirmation.dispose();
  }

  Widget _group(String label, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: Responsive.font(9),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Responsive.radius(14)),
        ),
        child: Column(children: children),
      ),
    ],
  );

  Widget _item(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = AppColors.text,
  }) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: color, size: 5.w),
    title: Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: Responsive.font(11.5),
        fontWeight: FontWeight.w600,
      ),
    ),
    trailing: Icon(
      Icons.chevron_right_rounded,
      size: 5.w,
      color: AppColors.muted,
    ),
    dense: true,
  );
}
