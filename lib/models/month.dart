import 'model.dart';

class Month extends Model {
  bool enabled;

  Month({
    int id = 0,
    required this.enabled,
  }) : super(id: id);

  @override
  Map<String, dynamic> toUpdateMap() {
    return {
      "id": id.toString(),
      "enabled": enabled.toString(),
    };
  }

  factory Month.fromMap(Map<String, dynamic> data) {
    return Month(
      id: data["id"],
      enabled: data["enabled"],
    );
  }
}
