import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

@freezed
class MembershipFeature with _$MembershipFeature {
  const factory MembershipFeature({
    required String text,
    required bool included,
  }) = _MembershipFeature;

  factory MembershipFeature.fromJson(Map<String, dynamic> json) =>
      _$MembershipFeatureFromJson(json);
}

@freezed
class MembershipTier with _$MembershipTier {
  const factory MembershipTier({
    required int id,
    required String name,
    required String tagline,
    required double pricePerMonth,
    double? pricePerYear,
    required List<MembershipFeature> features,
    required bool highlighted,
    String? badge,
    required String ctaLabel,
    String? accentColor,
  }) = _MembershipTier;

  factory MembershipTier.fromJson(Map<String, dynamic> json) =>
      _$MembershipTierFromJson(json);
}
