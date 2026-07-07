// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MembershipFeature _$MembershipFeatureFromJson(Map<String, dynamic> json) {
  return _MembershipFeature.fromJson(json);
}

/// @nodoc
mixin _$MembershipFeature {
  String get text => throw _privateConstructorUsedError;
  bool get included => throw _privateConstructorUsedError;

  /// Serializes this MembershipFeature to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MembershipFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipFeatureCopyWith<MembershipFeature> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipFeatureCopyWith<$Res> {
  factory $MembershipFeatureCopyWith(
          MembershipFeature value, $Res Function(MembershipFeature) then) =
      _$MembershipFeatureCopyWithImpl<$Res, MembershipFeature>;
  @useResult
  $Res call({String text, bool included});
}

/// @nodoc
class _$MembershipFeatureCopyWithImpl<$Res, $Val extends MembershipFeature>
    implements $MembershipFeatureCopyWith<$Res> {
  _$MembershipFeatureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembershipFeature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? included = null,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      included: null == included
          ? _value.included
          : included // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembershipFeatureImplCopyWith<$Res>
    implements $MembershipFeatureCopyWith<$Res> {
  factory _$$MembershipFeatureImplCopyWith(_$MembershipFeatureImpl value,
          $Res Function(_$MembershipFeatureImpl) then) =
      __$$MembershipFeatureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, bool included});
}

/// @nodoc
class __$$MembershipFeatureImplCopyWithImpl<$Res>
    extends _$MembershipFeatureCopyWithImpl<$Res, _$MembershipFeatureImpl>
    implements _$$MembershipFeatureImplCopyWith<$Res> {
  __$$MembershipFeatureImplCopyWithImpl(_$MembershipFeatureImpl _value,
      $Res Function(_$MembershipFeatureImpl) _then)
      : super(_value, _then);

  /// Create a copy of MembershipFeature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? included = null,
  }) {
    return _then(_$MembershipFeatureImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      included: null == included
          ? _value.included
          : included // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MembershipFeatureImpl implements _MembershipFeature {
  const _$MembershipFeatureImpl({required this.text, required this.included});

  factory _$MembershipFeatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembershipFeatureImplFromJson(json);

  @override
  final String text;
  @override
  final bool included;

  @override
  String toString() {
    return 'MembershipFeature(text: $text, included: $included)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipFeatureImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.included, included) ||
                other.included == included));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, included);

  /// Create a copy of MembershipFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipFeatureImplCopyWith<_$MembershipFeatureImpl> get copyWith =>
      __$$MembershipFeatureImplCopyWithImpl<_$MembershipFeatureImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MembershipFeatureImplToJson(
      this,
    );
  }
}

abstract class _MembershipFeature implements MembershipFeature {
  const factory _MembershipFeature(
      {required final String text,
      required final bool included}) = _$MembershipFeatureImpl;

  factory _MembershipFeature.fromJson(Map<String, dynamic> json) =
      _$MembershipFeatureImpl.fromJson;

  @override
  String get text;
  @override
  bool get included;

  /// Create a copy of MembershipFeature
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipFeatureImplCopyWith<_$MembershipFeatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MembershipTier _$MembershipTierFromJson(Map<String, dynamic> json) {
  return _MembershipTier.fromJson(json);
}

/// @nodoc
mixin _$MembershipTier {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get tagline => throw _privateConstructorUsedError;
  double get pricePerMonth => throw _privateConstructorUsedError;
  double? get pricePerYear => throw _privateConstructorUsedError;
  List<MembershipFeature> get features => throw _privateConstructorUsedError;
  bool get highlighted => throw _privateConstructorUsedError;
  String? get badge => throw _privateConstructorUsedError;
  String get ctaLabel => throw _privateConstructorUsedError;
  String? get accentColor => throw _privateConstructorUsedError;

  /// Serializes this MembershipTier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MembershipTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipTierCopyWith<MembershipTier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipTierCopyWith<$Res> {
  factory $MembershipTierCopyWith(
          MembershipTier value, $Res Function(MembershipTier) then) =
      _$MembershipTierCopyWithImpl<$Res, MembershipTier>;
  @useResult
  $Res call(
      {int id,
      String name,
      String tagline,
      double pricePerMonth,
      double? pricePerYear,
      List<MembershipFeature> features,
      bool highlighted,
      String? badge,
      String ctaLabel,
      String? accentColor});
}

/// @nodoc
class _$MembershipTierCopyWithImpl<$Res, $Val extends MembershipTier>
    implements $MembershipTierCopyWith<$Res> {
  _$MembershipTierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembershipTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tagline = null,
    Object? pricePerMonth = null,
    Object? pricePerYear = freezed,
    Object? features = null,
    Object? highlighted = null,
    Object? badge = freezed,
    Object? ctaLabel = null,
    Object? accentColor = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tagline: null == tagline
          ? _value.tagline
          : tagline // ignore: cast_nullable_to_non_nullable
              as String,
      pricePerMonth: null == pricePerMonth
          ? _value.pricePerMonth
          : pricePerMonth // ignore: cast_nullable_to_non_nullable
              as double,
      pricePerYear: freezed == pricePerYear
          ? _value.pricePerYear
          : pricePerYear // ignore: cast_nullable_to_non_nullable
              as double?,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as List<MembershipFeature>,
      highlighted: null == highlighted
          ? _value.highlighted
          : highlighted // ignore: cast_nullable_to_non_nullable
              as bool,
      badge: freezed == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as String?,
      ctaLabel: null == ctaLabel
          ? _value.ctaLabel
          : ctaLabel // ignore: cast_nullable_to_non_nullable
              as String,
      accentColor: freezed == accentColor
          ? _value.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembershipTierImplCopyWith<$Res>
    implements $MembershipTierCopyWith<$Res> {
  factory _$$MembershipTierImplCopyWith(_$MembershipTierImpl value,
          $Res Function(_$MembershipTierImpl) then) =
      __$$MembershipTierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String tagline,
      double pricePerMonth,
      double? pricePerYear,
      List<MembershipFeature> features,
      bool highlighted,
      String? badge,
      String ctaLabel,
      String? accentColor});
}

