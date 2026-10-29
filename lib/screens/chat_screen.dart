import 'package:flutter/material.dart';
import '../providers/app_state_provider.dart';
import '../models/chat_message.dart';
import '../core/app_theme.dart';
import '../core/time_helper.dart';
import '../widgets/attachment_sheet.dart';
import '../widgets/emoji_gif_sheet.dart';
import 'active_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final AppStateProvider provider;

  const ChatScreen({super.key, required this.provider});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final has = _textController.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() {
          _hasText = has;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    widget.provider.sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _sendVoiceNote() {
    widget.provider.sendVoiceMessage(durationSeconds: 18);
    _scrollToBottom();
  }

  void _startCall({required bool isVideo}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveCallScreen(
          bestieName: widget.provider.bestieName,
          bestieAvatar: '🦊',
          isVideo: isVideo,
          onCallEnded: (durationSeconds) {
            widget.provider.logCompletedCall(
              isVideo: isVideo,
              durationSeconds: durationSeconds,
            );
          },
        ),
      ),
    );
  }

  void _openAttachmentSheet() {
    AttachmentSheet.show(
      context,
      bestieName: widget.provider.bestieName,
      onSendPhoto: ({required imageUrl, caption}) {
        widget.provider.sendPhotoMessage(imageUrl: imageUrl, caption: caption);
        _scrollToBottom();
      },
      onSendVideo: ({required videoUrl, required thumbnailUrl, required durationSeconds, caption}) {
        widget.provider.sendVideoMessage(
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
          durationSeconds: durationSeconds,
          caption: caption,
        );
        _scrollToBottom();
      },
      onSendFile: ({required fileUrl, required fileName, required fileSizeBytes, caption}) {
        widget.provider.sendFileMessage(
          fileUrl: fileUrl,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes,
          caption: caption,
        );
        _scrollToBottom();
      },
    );
  }

  void _openEmojiGifSheet() {
    EmojiGifSheet.show(
      context,
      onEmojiSelected: (emoji) {
        final text = _textController.text;
        final selection = _textController.selection;
        final newText = selection.start >= 0
            ? text.replaceRange(selection.start, selection.end, emoji)
            : text + emoji;
        _textController.text = newText;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: (selection.start >= 0 ? selection.start : text.length) + emoji.length),
        );
      },
      onGifSelected: (gifUrl) {
        widget.provider.sendGifMessage(gifUrl: gifUrl);
        _scrollToBottom();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.provider.messages;
    final bestieName = widget.provider.bestieName;
    final isSleeping = TimeHelper.isBestieAsleep(widget.provider.bestieUtcOffset);
    final bestieClock = TimeHelper.formatBestieClock(widget.provider.bestieUtcOffset);
    final statusText = isSleeping ? 'Sleeping, $bestieClock' : 'Active, $bestieClock';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.avatarPurple,
              child: Text(
                bestieName.isNotEmpty ? bestieName[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bestieName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                ),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF818CF8),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: AppTheme.textWhite, size: 22),
            tooltip: 'Audio Call',
            onPressed: () => _startCall(isVideo: false),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppTheme.textWhite, size: 24),
            tooltip: 'Video Call',
            onPressed: () => _startCall(isVideo: true),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Message stream list with "Today" header matching img33.jpg
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF131A29),
                              border: Border.all(color: const Color(0xFF222F49)),
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF818CF8), size: 26),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Say hi to $bestieName 👋',
                            style: const TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Your private messages and calls are synced in real-time.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                      final message = messages[index - 1];
                      return _buildMessageItem(message);
                    },
                  ),
          ),

          // Bottom Input Bar matching img33.jpg
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isMe = message.isFromMe;

    // Call Event pill matching img33.jpg
    if (message.type == MessageType.callEvent) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardDarkSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Text(
                message.text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Voice Note Bubble matching img33.jpg
    if (message.type == MessageType.voice) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardDarkSecondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppTheme.accentBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Waveform representation
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(16, (i) {
                    final heights = [6, 12, 18, 10, 16, 22, 14, 8, 16, 20, 12, 18, 10, 14, 8, 4];
                    return Container(
                      width: 2.5,
                      height: heights[i % heights.length].toDouble(),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '0:18',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // File / Document bubble matching img33.jpg (trip-plan.pdf with red pdf icon)
    if (message.type == MessageType.file) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardDarkSecondary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'trip-plan.pdf',
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.fileSizeBytes != null
                          ? '${(message.fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB'
                          : '2.4 MB',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Photo / Multi-media message matching img33.jpg
    if (message.type == MessageType.photo && message.text.isEmpty) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkSecondary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppTheme.textMuted,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkSecondary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_outlined,
                      color: AppTheme.textMuted,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Animated GIF Message
    if (message.type == MessageType.gif && message.mediaUrl != null) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.70,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardDarkSecondary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              message.mediaUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: AppTheme.cardDark,
                child: const Center(
                  child: Icon(Icons.movie_outlined, color: AppTheme.textMuted),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Standard Text Bubble
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.accentBlue : AppTheme.cardDarkSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 15,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerColor,
            width: 0.6,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Circular + attachment button matching img33.jpg
            InkWell(
              onTap: _openAttachmentSheet,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.cardDarkSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppTheme.accentBlue,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Message text input container matching img33.jpg + Emoji/GIF button
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.only(left: 16, right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardDarkSecondary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Message ${widget.provider.bestieName}',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    InkWell(
                      onTap: _openEmojiGifSheet,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          color: AppTheme.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Circular Sky Blue button: Mic when empty, Send when typed (matching img33.jpg)
            InkWell(
              onTap: _hasText ? _sendMessage : _sendVoiceNote,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.accentBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasText ? Icons.arrow_upward_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
