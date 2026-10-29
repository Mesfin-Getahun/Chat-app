class AppConstants {
  // App Branding (Customizable by user in Settings)
  static const String defaultAppName = 'BestieSync';
  static const String defaultAppSubtitle = 'Private 1-on-1 Best Friend Haven';
  static const String appVersion = '1.0.0';

  // Default User & Bestie Profiles
  static const String defaultMyName = 'Alex';
  static const String defaultBestieName = 'Sam';
  static const String defaultBestieCity = 'New York';
  static const int defaultBestieUtcOffset = -5; // UTC-5
  static const String defaultBestieAvatar = '🦊';
  static const String defaultMyAvatar = '🐼';

  // Inactivity Reminder Defaults
  static const int defaultReminderThresholdHours = 48; // 2 days
  static const int streakResetThresholdHours = 72; // 3 days

  // Quick Poke / Hug Presets
  static const List<Map<String, String>> pokePresets = [
    {'emoji': '🤗', 'label': 'Big Warm Hug', 'text': 'sent you a big warm hug! 🤗'},
    {'emoji': '💌', 'label': 'Miss You!', 'text': 'is missing you right now! 💌'},
    {'emoji': '☕', 'label': 'Coffee Catch-up', 'text': 'wants a virtual coffee chat! ☕'},
    {'emoji': '⚡', 'label': 'Friendly Poke', 'text': 'poked you! Hey bestie, wake up! ⚡'},
    {'emoji': '🍕', 'label': 'Pizza Craving', 'text': 'wishes you were here for pizza! 🍕'},
    {'emoji': '🎧', 'label': 'Song for You', 'text': 'is listening to music and thinking of you! 🎧'},
  ];

  // Daily Catch-up Icebreaker Prompts
  static const List<String> catchUpPrompts = [
    'What was the funniest thing that happened to you today?',
    'If we could teleport anywhere right now for 1 hour, where are we going?',
    'What song are you listening to on repeat this week?',
    'Send a 10-second voice note of what you\'re doing right now!',
    'What\'s one little thing that made you smile today?',
    'What delicious food did you eat today that you wish I could taste?',
    'Tell me the latest gossip or drama in your life!',
    'Rate your day from 1-10 and tell me why!',
  ];
}