/// @nodoc
class __$$MembershipTierImplCopyWithImpl<$Res>
    extends _$MembershipTierCopyWithImpl<$Res, _$MembershipTierImpl>
    implements _$$MembershipTierImplCopyWith<$Res> {
  __$$MembershipTierImplCopyWithImpl(
      _$MembershipTierImpl _value, $Res Function(_$MembershipTierImpl) _then)
      : super(_value, _then);

  /// Create a copy of MembershipTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tagline = null,
    Object? pricePerMonth = null,
    Object? pricePerYear = freezed,
    Object? features = null,
    Object? highlighted = null,
    Object? badge = freezed,
    Object? ctaLabel = null,
    Object? accentColor = freezed,
  }) {
    return _then(_$MembershipTierImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tagline: null == tagline
          ? _value.tagline
          : tagline // ignore: cast_nullable_to_non_nullable
              as String,
      pricePerMonth: null == pricePerMonth
          ? _value.pricePerMonth
          : pricePerMonth // ignore: cast_nullable_to_non_nullable
              as double,
      pricePerYear: freezed == pricePerYear
          ? _value.pricePerYear
          : pricePerYear // ignore: cast_nullable_to_non_nullable
              as double?,
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as List<MembershipFeature>,
      highlighted: null == highlighted
          ? _value.highlighted
          : highlighted // ignore: cast_nullable_to_non_nullable
              as bool,
      badge: freezed == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as String?,
      ctaLabel: null == ctaLabel
          ? _value.ctaLabel
          : ctaLabel // ignore: cast_nullable_to_non_nullable
              as String,
      accentColor: freezed == accentColor
          ? _value.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MembershipTierImpl implements _MembershipTier {
  const _$MembershipTierImpl(
      {required this.id,
      required this.name,
      required this.tagline,
      required this.pricePerMonth,
      this.pricePerYear,
      required final List<MembershipFeature> features,
      required this.highlighted,
      this.badge,
      required this.ctaLabel,
      this.accentColor})
      : _features = features;

  factory _$MembershipTierImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembershipTierImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String tagline;
  @override
  final double pricePerMonth;
  @override
  final double? pricePerYear;
  final List<MembershipFeature> _features;
  @override
  List<MembershipFeature> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  final bool highlighted;
  @override
  final String? badge;
  @override
  final String ctaLabel;
  @override
  final String? accentColor;

  @override
  String toString() {
    return 'MembershipTier(id: $id, name: $name, tagline: $tagline, pricePerMonth: $pricePerMonth, pricePerYear: $pricePerYear, features: $features, highlighted: $highlighted, badge: $badge, ctaLabel: $ctaLabel, accentColor: $accentColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipTierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tagline, tagline) || other.tagline == tagline) &&
            (identical(other.pricePerMonth, pricePerMonth) ||
                other.pricePerMonth == pricePerMonth) &&
            (identical(other.pricePerYear, pricePerYear) ||
                other.pricePerYear == pricePerYear) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.highlighted, highlighted) ||
                other.highlighted == highlighted) &&
            (identical(other.badge, badge) || other.badge == badge) &&
            (identical(other.ctaLabel, ctaLabel) ||
                other.ctaLabel == ctaLabel) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      tagline,
      pricePerMonth,
      pricePerYear,
      const DeepCollectionEquality().hash(_features),
      highlighted,
      badge,
      ctaLabel,
      accentColor);

  /// Create a copy of MembershipTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipTierImplCopyWith<_$MembershipTierImpl> get copyWith =>
      __$$MembershipTierImplCopyWithImpl<_$MembershipTierImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MembershipTierImplToJson(
      this,
    );
  }
}

abstract class _MembershipTier implements MembershipTier {
  const factory _MembershipTier(
      {required final int id,
      required final String name,
      required final String tagline,
      required final double pricePerMonth,
      final double? pricePerYear,
      required final List<MembershipFeature> features,
      required final bool highlighted,
      final String? badge,
      required final String ctaLabel,
      final String? accentColor}) = _$MembershipTierImpl;

  factory _MembershipTier.fromJson(Map<String, dynamic> json) =
      _$MembershipTierImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get tagline;
  @override
  double get pricePerMonth;
  @override
  double? get pricePerYear;
  @override
  List<MembershipFeature> get features;
  @override
  bool get highlighted;
  @override
  String? get badge;
  @override
  String get ctaLabel;
  @override
  String? get accentColor;

  /// Create a copy of MembershipTier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipTierImplCopyWith<_$MembershipTierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
