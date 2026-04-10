class ResourcePost {
  final int    id;
  final String title;
  final String body;

  ResourcePost({required this.id, required this.title, required this.body});

  factory ResourcePost.fromJson(Map<String, dynamic> json) => ResourcePost(
    id:    json['id'],
    title: json['title'],
    body:  json['body'],
  );
}