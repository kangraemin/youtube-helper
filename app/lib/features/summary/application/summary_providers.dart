import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/core/constants/api_constants.dart';
import 'package:youtube_helper/features/summary/domain/repositories/summary_repository.dart';
import 'package:youtube_helper/features/summary/infrastructure/summary_api_service.dart';
import 'package:youtube_helper/features/summary/infrastructure/summary_repository_impl.dart';

final summaryRepositoryProvider = Provider<SummaryRepository>((ref) {
  return SummaryRepositoryImpl();
});

final serverUrlProvider = StateProvider<String>((ref) {
  return ApiConstants.defaultBaseUrl;
});

final summaryApiServiceProvider = Provider<SummaryApiService>((ref) {
  final baseUrl = ref.watch(serverUrlProvider);
  return SummaryApiService(baseUrl: baseUrl);
});
