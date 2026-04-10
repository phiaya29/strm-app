class Task {
  final int?    id;
  final String title;
  final String description;
  final bool   isSynced;
  final String createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isSynced = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id':          id,
    'title':       title,
    'description': description,
    'isSynced':    isSynced ? 1 : 0,
    'createdAt':   createdAt,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id:          map['id'],
    title:       map['title'],
    description: map['description'],
    isSynced:    map['isSynced'] == 1,
    createdAt:   map['createdAt'],
  );
}