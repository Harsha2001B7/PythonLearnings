// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faq.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FAQItem _$FAQItemFromJson(Map<String, dynamic> json) {
  return _FAQItem.fromJson(json);
}

/// @nodoc
mixin _$FAQItem {
  int get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;

  /// Serializes this FAQItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FAQItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FAQItemCopyWith<FAQItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FAQItemCopyWith<$Res> {
  factory $FAQItemCopyWith(FAQItem value, $Res Function(FAQItem) then) =
      _$FAQItemCopyWithImpl<$Res, FAQItem>;
  @useResult
  $Res call({int id, String question, String answer, String category});
}

/// @nodoc
class _$FAQItemCopyWithImpl<$Res, $Val extends FAQItem>
    implements $FAQItemCopyWith<$Res> {
  _$FAQItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FAQItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? answer = null,
    Object? category = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FAQItemImplCopyWith<$Res> implements $FAQItemCopyWith<$Res> {
  factory _$$FAQItemImplCopyWith(
          _$FAQItemImpl value, $Res Function(_$FAQItemImpl) then) =
      __$$FAQItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String question, String answer, String category});
}

/// @nodoc
class __$$FAQItemImplCopyWithImpl<$Res>
    extends _$FAQItemCopyWithImpl<$Res, _$FAQItemImpl>
    implements _$$FAQItemImplCopyWith<$Res> {
  __$$FAQItemImplCopyWithImpl(
      _$FAQItemImpl _value, $Res Function(_$FAQItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of FAQItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? answer = null,
    Object? category = null,
  }) {
    return _then(_$FAQItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FAQItemImpl implements _FAQItem {
  const _$FAQItemImpl(
      {required this.id,
      required this.question,
      required this.answer,
      required this.category});

  factory _$FAQItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FAQItemImplFromJson(json);

  @override
  final int id;
  @override
  final String question;
  @override
  final String answer;
  @override
  final String category;

  @override
  String toString() {
    return 'FAQItem(id: $id, question: $question, answer: $answer, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FAQItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, question, answer, category);

  /// Create a copy of FAQItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FAQItemImplCopyWith<_$FAQItemImpl> get copyWith =>
      __$$FAQItemImplCopyWithImpl<_$FAQItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FAQItemImplToJson(
      this,
    );
  }
}

abstract class _FAQItem implements FAQItem {
  const factory _FAQItem(
      {required final int id,
      required final String question,
      required final String answer,
      required final String category}) = _$FAQItemImpl;

  factory _FAQItem.fromJson(Map<String, dynamic> json) = _$FAQItemImpl.fromJson;

  @override
  int get id;
  @override
  String get question;
  @override
  String get answer;
  @override
  String get category;

  /// Create a copy of FAQItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FAQItemImplCopyWith<_$FAQItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
