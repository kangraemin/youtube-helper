# Step 2: Data Models + Services

## Results
- `lib/models/video_summary.dart` - VideoSummary and Section models with toJson/fromJson ✅
  - Includes: videoId, title, thumbnailUrl, transcript, summary, keyPoints, sections, language, createdAt
- `lib/services/api_service.dart` - ApiService calling /transcript, /summarize, /chat endpoints ✅
  - processVideo() combines transcript + summarize into single VideoSummary
- `lib/services/storage_service.dart` - StorageService with SharedPreferences ✅
  - Caches full VideoSummary including thumbnail and title
  - Server URL persistence
