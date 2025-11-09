import 'package:cloud_firestore/cloud_firestore.dart';

enum OfferStatus { pending, accepted, rejected }

class SwapOfferModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookImageUrl;
  final String ownerId;
  final String ownerName;
  final String requesterId;
  final String requesterName;
  final OfferStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  SwapOfferModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookImageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.requesterId,
    required this.requesterName,
    this.status = OfferStatus.pending,
    required this.createdAt,
    this.respondedAt,
  });

  factory SwapOfferModel.fromMap(Map<String, dynamic> map) {
    return SwapOfferModel(
      id: map['id'] ?? '',
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      bookAuthor: map['bookAuthor'] ?? '',
      bookImageUrl: map['bookImageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      status: OfferStatus.values[map['status'] ?? 0],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null ? (map['respondedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookImageUrl': bookImageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'status': status.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  SwapOfferModel copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookImageUrl,
    String? ownerId,
    String? ownerName,
    String? requesterId,
    String? requesterName,
    OfferStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return SwapOfferModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}