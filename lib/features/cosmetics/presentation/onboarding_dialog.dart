import 'package:flutter/material.dart';

/// Одноразовое обучающее окно с основными жестами приложения.
class OnboardingDialog extends StatelessWidget {
  const OnboardingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Как пользоваться полкой'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HintRow(
            icon: Icons.swipe_left,
            color: Colors.red,
            text: 'Свайп влево — удалить средство',
          ),
          SizedBox(height: 12),
          _HintRow(
            icon: Icons.swipe_right,
            color: Colors.green,
            text: 'Свайп вправо — отметить использование',
          ),
          SizedBox(height: 12),
          _HintRow(
            icon: Icons.touch_app,
            color: Colors.blue,
            text: 'Тап по строке — редактировать средство',
          ),
          SizedBox(height: 12),
          _HintRow(
            icon: Icons.tab,
            color: Colors.grey,
            text: 'Внизу — вкладки «Полка» и «Обзор»',
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Понятно!'),
        ),
      ],
    );
  }
}

/// Одна строка подсказки с иконкой.
class _HintRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _HintRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
