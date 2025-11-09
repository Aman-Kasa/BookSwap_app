enum BookCondition { New, LikeNew, Good, Used }

enum SwapStatus { Available, Pending, Accepted, Rejected }

class BookModel {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String imageUrl;
  final String ownerId;
  final String ownerName;
  final SwapStatus status;
  final DateTime createdAt;
  final String? swapRequesterId;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    this.status = SwapStatus.Available,
    required this.createdAt,
    this.swapRequesterId,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookCondition.values[map['condition'] ?? 0],
      imageUrl: map['imageBase64'] ?? map['imageUrl'] ?? '', // Support both fields
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      status: SwapStatus.values[map['status'] ?? 0],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      swapRequesterId: map['swapRequesterId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'condition': condition.index,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'swapRequesterId': swapRequesterId,
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    BookCondition? condition,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
    SwapStatus? status,
    DateTime? createdAt,
    String? swapRequesterId,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      swapRequesterId: swapRequesterId ?? this.swapRequesterId,
    );
  }
}