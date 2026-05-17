import 'package:albayan/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final double border;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final TextDirection? textDirection;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.border = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.textDirection,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: AppColors.accentLight,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      textDirection: textDirection,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText!=null?"Ex: $hintText":null,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? null : '',
        filled: true,
        fillColor: Colors.white,
        // ✅ NORMAL
        enabledBorder: _border(Colors.grey, width: 0.5),

        // ✅ FOCUSED
        focusedBorder: _border(Colors.grey, width: border),

        // ✅ ERROR (keeps same radius)
        errorBorder: _border(Colors.red, width: border),

        // ✅ FOCUSED + ERROR (important)
        focusedErrorBorder: _border(Colors.red, width: border),
        labelStyle: const TextStyle(color: Colors.black,fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey.shade400,fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}