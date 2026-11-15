/// Represents bulk pricing brackets for wholesale orders.
class TierPrice {
  final int minQty;
  final int? maxQty;
  final double pricePerUnit;
  final int discountPercentage;
  final String label;

  const TierPrice({
    required this.minQty,
    this.maxQty,
    required this.pricePerUnit,
    required this.discountPercentage,
    required this.label,
  });

  factory TierPrice.fromJson(Map<String, dynamic> json) {
    return TierPrice(
      minQty: json['minQty'] as int? ?? 1,
      maxQty: json['maxQty'] as int?,
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: json['discountPercentage'] as int? ?? 0,
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'minQty': minQty,
    'maxQty': maxQty,
    'pricePerUnit': pricePerUnit,
    'discountPercentage': discountPercentage,
    'label': label,
  };
}

/// Wholesale business metadata appended to regular catalog items.
class WholesaleMeta {
  final int productId;
  final int moq; // Minimum Order Quantity
  final List<TierPrice> tierPrices;
  final String supplierLabel;
  final bool isDemoData;

  const WholesaleMeta({
    required this.productId,
    required this.moq,
    required this.tierPrices,
    required this.supplierLabel,
    this.isDemoData = true,
  });

  /// Dynamically computes synthetic MOQ and tier pricing brackets from base retail price.
  factory WholesaleMeta.generate({
    required int productId,
    required double basePrice,
  }) {
    // Determine Minimum Order Quantity
    final int moq = basePrice > 500 ? 5 : (basePrice > 100 ? 10 : 25);

    final double tier1Price = double.parse((basePrice * 0.95).toStringAsFixed(2));
    final double tier2Price = double.parse((basePrice * 0.88).toStringAsFixed(2));
    final double tier3Price = double.parse((basePrice * 0.80).toStringAsFixed(2));

    final tiers = [
      TierPrice(
        minQty: moq,
        maxQty: moq * 4 - 1,
        pricePerUnit: tier1Price,
        discountPercentage: 5,
        label: '$moq–${moq * 4 - 1} units',
      ),
      TierPrice(
        minQty: moq * 4,
        maxQty: moq * 10 - 1,
        pricePerUnit: tier2Price,
        discountPercentage: 12,
        label: '${moq * 4}–${moq * 10 - 1} units',
      ),
      TierPrice(
        minQty: moq * 10,
        maxQty: null,
        pricePerUnit: tier3Price,
        discountPercentage: 20,
        label: '${moq * 10}+ units',
      ),
    ];

    final suppliers = [
      'Apex Bulk Enterprises',
      'Bharat Wholesale Supplies',
      'Prime Source Traders',
      'National Trade Connect',
      'Surat Mercantile Co.',
    ];
    final supplier = suppliers[productId % suppliers.length];

    return WholesaleMeta(
      productId: productId,
      moq: moq,
      tierPrices: tiers,
      supplierLabel: supplier,
      isDemoData: true,
    );
  }

  /// Calculates the effective unit price for a given requested quantity.
  double getUnitPriceForQuantity(int qty) {
    if (tierPrices.isEmpty) return 0.0;
    for (int i = tierPrices.length - 1; i >= 0; i--) {
      if (qty >= tierPrices[i].minQty) {
        return tierPrices[i].pricePerUnit;
      }
    }
    return tierPrices.first.pricePerUnit;
  }

  factory WholesaleMeta.fromJson(Map<String, dynamic> json) {
    return WholesaleMeta(
      productId: json['productId'] as int? ?? 0,
      moq: json['moq'] as int? ?? 10,
      tierPrices: (json['tierPrices'] as List<dynamic>?)
              ?.map((e) => TierPrice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      supplierLabel: json['supplierLabel'] as String? ?? 'Verified Supplier',
      isDemoData: json['isDemoData'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'moq': moq,
    'tierPrices': tierPrices.map((e) => e.toJson()).toList(),
    'supplierLabel': supplierLabel,
    'isDemoData': isDemoData,
  };
}

/// Core Product model representing items fetched from DummyJSON.
class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;
  final WholesaleMeta wholesaleMeta;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
    required this.wholesaleMeta,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int? ?? 0;
    final double price = (json['price'] as num?)?.toDouble() ?? 0.0;

    WholesaleMeta meta;
    if (json['wholesaleMeta'] != null && json['wholesaleMeta'] is Map<String, dynamic>) {
      meta = WholesaleMeta.fromJson(json['wholesaleMeta'] as Map<String, dynamic>);
    } else {
      meta = WholesaleMeta.generate(productId: id, basePrice: price);
    }

    return Product(
      id: id,
      title: json['title'] as String? ?? 'Untitled Product',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      price: price,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      brand: json['brand'] as String? ?? 'Generic',
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      wholesaleMeta: meta,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
    'brand': brand,
    'thumbnail': thumbnail,
    'images': images,
    'wholesaleMeta': wholesaleMeta.toJson(),
  };
}
