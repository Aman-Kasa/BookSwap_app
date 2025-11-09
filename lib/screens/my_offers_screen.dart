import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/swap_offer_model.dart';
import '../providers/swap_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import 'dart:convert';

class MyOffersScreen extends StatefulWidget {
  @override
  _MyOffersScreenState createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.backgroundColor,
          ],
          stops: [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: AppTheme.accentGradient,
                      ).createShader(bounds),
                      child: Text(
                        'My Offers',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.swap_horiz,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        // Offers List
                        Expanded(
                          child: Consumer<app_auth.AuthProvider>(
                            builder: (context, authProvider, child) {
                              if (authProvider.user == null) {
                                return Center(child: Text('Please log in'));
                              }
                              
                              return StreamBuilder<List<SwapOfferModel>>(
                                stream: context.read<SwapProvider>().getUserSwapOffers(authProvider.user!.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
                                  }
                                  
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(40),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: AppTheme.accentGradient),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.accentColor.withOpacity(0.3),
                                                blurRadius: 30,
                                                offset: Offset(0, 15),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.swap_horiz,
                                            size: 80,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        Text(
                                          'No Swap Offers Yet',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Browse books and make swap offers\\nto see them here',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppTheme.textSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  
                                  // Show swap offers
                                  List<SwapOfferModel> offers = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Your Swap Offers',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: AppTheme.accentGradient),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${offers.length} offers',
                                              style: TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Expanded(
                                        child: ListView.builder(
                                          padding: EdgeInsets.only(bottom: 100),
                                          itemCount: offers.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.only(bottom: 16),
                                              child: _buildOfferCard(offers[index]),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(SwapOfferModel offer) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (offer.status) {
      case OfferStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        statusIcon = Icons.hourglass_empty;
        break;
      case OfferStatus.accepted:
        statusColor = Colors.green;
        statusText = 'Accepted';
        statusIcon = Icons.check_circle;
        break;
      case OfferStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Rejected';
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // Book Image
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: offer.bookImageUrl.isNotEmpty
                    ? Image.memory(
                        base64Decode(offer.bookImageUrl.contains(',') 
                            ? offer.bookImageUrl.split(',')[1] 
                            : offer.bookImageUrl),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppTheme.surfaceColor,
                        child: Icon(Icons.book, color: AppTheme.accentColor, size: 40),
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
                    offer.bookTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'by ${offer.bookAuthor}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Owner: ${offer.ownerName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            if (offer.status == OfferStatus.pending)
              IconButton(
                onPressed: () => _cancelOffer(offer.id),
                icon: Icon(Icons.close, color: Colors.red),
                tooltip: 'Cancel Offer',
              ),
          ],
        ),
      ),
    );
  }

  void _cancelOffer(String offerId) async {
    try {
      await context.read<SwapProvider>().deleteSwapOffer(offerId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer cancelled successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling offer: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}