// ============================================
// FILE: lib/fatures/library/data/models/personal_document_model.dart
// ============================================
//
// `PersonalDocument` — a PDF the user uploaded to "My Documents"
// (`/reader/my-library/documents`). Reading progress, highlights and
// bookmarks are synced back through `/reader/my-library/documents/sync`
// (see `ReaderCubit`/`BookSyncItem` in the reader feature, reused as-is —
// the sync payload shape is identical to a library book's).

class PersonalDocumentFile {
  final String id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String fileSizeFormatted;
  final String url;

  const PersonalDocumentFile({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.fileSizeFormatted,
    required this.url,
  });

  static const empty = PersonalDocumentFile(
    id: '',
    fileName: '',
    fileType: '',
    fileSize: 0,
    fileSizeFormatted: '',
    url: '',
  );

  factory PersonalDocumentFile.fromJson(Map<String, dynamic> json) {
    return PersonalDocumentFile(
      id: json['id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileType: json['file_type']?.toString() ?? '',
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      fileSizeFormatted: json['file_size_formatted']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class PersonalDocumentModel {
  final String id;
  final String title;
  final int currentPage;
  final int totalPages;
  final num progressPercentage;
  final DateTime? lastReadAt;
  final PersonalDocumentFile file;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PersonalDocumentModel({
    required this.id,
    required this.title,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
    required this.lastReadAt,
    required this.file,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 0..1, for the same progress bar used by the library's book cards.
  double get progress => (progressPercentage.clamp(0, 100)) / 100;

  factory PersonalDocumentModel.fromJson(Map<String, dynamic> json) {
    final progress = json['reading_progress'];
    final progressMap = progress is Map<String, dynamic> ? progress : const {};
    final rawFile = json['file'];

    return PersonalDocumentModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      currentPage: (progressMap['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (progressMap['total_pages'] as num?)?.toInt() ?? 0,
      progressPercentage:
          (progressMap['progress_percentage'] as num?) ?? 0,
      lastReadAt: DateTime.tryParse(
        progressMap['last_read_at']?.toString() ?? '',
      ),
      file: rawFile is Map<String, dynamic>
          ? PersonalDocumentFile.fromJson(rawFile)
          : PersonalDocumentFile.empty,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  static List<PersonalDocumentModel> listFrom(dynamic data) {
    final map = data is Map<String, dynamic> ? data : const <String, dynamic>{};
    final rawItems = map['items'];
    if (rawItems is! List) return const [];
    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(PersonalDocumentModel.fromJson)
        .toList();
  }
}
