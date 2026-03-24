class Post {
  final String id;
  final String authorName;
  final String authorImageUrl;
  final String timeAgo;
  final String postImageUrl;
  final String caption;
  int likes; // Not final, because users can like/unlike a post!
  final int comments;
  bool isLiked; // Not final, because this changes when a user double-taps

  Post({
    required this.id,
    required this.authorName,
    required this.authorImageUrl,
    required this.timeAgo,
    required this.postImageUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    this.isLiked = false, // Defaults to false
  });
}

// --- DUMMY DATA FOR TESTING ---
// We will use this list to build the Home Page UI before connecting a real database.

List<Post> dummyPosts = [
  Post(
    id: '1',
    authorName: 'Luna The Cat',
    authorImageUrl: 'assets/img/profile_cat1.jpg', // Using your exact folder structure!
    timeAgo: '2 hours ago',
    postImageUrl: 'assets/img/post1.jpg',
    caption: 'Enjoying the afternoon sun! ☀️🐾 #catlife #sunbathing',
    likes: 124,
    comments: 12,
    isLiked: true,
  ),
  Post(
    id: '2',
    authorName: 'Milo',
    authorImageUrl: 'assets/img/profile_cat2.jpg',
    timeAgo: '5 hours ago',
    postImageUrl: 'assets/img/logo.png', // Placeholder until you add post2.jpg
    caption: 'Just woke up from a 5 hour nap. Time for treats! 🐟',
    likes: 89,
    comments: 5,
    isLiked: false,
  ),
];