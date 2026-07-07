// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FAQItemImpl _$$FAQItemImplFromJson(Map<String, dynamic> json) =>
    _$FAQItemImpl(
      id: (json['id'] as num).toInt(),
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$$FAQItemImplToJson(_$FAQItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'category': instance.category,
    };
