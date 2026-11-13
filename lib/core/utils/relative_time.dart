class RelativeTime {
  static String format(DateTime date, {bool isAmharic = false}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (isAmharic) {
      if (difference.inMinutes < 1) {
        return 'አሁን';
      } else if (difference.inHours < 1) {
        return 'ከ${difference.inMinutes} ደቂቃ በፊት';
      } else if (difference.inHours < 24) {
        if (difference.inHours == 1) return 'ከ1 ሰዓት በፊት';
        return 'ከ${difference.inHours} ሰዓት በፊት';
      } else if (difference.inDays == 1) {
        return 'ትላንት';
      } else if (difference.inDays < 7) {
        return 'ከ${difference.inDays} ቀን በፊት';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'ከ$weeks ሳምንት በፊት';
      } else {
        return 'ከ${difference.inDays} ቀን በፊት';
      }
    } else {
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }
  }
}
