import 'package:freezed_annotation/freezed_annotation.dart';

part 'faq.freezed.dart';
part 'faq.g.dart';

@freezed
class FAQItem with _$FAQItem {
  const factory FAQItem({
    required int id,
    required String question,
    required String answer,
    required String category,
  }) = _FAQItem;

  factory FAQItem.fromJson(Map<String, dynamic> json) =>
      _$FAQItemFromJson(json);
}
