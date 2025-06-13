class Ingredient {
  final String name;
  final double quantity;
  final String unit;

  Ingredient({required this.name, required this.quantity, required this.unit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name']?.toString() ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}