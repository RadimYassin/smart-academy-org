class AiChatResponse {
  final String answer;
  final List<SourceDocument> sources;
  final String modelUsed;
  final int numSources;

  AiChatResponse({
    required this.answer,
    required this.sources,
    required this.modelUsed,
    required this.numSources,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      answer: json['answer'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((source) => SourceDocument.fromJson(source as Map<String, dynamic>))
              .toList() ?? [],
      modelUsed: json['model_used'] as String? ?? 'unknown',
      numSources: json['num_sources'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'sources': sources.map((s) => s.toJson()).toList(),
      'model_used': modelUsed,
      'num_sources': numSources,
    };
  }
}

class SourceDocument {
  final String content;
  final Map<String, dynamic> metadata;
  final dynamic page;
  final String sourceFile;

  SourceDocument({
    required this.content,
    required this.metadata,
    required this.page,
    required this.sourceFile,
  });

  factory SourceDocument.fromJson(Map<String, dynamic> json) {
    return SourceDocument(
      content: json['content'] as String? ?? '',
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      page: json['page'],
      sourceFile: json['source_file'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'metadata': metadata,
      'page': page,
      'source_file': sourceFile,
    };
  }
}

