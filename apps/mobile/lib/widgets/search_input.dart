import 'package:flutter/material.dart';

import '../core/constants/strings.dart';
import '../core/theme/app_colors.dart';

/// Arama kutusu.
class SearchInput extends StatelessWidget {
  const SearchInput({super.key, required this.onChanged, this.hint = S.search});

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        isDense: true,
      ),
    );
  }
}
