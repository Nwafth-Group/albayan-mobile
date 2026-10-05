// ============================================
// FILE: lib/fatures/settings/screens/profile_screen.dart
// ============================================

import 'dart:io';

import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/data/models/country_model.dart';
import 'package:albayan/fatures/auth/data/models/user_model.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/shared_pref_helper.dart';
import 'widgets/settings_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRemoteDataSource(ApiService())),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _countryName = TextEditingController();

  UserModel? _user;
  File? _pickedImage;
  List<CountryModel> _countries = const [];
  CountryModel? _country;

  // Reading hours reminder.
  int _hour = 10;
  int _minutes = 0;
  bool _isAm = true;

  @override
  void initState() {
    super.initState();
    _fill(SharedPrefHelper.getUser());
    // Profile first (fresh data), then the country list for the picker.
    context.read<AuthCubit>().getProfile();
  }

  void _fill(UserModel? user) {
    if (user == null) return;
    _user = user;
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    _phone.text = user.mobileNumber ?? '';
    _email.text = user.email ?? '';
    _country = user.country ?? _country;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _countryName.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null && mounted) {
      setState(() => _pickedImage = File(file.path));
    }
  }

  Future<void> _pickCountry() async {
    if (_countries.isEmpty) return;
    final isAr = context.locale.languageCode == 'ar';
    final picked = await showModalBottomSheet<CountryModel>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _countries.length,
          itemBuilder: (_, i) {
            final c = _countries[i];
            return ListTile(
              leading: _Flag(url: c.image),
              title: Text(isAr ? c.nameAr : c.nameEn),
              trailing: c.id == _country?.id
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(c),
            );
          },
        ),
      ),
    );
    if (picked != null) setState(() => _country = picked);
  }

  void _save() {
    // TODO(api): no profile-update endpoint yet — send first/last name,
    // mobile, email, country, the picked image and the reading-hours
    // reminder here once it exists, then refresh the cached user.
    Helpers.showError(AppStrings.featureComingSoon.tr());
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    _countryName.text = _country == null
        ? ''
        : (isAr ? _country!.nameAr : _country!.nameEn);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() => _fill(state.user));
          context.read<AuthCubit>().fetchCountries();
        } else if (state is ProfileError) {
          context.read<AuthCubit>().fetchCountries();
        } else if (state is CountriesLoaded) {
          setState(() {
            _countries = state.countries;
            // Match the user's country to the loaded list (for its flag).
            final id = _country?.id;
            if (id != null) {
              for (final c in state.countries) {
                if (c.id == id) _country = c;
              }
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: SettingsAppBar(title: AppStrings.profileTitle.tr()),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: _Avatar(
                file: _pickedImage,
                url: _user?.profileImage,
                onEdit: _pickImage,
              ),
            ),
            const SizedBox(height: 20),
            SettingsField(
              label: AppStrings.labelFirstName.tr(),
              hint: AppStrings.hintFirstName.tr(),
              controller: _firstName,
            ),
            const SizedBox(height: 14),
            SettingsField(
              label: AppStrings.labelLastName.tr(),
              hint: AppStrings.hintLastName.tr(),
              controller: _lastName,
            ),
            const SizedBox(height: 14),
            SettingsField(
              label: AppStrings.phoneNumber.tr(),
              hint: AppStrings.hintMobilePhone.tr(),
              controller: _phone,
              keyboardType: TextInputType.phone,
              prefix: Padding(
                padding: const EdgeInsetsDirectional.only(start: 10, end: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Flag(url: _country?.image, size: 18, square: true),
                    const SizedBox(width: 6),
                    Text(
                      _phoneCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SettingsField(
              label: AppStrings.labelEmail.tr(),
              hint: AppStrings.hintEmail.tr(),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            SettingsField(
              label: AppStrings.labelCountry.tr(),
              hint: AppStrings.chooseCountry.tr(),
              readOnly: true,
              onTap: _pickCountry,
              controller: _countryName,
              suffix: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.readingHours.tr(),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _ReadingHoursCard(
              hour: _hour,
              minutes: _minutes,
              isAm: _isAm,
              onHour: (v) => setState(() => _hour = v),
              onMinutes: (v) => setState(() => _minutes = v),
              onAmPm: (v) => setState(() => _isAm = v),
            ),
          ],
        ),
        bottomNavigationBar: SettingsButtonPair(
          secondaryText: AppStrings.cancel.tr(),
          primaryText: AppStrings.saveChange.tr(),
          onSecondary: () => AppNavigator.pop(),
          onPrimary: _save,
        ),
      ),
    );
  }

  String get _phoneCode {
    final code = _country?.phoneCode ?? '966';
    return code.startsWith('+') ? code : '+$code';
  }
}

class _Avatar extends StatelessWidget {
  final File? file;
  final String? url;
  final VoidCallback onEdit;

  const _Avatar({this.file, this.url, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(
      Icons.person,
      size: 56,
      color: AppColors.textLight,
    );

    ImageProvider? image;
    if (file != null) {
      image = FileImage(file!);
    } else if (url != null && url!.isNotEmpty) {
      image = NetworkImage(url!);
    }

    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: image,
            onBackgroundImageError: image == null ? null : (_, __) {},
            child: image == null ? placeholder : null,
          ),
          PositionedDirectional(
            end: 2,
            bottom: 4,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCamera01,
                    color: AppColors.white,
                    size: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  final String? url;
  final double size;
  final bool square;

  const _Flag({this.url, this.size = 28, this.square = false});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.surfaceVariant,
    );
    final child = (url == null || url!.isEmpty)
        ? placeholder
        : Image.network(
            url!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder,
          );
    return square
        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: child)
        : ClipOval(child: child);
  }
}

/// "10 AM" + AM/PM toggle, then Hour (1–12) and Minutes (0–60) sliders.
class _ReadingHoursCard extends StatelessWidget {
  final int hour;
  final int minutes;
  final bool isAm;
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinutes;
  final ValueChanged<bool> onAmPm;

  const _ReadingHoursCard({
    required this.hour,
    required this.minutes,
    required this.isAm,
    required this.onHour,
    required this.onMinutes,
    required this.onAmPm,
  });

  @override
  Widget build(BuildContext context) {
    final am = AppStrings.timeAm.tr();
    final pm = AppStrings.timePm.tr();
    final time = minutes == 0
        ? '$hour ${isAm ? am : pm}'
        : '$hour:${minutes.toString().padLeft(2, '0')} ${isAm ? am : pm}';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: settingsBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.accentPale,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _AmPmChip(
                      label: am,
                      selected: isAm,
                      onTap: () => onAmPm(true),
                    ),
                    _AmPmChip(
                      label: pm,
                      selected: !isAm,
                      onTap: () => onAmPm(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: settingsBorder),
          _SliderRow(
            label: AppStrings.readingHour.tr(),
            value: hour,
            min: 1,
            max: 12,
            ticks: const ['01', '06', '12'],
            onChanged: onHour,
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: AppStrings.readingMinutes.tr(),
            value: minutes,
            min: 0,
            max: 60,
            ticks: const ['00', '30', '60'],
            onChanged: onMinutes,
          ),
        ],
      ),
    );
  }
}

class _AmPmChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AmPmChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final List<String> ticks;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.ticks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tickStyle = TextStyle(fontSize: 9, color: AppColors.textLight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: settingsBorder,
            thumbColor: AppColors.primary,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final t in ticks) Text(t, style: tickStyle)],
          ),
        ),
      ],
    );
  }
}
