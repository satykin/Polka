import 'package:flutter/material.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

/// Экран добавления нового косметического средства.
class AddCosmeticScreen extends StatefulWidget {
  final CosmeticRepository repository;

  const AddCosmeticScreen({super.key, required this.repository});

  @override
  State<AddCosmeticScreen> createState() => _AddCosmeticScreenState();
}

class _AddCosmeticScreenState extends State<AddCosmeticScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  CosmeticCategory _selectedCategory = CosmeticCategory.face;
  bool _priceIsApproximate = false;
  DateTime? _purchasedAt;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickPurchasedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchasedAt ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _purchasedAt = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  /// Разрешаем вводить цену и с точкой, и с запятой.
  double? _parsePrice() {
    final text = _priceController.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      final now = DateTime.now();
      final newItem = CosmeticItem(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: _parsePrice(),
        priceIsApproximate: _priceIsApproximate,
        purchasedAt: _purchasedAt,
        createdAt: now,
        updatedAt: now,
      );

      await widget.repository.add(newItem);

      if (mounted) {
        // Возвращаем true на предыдущий экран, чтобы он обновил список
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новое средство')),
      // SafeArea не пускает контент под системную панель телефона.
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название средства',
                    hintText: 'Например, Увлажняющий крем',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите название';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<CosmeticCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: CosmeticCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Цена, ₽ (необязательно)',
                    hintText: 'Например, 599 или 599,90',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim().replaceAll(',', '.');
                    if (text.isEmpty) return null;
                    final parsed = double.tryParse(text);
                    if (parsed == null || parsed < 0) {
                      return 'Введите положительное число';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  title: const Text('Цена примерная'),
                  value: _priceIsApproximate,
                  onChanged: (value) {
                    setState(() {
                      _priceIsApproximate = value;
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _pickPurchasedDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _purchasedAt == null
                              ? 'Указать дату покупки'
                              : 'Куплено: ${_formatDate(_purchasedAt!)}',
                        ),
                      ),
                    ),
                    if (_purchasedAt != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _purchasedAt = null;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Сохранение...' : 'Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
