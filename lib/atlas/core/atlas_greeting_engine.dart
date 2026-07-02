class AtlasGreetingEngine {
  const AtlasGreetingEngine();

  String getGreeting(DateTime now) {
    final hour = now.hour;

    if (hour < 12) {
      return 'Good Morning';
    }

    if (hour < 17) {
      return 'Good Afternoon';
    }

    return 'Good Evening';
  }

  String getGreetingIcon(DateTime now) {
    final hour = now.hour;

    if (hour < 12) {
      return '🌅';
    }

    if (hour < 17) {
      return '☀️';
    }

    return '🌙';
  }
}