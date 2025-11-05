import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book_model.dart';
import '../utils/app_theme.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Book Image
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              clipBehavior: Clip.hardEdge,
              child: book.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.accentColor,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 40,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 40,
                        color: AppTheme.textSecondary,
                      ),
                    ),
            ),
            SizedBox(width: 16),
            
            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'by ${book.author}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getConditionColor(book.condition),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.condition.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(book.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.status.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isOwner && !isOffer)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Owner: ${book.ownerName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentColor, Color(0xFFED8936)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: onSwap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Swap',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (isOwner && book.status == SwapStatus.Available) ...[
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined, color: AppTheme.accentColor),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(height: 4),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: AppTheme.errorColor),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                    ),
                  ),
                ],
                if (isOwner && book.status == SwapStatus.Pending) ...[
                  ElevatedButton(
                    onPressed: onAcceptSwap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: onRejectSwap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
        return AppTheme.successColor;
      case SwapStatus.Pending:
        return AppTheme.warningColor;
      case SwapStatus.Accepted:
        return Colors.blue;
      case SwapStatus.Rejected:
        return AppTheme.errorColor;
    }
  }

  Color _getConditionColor(BookCondition condition) {
    switch (condition) {
      case BookCondition.New:
        return AppTheme.successColor;
      case BookCondition.LikeNew:
        return Colors.blue;
      case BookCondition.Good:
        return AppTheme.warningColor;
      case BookCondition.Used:
        return Colors.grey;
    }
  }
}