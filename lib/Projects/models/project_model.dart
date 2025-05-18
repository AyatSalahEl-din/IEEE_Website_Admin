class Project {
  final String id;
  final String name;
  final String description;
  final String? imageUrl; // Make imageUrl nullable
  final DateTime createdAt;
  final Map<String, dynamic> additionalDetails;

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl, // Nullable imageUrl
    DateTime? createdAt,
    Map<String, dynamic>? additionalDetails,
  }) : createdAt = createdAt ?? DateTime.now(),
       additionalDetails = additionalDetails ?? {};

  factory Project.fromFirestore(Map<String, dynamic> data, String id) {
    return Project(
      id: id,
      name: data['name'] ?? 'No Name',
      description: data['description'] ?? 'No Description',
      imageUrl: data['imageUrl'], // Handle nullable imageUrl
      createdAt:
          data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
      additionalDetails: data['additionalDetails'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl, // Include only if not null
      'createdAt': createdAt.toIso8601String(),
      'additionalDetails': additionalDetails,
    };
  }
}
