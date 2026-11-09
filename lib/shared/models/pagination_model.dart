import '../../core/utils/json_utils.dart';

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: Json.intOf(json['page'], fallback: 1),
      limit: Json.intOf(json['limit'], fallback: 20),
      total: Json.intOf(json['total']),
      totalPages: Json.intOf(json['total_pages']),
      hasNext: Json.boolOf(json['has_next']),
      hasPrevious: Json.boolOf(json['has_previous']),
    );
  }
}
