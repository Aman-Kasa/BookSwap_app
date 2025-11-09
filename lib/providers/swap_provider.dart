import 'package:flutter/material.dart';
import '../models/swap_offer_model.dart';
import '../services/swap_service.dart';

class SwapProvider with ChangeNotifier {
  final SwapService _swapService = SwapService();
  List<SwapOfferModel> _myOffers = [];
  List<SwapOfferModel> _receivedOffers = [];
  bool _isLoading = false;

  List<SwapOfferModel> get myOffers => _myOffers;
  List<SwapOfferModel> get receivedOffers => _receivedOffers;
  bool get isLoading => _isLoading;

  // Create swap offer
  Future<void> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required String bookImageUrl,
    required String ownerId,
    required String ownerName,
    required String requesterId,
    required String requesterName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _swapService.createSwapOffer(
        bookId: bookId,
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        bookImageUrl: bookImageUrl,
        ownerId: ownerId,
        ownerName: ownerName,
        requesterId: requesterId,
        requesterName: requesterName,
      );
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user's swap offers
  Stream<List<SwapOfferModel>> getUserSwapOffers(String userId) {
    return _swapService.getUserSwapOffers(userId);
  }

  // Get received swap offers
  Stream<List<SwapOfferModel>> getReceivedSwapOffers(String userId) {
    return _swapService.getReceivedSwapOffers(userId);
  }

  // Respond to swap offer
  Future<void> respondToSwapOffer(String offerId, OfferStatus status) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _swapService.respondToSwapOffer(offerId, status);
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete swap offer
  Future<void> deleteSwapOffer(String offerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _swapService.deleteSwapOffer(offerId);
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}