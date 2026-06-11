class MenuCategory {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.items = const [],
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      items: (json['items'] as List?)
              ?.map((i) => MenuItem.fromJson(i))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'sort_order': sortOrder,
    'is_active': isActive,
  };
}

class MenuItem {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int sortOrder;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.sortOrder = 0,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      categoryId: json['menu_category_id'] is int
          ? json['menu_category_id']
          : int.tryParse('${json['menu_category_id']}') ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : double.parse('${json['price'] ?? 0}'),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'menu_category_id': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'image_url': imageUrl,
    'is_available': isAvailable,
    'sort_order': sortOrder,
  };
}
