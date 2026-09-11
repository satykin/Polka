import 'package:hive/hive.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

/// Адаптер, который объясняет Hive, как сохранять CosmeticItem.
/// Написан вручную, без генерации кода.
class CosmeticItemAdapter extends TypeAdapter<CosmeticItem> {
  @override
  final int typeId = 0;

  @override
  CosmeticItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return CosmeticItem(
      id: fields[0] as String,
      name: fields[1] as String,
      category: CosmeticCategory.values[fields[2] as int],
      price: fields[3] as double?,
      priceIsApproximate: fields[4] as bool,
      purchasedAt: fields[5] as DateTime?,
      openedAt: fields[6] as DateTime?,
      paoMonths: fields[7] as int?,
      lastUsedAt: fields[8] as DateTime?,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CosmeticItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category.index)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.priceIsApproximate)
      ..writeByte(5)
      ..write(obj.purchasedAt)
      ..writeByte(6)
      ..write(obj.openedAt)
      ..writeByte(7)
      ..write(obj.paoMonths)
      ..writeByte(8)
      ..write(obj.lastUsedAt)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }
}
