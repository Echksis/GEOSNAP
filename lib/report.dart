class Report {
  final int id;
  final String title;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String image;
  final String imageType;
  final String createdAt;

  Report({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.imageType,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      image: json['image'] ?? '',
      imageType: json['image_type'] ?? 'image/jpeg',
      createdAt: json['created_at'] ?? '',
    );
  }
}