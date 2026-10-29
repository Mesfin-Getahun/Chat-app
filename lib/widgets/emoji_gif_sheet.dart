import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class EmojiGifSheet extends StatefulWidget {
  final Function(String emoji) onEmojiSelected;
  final Function(String gifUrl) onGifSelected;

  const EmojiGifSheet({
    super.key,
    required this.onEmojiSelected,
    required this.onGifSelected,
  });

  static void show(
    BuildContext context, {
    required Function(String emoji) onEmojiSelected,
    required Function(String gifUrl) onGifSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EmojiGifSheet(
        onEmojiSelected: onEmojiSelected,
        onGifSelected: onGifSelected,
      ),
    );
  }

  @override
  State<EmojiGifSheet> createState() => _EmojiGifSheetState();
}

class _EmojiGifSheetState extends State<EmojiGifSheet> {
  int _selectedTab = 0; // 0 = Emojis, 1 = GIFs
  String _selectedCategory = 'All';

  static const List<String> _emojis = [
    '❤️', '🥰', '✨', '🔥', '🤗', '😂', '🥺', '🥳',
    '💖', '🌸', '☕', '🍕', '🚀', '🎉', '💯', '👑',
    '🧸', '💃', '✈️', '🌟', '🥂', '💬', '🫶', '🫂',
    '😎', '😜', '😍', '🤩', '😴', '🌈', '💐', '🍿',
    '🧁', '🍦', '🎈', '🎁', '💌', '💎', '🦄', '🐾',
    '☀️', '🌙', '⭐', '🍀', '🍓', '🍰', '🧁', '🍩',
    '👏', '🙌', '✌️', '🤞', '🤙', '👋', '👀', '💡',
  ];

  static const List<Map<String, String>> _gifs = [
    {
      'title': 'Big Warm Hug',
      'category': 'Hugs',
      'url': 'https://media.giphy.com/media/l2QDM9Jnim1YV57YA/giphy.gif',
    },
    {
      'title': 'Bestie Hug',
      'category': 'Hugs',
      'url': 'https://media.giphy.com/media/3M4NpbLCTxBqU/giphy.gif',
    },
    {
      'title': 'Dancing Celebration',
      'category': 'Celebration',
      'url': 'https://media.giphy.com/media/blSTtZehjAZ8I/giphy.gif',
    },
    {
      'title': 'Laughing Out Loud',
      'category': 'Laugh',
      'url': 'https://media.giphy.com/media/10JhviFuU2gWD6/giphy.gif',
    },
    {
      'title': 'Sending Love',
      'category': 'Love',
      'url': 'https://media.giphy.com/media/PQKlfexeEpnTq/giphy.gif',
    },
    {
      'title': 'High Five',
      'category': 'Celebration',
      'url': 'https://media.giphy.com/media/l0ErFafpUCQTQFMSk/giphy.gif',
    },
    {
      'title': 'Miss You Tons',
      'category': 'Miss You',
      'url': 'https://media.giphy.com/media/9d3LQ6TdV2Flo8ODTU/giphy.gif',
    },
    {
      'title': 'Party Time',
      'category': 'Celebration',
      'url': 'https://media.giphy.com/media/artj92V8o75VPL7AeQ/giphy.gif',
    },
  ];

  List<Map<String, String>> get _filteredGifs {
    if (_selectedCategory == 'All') return _gifs;
    return _gifs.where((g) => g['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 440,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tab Selector (Emojis vs GIFs)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Emojis 😊', 0),
                  ),
                  Expanded(
                    child: _buildTabButton('GIFs 🎬', 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab Content
            Expanded(
              child: _selectedTab == 0 ? _buildEmojisTab() : _buildGifsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmojisTab() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _emojis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final emoji = _emojis[index];
        return InkWell(
          onTap: () {
            widget.onEmojiSelected(emoji);
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGifsTab() {
    final categories = ['All', 'Hugs', 'Laugh', 'Love', 'Miss You', 'Celebration'];
    final list = _filteredGifs;

    return Column(
      children: [
        // Category Pills
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isCatSelected = _selectedCategory == cat;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCatSelected ? AppTheme.cardDarkSecondary : AppTheme.cardDark,
                    border: Border.all(
                      color: isCatSelected ? AppTheme.accentBlue : Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isCatSelected ? AppTheme.textWhite : AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: isCatSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // GIF Grid
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final gif = list[index];
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  widget.onGifSelected(gif['url']!);
                },
                borderRadius: BorderRadius.circular(14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        gif['url']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppTheme.cardDarkSecondary,
                          child: const Center(
                            child: Icon(Icons.movie_outlined, color: AppTheme.textMuted),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            gif['title'] ?? 'GIF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
