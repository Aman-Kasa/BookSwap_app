import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book_model.dart';
import '../utils/app_theme.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  BookDetailScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'book_${book.id}',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: book.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.book, size: 100),
                        ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${book.author}',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoChip('Condition', book.condition.name, _getConditionColor(book.condition)),
                      SizedBox(width: 12),
                      _buildInfoChip('Status', book.status.name, _getStatusColor(book.status)),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection('Owner Information', [
                    _buildInfoRow(Icons.person, 'Owner', book.ownerName),
                    _buildInfoRow(Icons.calendar_today, 'Listed', _formatDate(book.createdAt)),
                  ]),
                  SizedBox(height: 24),
                  _buildInfoSection('Book Details', [
                    _buildInfoRow(Icons.book, 'Title', book.title),
                    _buildInfoRow(Icons.person_outline, 'Author', book.author),
                    _buildInfoRow(Icons.star, 'Condition', book.condition.name),
                  ]),
                  SizedBox(height: 40),
                  if (book.status == SwapStatus.Available)\n                    SizedBox(\n                      width: double.infinity,\n                      child: Container(\n                        decoration: BoxDecoration(\n                          gradient: LinearGradient(\n                            colors: [AppTheme.accentColor, Color(0xFFED8936)],\n                          ),\n                          borderRadius: BorderRadius.circular(12),\n                        ),\n                        child: ElevatedButton(\n                          onPressed: () => _showSwapDialog(context),\n                          style: ElevatedButton.styleFrom(\n                            backgroundColor: Colors.transparent,\n                            shadowColor: Colors.transparent,\n                            padding: EdgeInsets.symmetric(vertical: 16),\n                          ),\n                          child: Text(\n                            'Request Swap',\n                            style: TextStyle(\n                              fontSize: 18,\n                              fontWeight: FontWeight.bold,\n                              color: Colors.white,\n                            ),\n                          ),\n                        ),\n                      ),\n                    ),\n                ],\n              ),\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildInfoChip(String label, String value, Color color) {\n    return Container(\n      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),\n      decoration: BoxDecoration(\n        color: color.withOpacity(0.1),\n        borderRadius: BorderRadius.circular(20),\n        border: Border.all(color: color.withOpacity(0.3)),\n      ),\n      child: Row(\n        mainAxisSize: MainAxisSize.min,\n        children: [\n          Container(\n            width: 8,\n            height: 8,\n            decoration: BoxDecoration(\n              color: color,\n              shape: BoxShape.circle,\n            ),\n          ),\n          SizedBox(width: 8),\n          Text(\n            '$label: $value',\n            style: TextStyle(\n              fontWeight: FontWeight.w600,\n              color: color,\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildInfoSection(String title, List<Widget> children) {\n    return Column(\n      crossAxisAlignment: CrossAxisAlignment.start,\n      children: [\n        Text(\n          title,\n          style: TextStyle(\n            fontSize: 20,\n            fontWeight: FontWeight.bold,\n            color: AppTheme.textPrimary,\n          ),\n        ),\n        SizedBox(height: 12),\n        Container(\n          padding: EdgeInsets.all(16),\n          decoration: BoxDecoration(\n            color: Colors.grey[50],\n            borderRadius: BorderRadius.circular(12),\n            border: Border.all(color: Colors.grey[200]!),\n          ),\n          child: Column(children: children),\n        ),\n      ],\n    );\n  }\n\n  Widget _buildInfoRow(IconData icon, String label, String value) {\n    return Padding(\n      padding: EdgeInsets.symmetric(vertical: 8),\n      child: Row(\n        children: [\n          Icon(icon, color: AppTheme.textSecondary, size: 20),\n          SizedBox(width: 12),\n          Text(\n            '$label:',\n            style: TextStyle(\n              fontWeight: FontWeight.w600,\n              color: AppTheme.textSecondary,\n            ),\n          ),\n          SizedBox(width: 8),\n          Expanded(\n            child: Text(\n              value,\n              style: TextStyle(\n                color: AppTheme.textPrimary,\n              ),\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  void _showSwapDialog(BuildContext context) {\n    showDialog(\n      context: context,\n      builder: (context) => AlertDialog(\n        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),\n        title: Row(\n          children: [\n            Icon(Icons.swap_horiz, color: AppTheme.accentColor),\n            SizedBox(width: 8),\n            Text('Swap Request'),\n          ],\n        ),\n        content: Text('Send swap request for \"${book.title}\" to ${book.ownerName}?'),\n        actions: [\n          TextButton(\n            onPressed: () => Navigator.pop(context),\n            child: Text('Cancel'),\n          ),\n          ElevatedButton(\n            onPressed: () {\n              Navigator.pop(context);\n              ScaffoldMessenger.of(context).showSnackBar(\n                SnackBar(\n                  content: Text('Swap request sent to ${book.ownerName}!'),\n                  backgroundColor: AppTheme.successColor,\n                ),\n              );\n            },\n            child: Text('Send Request'),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Color _getConditionColor(BookCondition condition) {\n    switch (condition) {\n      case BookCondition.New:\n        return AppTheme.successColor;\n      case BookCondition.LikeNew:\n        return Colors.blue;\n      case BookCondition.Good:\n        return AppTheme.warningColor;\n      case BookCondition.Used:\n        return Colors.grey;\n    }\n  }\n\n  Color _getStatusColor(SwapStatus status) {\n    switch (status) {\n      case SwapStatus.Available:\n        return AppTheme.successColor;\n      case SwapStatus.Pending:\n        return AppTheme.warningColor;\n      case SwapStatus.Accepted:\n        return Colors.blue;\n      case SwapStatus.Rejected:\n        return AppTheme.errorColor;\n    }\n  }\n\n  String _formatDate(DateTime date) {\n    final now = DateTime.now();\n    final difference = now.difference(date).inDays;\n    if (difference == 0) return 'Today';\n    if (difference == 1) return 'Yesterday';\n    return '$difference days ago';\n  }\n}