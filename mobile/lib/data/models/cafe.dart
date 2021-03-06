import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/cafe.dart';
import '../../domain/entities/tag.dart';
import 'location.dart';
import 'photo.dart';
import 'tag_reputation.dart';

//ignore_for_file: unnecessary_lambdas
class CafeModel extends Equatable {
  final String placeId;
  final String name;
  final LocationModel location;
  final String iconUrl;
  final double rating;
  final int priceLevel;
  final bool openNow;
  final String address;
  final List<TagReputationModel> tags;
  final PhotoModel photo;
  CafeModel({
    @required this.placeId,
    @required this.name,
    @required this.location,
    @required this.iconUrl,
    @required this.rating,
    @required this.priceLevel,
    @required this.openNow,
    @required this.address,
    @required this.tags,
    this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'geometry': {'location': location.toJson()},
      'icon': iconUrl,
      'rating': rating,
      'price_level': priceLevel,
      'opening_hours': {'open_now': openNow},
      'formatted_address': address,
      'tags': List<dynamic>.from(tags.map((x) => x.toJson())),
      'photos': [photo.toJson()],
    };
  }

  static CafeModel fromJson(Map<String, dynamic> map) {
    if (map == null) return null;

    return CafeModel(
      placeId: map['place_id'],
      name: map['name'],
      location: LocationModel.fromJson(map['geometry']['location']),
      iconUrl: map['icon'],
      rating: map['rating']?.toDouble(),
      priceLevel: map['price_level']?.toInt(),
      openNow: map['opening_hours'] != null
          ? map['opening_hours']['open_now']
          : null,
      address: map['formatted_address'] != null
          ? map['formatted_address']
          : map['vicinity'],
      tags: List<TagReputationModel>.from(
          map['tags']?.map((x) => TagReputationModel.fromJson(x))),
      photo:
          PhotoModel.fromJson(map['photos'] != null ? map['photos'][0] : null),
    );
  }

  CafeModel copyWith({
    String placeId,
    String name,
    LocationModel location,
    String iconUrl,
    double rating,
    int priceLevel,
    bool openNow,
    String address,
    List<TagReputationModel> tags,
    PhotoModel photo,
  }) {
    return CafeModel(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      location: location ?? this.location,
      iconUrl: iconUrl ?? this.iconUrl,
      rating: rating ?? this.rating,
      priceLevel: priceLevel ?? this.priceLevel,
      openNow: openNow ?? this.openNow,
      address: address ?? this.address,
      tags: tags ?? this.tags,
      photo: photo ?? this.photo,
    );
  }

  @override
  String toString() {
    return '''CafeModel placeId: $placeId, name: $name, location: $location, 
    iconUrl: $iconUrl, rating: $rating, priceLevel: $priceLevel, openNow: $openNow, address: $address, tags: $tags, photo: $photo''';
  }

  @override
  List<Object> get props => [
        placeId,
        name,
        location,
        iconUrl,
        rating,
        priceLevel,
        openNow,
        address,
        tags,
        photo,
      ];

  Cafe toEntity(
          {@required bool isFavorite,
          @required List<Tag> allTags,
          @required String photoUrl}) =>
      Cafe(
        placeId: placeId,
        name: name,
        location: location.toEntity(),
        iconUrl: iconUrl,
        rating: rating,
        priceLevel: priceLevel,
        openNow: openNow,
        address: address,
        tags: tags
            .where((t) => t.score >= TagReputationModel.minimalScore)
            .map((x) => x.toEntity(
                allTags.firstWhere((t) => t.id == x.id, orElse: () => null)))
            .toList(),
        photos: [photo?.toEntity(photoUrl)],
        isFavorite: isFavorite,
      );
}
