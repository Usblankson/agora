import 'package:hive/hive.dart';

part 'channel.g.dart';

@HiveType(typeId: 0)
class Channel extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final DateTime? createdAt;
  @HiveField(3)
  final DateTime? updatedAt;

  Channel({
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });
}
