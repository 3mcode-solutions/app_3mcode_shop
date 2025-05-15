import 'package:equatable/equatable.dart';

/// Model class for WooCommerce product image
class WooProductImage extends Equatable {
  final int id;
  final String src;
  final String? name;
  final String? alt;

  const WooProductImage({
    required this.id,
    required this.src,
    this.name,
    this.alt,
  });

  factory WooProductImage.fromJson(Map<String, dynamic> json) {
    return WooProductImage(
      id: json['id'] as int,
      src: json['src'] as String,
      name: json['name'] as String?,
      alt: json['alt'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, src, name, alt];
}

/// Model class for WooCommerce product category
class WooProductCategory extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final String? image;

  const WooProductCategory({
    required this.id,
    required this.name,
    this.slug,
    this.image,
  });

  factory WooProductCategory.fromJson(Map<String, dynamic> json) {
    String? imageUrl;

    // Extract image URL if available
    if (json['image'] != null) {
      final imageData = json['image'] as Map<String, dynamic>;
      imageUrl = imageData['src'] as String?;
    }

    return WooProductCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      image: imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, slug, image];
}

/// Model class for WooCommerce product attribute
class WooProductAttribute extends Equatable {
  final int id;
  final String name;
  final int position;
  final bool visible;
  final bool variation;
  final List<String> options;

  const WooProductAttribute({
    required this.id,
    required this.name,
    required this.position,
    required this.visible,
    required this.variation,
    required this.options,
  });

  factory WooProductAttribute.fromJson(Map<String, dynamic> json) {
    return WooProductAttribute(
      id: json['id'] as int,
      name: json['name'] as String,
      position: json['position'] as int,
      visible: json['visible'] as bool,
      variation: json['variation'] as bool,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, position, visible, variation, options];
}

/// Model class for WooCommerce product
class WooProduct extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final String? permalink;
  final String? dateCreated;
  final String? dateModified;
  final String? type;
  final String? status;
  final bool? featured;
  final String? catalogVisibility;
  final String? description;
  final String? shortDescription;
  final String? sku;
  final String price;
  final String? regularPrice;
  final String? salePrice;
  final String? dateOnSaleFrom;
  final String? dateOnSaleTo;
  final bool? onSale;
  final bool? purchasable;
  final int? totalSales;
  final bool? virtual;
  final bool? downloadable;
  final List<dynamic>? downloads;
  final int? downloadLimit;
  final int? downloadExpiry;
  final String? externalUrl;
  final String? buttonText;
  final String? taxStatus;
  final String? taxClass;
  final bool? manageStock;
  final int? stockQuantity;
  final String? stockStatus;
  final String? backorders;
  final bool? backordersAllowed;
  final bool? backordered;
  final bool? soldIndividually;
  final String? weight;
  final Map<String, dynamic>? dimensions;
  final bool? shippingRequired;
  final bool? shippingTaxable;
  final String? shippingClass;
  final int? shippingClassId;
  final bool? reviewsAllowed;
  final String? averageRating;
  final int? ratingCount;
  final List<int>? relatedIds;
  final List<int>? upsellIds;
  final List<int>? crossSellIds;
  final int? parentId;
  final String? purchaseNote;
  final List<WooProductCategory> categories;
  final List<dynamic>? tags;
  final List<WooProductImage> images;
  final List<WooProductAttribute>? attributes;
  final List<dynamic>? defaultAttributes;
  final List<int>? variations;
  final List<dynamic>? groupedProducts;
  final int? menuOrder;
  final List<dynamic>? metaData;

