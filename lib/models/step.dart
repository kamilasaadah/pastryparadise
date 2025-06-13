class Step {
  final String description;
  final int stepNumber;

  Step({required this.description, required this.stepNumber});

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      description: json['description']?.toString() ?? '',
      stepNumber: int.tryParse(json['number']?.toString() ?? '0') ?? 0, // Sesuaikan dengan 'number' dari PocketBase
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'stepNumber': stepNumber,
    };
  }
}