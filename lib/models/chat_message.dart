enum MessageType {
  text,
  poke,
  voice,
  prompt,
  photo,
  video,
  file,
  callEvent,
  gif,
}

class ChatMessage {
  final String id;
  final String senderId; // 'me' or 'bestie'
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;
  final List<String> reactions;
  final int? durationSeconds; // for voice notes and videos
  final String? mediaUrl; // Cloudinary secure CDN URL or local media
  final String? fileName; // for documents/files
  final int? fileSizeBytes; // for documents/files
  final String? thumbnailUrl; // preview thumbnail

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = true,
    this.reactions = const [],
    this.durationSeconds,
    this.mediaUrl,
    this.fileName,
    this.fileSizeBytes,
    this.thumbnailUrl,
  });

  bool get isFromMe => senderId == 'me';

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? timestamp,
    MessageType? type,
    bool? isRead,
    List<String>? reactions,
    int? durationSeconds,
    String? mediaUrl,
    String? fileName,
    int? fileSizeBytes,
    String? thumbnailUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      reactions: reactions ?? this.reactions,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'reactions': reactions,
      'durationSeconds': durationSeconds,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      isRead: json['isRead'] as bool? ?? true,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      durationSeconds: json['durationSeconds'] as int?,
      mediaUrl: json['mediaUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}