  const WooProduct({
    required this.id,
    required this.name,
    this.slug,
    this.permalink,
    this.dateCreated,
    this.dateModified,
    this.type,
    this.status,
    this.featured,
    this.catalogVisibility,
    this.description,
    this.shortDescription,
    this.sku,
    required this.price,
    this.regularPrice,
    this.salePrice,
    this.dateOnSaleFrom,
    this.dateOnSaleTo,
    this.onSale,
    this.purchasable,
    this.totalSales,
    this.virtual,
    this.downloadable,
    this.downloads,
    this.downloadLimit,
    this.downloadExpiry,
    this.externalUrl,
    this.buttonText,
    this.taxStatus,
    this.taxClass,
    this.manageStock,
    this.stockQuantity,
    this.stockStatus,
    this.backorders,
    this.backordersAllowed,
    this.backordered,
    this.soldIndividually,
    this.weight,
    this.dimensions,
    this.shippingRequired,
    this.shippingTaxable,
    this.shippingClass,
    this.shippingClassId,
    this.reviewsAllowed,
    this.averageRating,
    this.ratingCount,
    this.relatedIds,
    this.upsellIds,
    this.crossSellIds,
    this.parentId,
    this.purchaseNote,
    required this.categories,
    this.tags,
    required this.images,
    this.attributes,
    this.defaultAttributes,
    this.variations,
    this.groupedProducts,
    this.menuOrder,
    this.metaData,
  });

  factory WooProduct.fromJson(Map<String, dynamic> json) {
    return WooProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      permalink: json['permalink'] as String?,
      dateCreated: json['date_created'] as String?,
      dateModified: json['date_modified'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      featured: json['featured'] as bool?,
      catalogVisibility: json['catalog_visibility'] as String?,
      description: json['description'] as String?,
      shortDescription: json['short_description'] as String?,
      sku: json['sku'] as String?,
      price: json['price'] as String? ?? '0',
      regularPrice: json['regular_price'] as String?,
      salePrice: json['sale_price'] as String?,
      dateOnSaleFrom: json['date_on_sale_from'] as String?,
      dateOnSaleTo: json['date_on_sale_to'] as String?,
      onSale: json['on_sale'] as bool?,
      purchasable: json['purchasable'] as bool?,
      totalSales: json['total_sales'] as int?,
      virtual: json['virtual'] as bool?,
      downloadable: json['downloadable'] as bool?,
      downloads: json['downloads'] as List<dynamic>?,
      downloadLimit: json['download_limit'] as int?,
      downloadExpiry: json['download_expiry'] as int?,
      externalUrl: json['external_url'] as String?,
      buttonText: json['button_text'] as String?,
      taxStatus: json['tax_status'] as String?,
      taxClass: json['tax_class'] as String?,
      manageStock: json['manage_stock'] as bool?,
      stockQuantity: json['stock_quantity'] as int?,
      stockStatus: json['stock_status'] as String?,
      backorders: json['backorders'] as String?,
      backordersAllowed: json['backorders_allowed'] as bool?,
      backordered: json['backordered'] as bool?,
      soldIndividually: json['sold_individually'] as bool?,
      weight: json['weight'] as String?,
      dimensions: json['dimensions'] as Map<String, dynamic>?,
      shippingRequired: json['shipping_required'] as bool?,
      shippingTaxable: json['shipping_taxable'] as bool?,
      shippingClass: json['shipping_class'] as String?,
      shippingClassId: json['shipping_class_id'] as int?,
      reviewsAllowed: json['reviews_allowed'] as bool?,
      averageRating: json['average_rating'] as String?,
      ratingCount: json['rating_count'] as int?,
      relatedIds:
          (json['related_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      upsellIds:
          (json['upsell_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      crossSellIds:
          (json['cross_sell_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      parentId: json['parent_id'] as int?,
      purchaseNote: json['purchase_note'] as String?,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map(
                (e) => WooProductCategory.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      tags: json['tags'] as List<dynamic>?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => WooProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attributes:
          (json['attributes'] as List<dynamic>?)
              ?.map(
                (e) => WooProductAttribute.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      defaultAttributes: json['default_attributes'] as List<dynamic>?,
      variations:
          (json['variations'] as List<dynamic>?)?.map((e) => e as int).toList(),
      groupedProducts: json['grouped_products'] as List<dynamic>?,
      menuOrder: json['menu_order'] as int?,
      metaData: json['meta_data'] as List<dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
