class ResourceModel {
  final int id;
  final String name;
  final String type;
  final String description;
  final String image;
  final int stock;
  final int price;

  ResourceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.image,
    required this.stock,
    required this.price,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? 'No description provided',
      image: json['image_url'] ?? '',
      stock: json['stock'] is int
          ? json['stock']
          : int.parse(json['stock'].toString()),
      price: json['price'] is int
          ? json['price']
          : double.parse(json['price'].toString()).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'image_url': image,
      'stock': stock,
      'price': price,
    };
  }
}
