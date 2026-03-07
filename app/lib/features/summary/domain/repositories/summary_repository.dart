import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';

abstract class SummaryRepository {
  Future<List<SummaryEntity>> getAll();
  Future<SummaryEntity?> getById(String id);
  Future<void> add(SummaryEntity summary);
  Future<void> delete(String id);
  Future<void> deleteAll();
}
