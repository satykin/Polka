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
  CosmeticCategory _selectedCategory = CosmeticCategory.face;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      final now = DateTime.now();
      final newItem = CosmeticItem(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
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
      appBar: AppBar(
        title: const Text('Новое средство'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
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
              const Spacer(),
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
    );
  }
}