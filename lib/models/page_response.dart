import 'package:json_annotation/json_annotation.dart';

part 'page_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PageResponse<T> {
  final List<T> content;
  final PageInfo page;

  const PageResponse({
    required this.content,
    required this.page,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    // Handle both nested and flat structures from backend
    // Spring Boot returns flat structure with pagination fields at root level
    final PageInfo pageInfo;
    
    if (json.containsKey('page') && json['page'] is Map) {
      // Nested structure (old format)
      pageInfo = PageInfo.fromJson(json['page'] as Map<String, dynamic>);
    } else {
      // Flat structure (Spring Boot Page format)
      pageInfo = PageInfo(
        size: json['size'] as int? ?? json['pageable']?['pageSize'] as int? ?? 10,
        number: json['number'] as int? ?? json['pageable']?['pageNumber'] as int? ?? 0,
        totalElements: json['totalElements'] as int? ?? 0,
        totalPages: json['totalPages'] as int? ?? 0,
      );
    }
    
    return PageResponse<T>(
      content: (json['content'] as List<dynamic>)
          .map((e) => fromJsonT(e))
          .toList(),
      page: pageInfo,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageResponseToJson(this, toJsonT);
}

@JsonSerializable()
class PageInfo {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  const PageInfo({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => _$PageInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PageInfoToJson(this);
}
