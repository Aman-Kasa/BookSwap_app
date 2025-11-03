import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final bool isOwner;
  final bool isOffer;
  final VoidCallback? onSwap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAcceptSwap;
  final VoidCallback? onRejectSwap;

  BookCard({
    required this.book,
    this.isOwner = false,
    this.isOffer = false,
    this.onSwap,
    this.onEdit,
    this.onDelete,
    this.onAcceptSwap,
    this.onRejectSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Book Image
            Container(
              width: 80,
              height: 100,
              child: book.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.book, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.book, size: 40),
                    ),
            ),
            SizedBox(width: 12),
            
            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'by ${book.author}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Condition: ${book.condition.name}',
                    style: TextStyle(fontSize: 12),
                  ),
                  if (!isOwner && !isOffer)
                    Text(
                      'Owner: ${book.ownerName}',
                      style: TextStyle(fontSize: 12),
                    ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(book.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      book.status.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Column(
              children: [
                if (!isOwner && !isOffer && book.status == SwapStatus.Available)
                  ElevatedButton(
                    onPressed: onSwap,
                    child: Text('Swap'),
                  ),
                if (isOwner && book.status == SwapStatus.Available) ...[
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
                if (isOwner && book.status == SwapStatus.Pending) ...[
                  ElevatedButton(
                    onPressed: onAcceptSwap,
                    child: Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: onRejectSwap,
                    child: Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.Available:
        return Colors.green;
      case SwapStatus.Pending:
        return Colors.orange;
      case SwapStatus.Accepted:
        return Colors.blue;
      case SwapStatus.Rejected:
        return Colors.red;
    }
  }
}