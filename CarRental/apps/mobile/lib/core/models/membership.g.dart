// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MembershipFeatureImpl _$$MembershipFeatureImplFromJson(
        Map<String, dynamic> json) =>
    _$MembershipFeatureImpl(
      text: json['text'] as String,
      included: json['included'] as bool,
    );

Map<String, dynamic> _$$MembershipFeatureImplToJson(
        _$MembershipFeatureImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'included': instance.included,
    };

_$MembershipTierImpl _$$MembershipTierImplFromJson(Map<String, dynamic> json) =>
    _$MembershipTierImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      pricePerMonth: (json['pricePerMonth'] as num).toDouble(),
      pricePerYear: (json['pricePerYear'] as num?)?.toDouble(),
      features: (json['features'] as List<dynamic>)
          .map((e) => MembershipFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
      highlighted: json['highlighted'] as bool,
      badge: json['badge'] as String?,
      ctaLabel: json['ctaLabel'] as String,
      accentColor: json['accentColor'] as String?,
    );

Map<String, dynamic> _$$MembershipTierImplToJson(
        _$MembershipTierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tagline': instance.tagline,
      'pricePerMonth': instance.pricePerMonth,
      'pricePerYear': instance.pricePerYear,
      'features': instance.features,
      'highlighted': instance.highlighted,
      'badge': instance.badge,
      'ctaLabel': instance.ctaLabel,
      'accentColor': instance.accentColor,
    };
