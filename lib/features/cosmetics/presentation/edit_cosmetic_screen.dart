import 'package:flutter/material.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

/// Экран редактирования косметического средства.
class EditCosmeticScreen extends StatefulWidget {
  final CosmeticRepository repository;
  final CosmeticItem item;

  const EditCosmeticScreen({
    super.key,
    required this.repository,
    required this.item,
  });

  @override
  State<EditCosmeticScreen> createState() => _EditCosmeticScreenState();
}

class _EditCosmeticScreenState extends State<EditCosmeticScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _paoController;
  late CosmeticCategory _selectedCategory;
  late DateTime? _openedAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _paoController = TextEditingController(
      text: widget.item.paoMonths?.toString() ?? '',
    );
    _selectedCategory = widget.item.category;
    _openedAt = widget.item.openedAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _paoController.dispose();
    super.dispose();
  }

  Future<void> _pickOpenedDate() async {
    final now = DateTime.now();
    final initial = _openedAt ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _openedAt = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      final now = DateTime.now();
      final paoText = _paoController.text.trim();

      // Создаём новую версию средства (вместо copyWith),
      // чтобы иметь возможность очищать поля (openedAt, paoMonths)
      final updatedItem = CosmeticItem(
        id: widget.item.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: widget.item.price,
        priceIsApproximate: widget.item.priceIsApproximate,
        purchasedAt: widget.item.purchasedAt,
        openedAt: _openedAt,
        paoMonths: paoText.isEmpty ? null : int.tryParse(paoText),
        lastUsedAt: widget.item.lastUsedAt,
        createdAt: widget.item.createdAt,
        updatedAt: now,
      );

      await widget.repository.update(updatedItem);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название средства',
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
              SwitchListTile(
                title: const Text('Средство открыто'),
                subtitle: Text(
                  _openedAt == null
                      ? 'Ещё не открыто'
                      : 'Открыто: ${_formatDate(_openedAt!)}',
                ),
                value: _openedAt != null,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _openedAt = DateTime.now();
                    } else {
                      _openedAt = null;
                    }
                  });
                },
              ),
              if (_openedAt != null)
                TextButton.icon(
                  onPressed: _pickOpenedDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Изменить дату: ${_formatDate(_openedAt!)}'),
                ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _paoController,
                decoration: const InputDecoration(
                  labelText: 'Срок после вскрытия (PAO), месяцев',
                  hintText: 'Например, 12',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return null;
                  }
                  final parsed = int.tryParse(text);
                  if (parsed == null || parsed <= 0) {
                    return 'Введите число больше нуля';
                  }
                  return null;
                },
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
    );
  }
}
