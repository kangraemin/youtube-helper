import 'package:hive_flutter/hive_flutter.dart';

import 'package:youtube_helper/core/constants/hive_constants.dart';
import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';
import 'package:youtube_helper/features/summary/domain/repositories/summary_repository.dart';
import 'package:youtube_helper/features/summary/infrastructure/summary_hive_model.dart';

class SummaryRepositoryImpl implements SummaryRepository {
  Box<SummaryHiveModel> get _box =>
      Hive.box<SummaryHiveModel>(HiveConstants.summaryBox);

  @override
  Future<List<SummaryEntity>> getAll() async {
    final models = _box.values.toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<SummaryEntity?> getById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> add(SummaryEntity summary) async {
    final model = SummaryHiveModel.fromEntity(summary);
    await _box.put(summary.id, model);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    await _box.clear();
  }
}
