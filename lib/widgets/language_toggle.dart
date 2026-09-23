import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageToggle extends StatelessWidget {
  final bool isDark;

  const LanguageToggle({super.key, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isMarathi = langProvider.isMarathi;

    return InkWell(
      onTap: () => langProvider.toggleLanguage(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate,
              size: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 5),
            Text(
              isMarathi ? 'मराठी' : 'English',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
