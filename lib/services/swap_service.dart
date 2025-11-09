import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_offer_model.dart';
import '../models/book_model.dart';

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a swap offer
  Future<String> createSwapOffer({
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
      String offerId = _firestore.collection('swapOffers').doc().id;
      
      SwapOfferModel offer = SwapOfferModel(
        id: offerId,
        bookId: bookId,
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        bookImageUrl: bookImageUrl,
        ownerId: ownerId,
        ownerName: ownerName,
        requesterId: requesterId,
        requesterName: requesterName,
        createdAt: DateTime.now(),
      );

      print('SwapService: Creating offer for book $bookTitle by $requesterName');
      Map<String, dynamic> offerData = {
        'id': offerId,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'bookAuthor': bookAuthor,
        'bookImageUrl': bookImageUrl,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'status': 0, // pending
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'respondedAt': null,
      };
      
      print('SwapService: Saving offer data: $offerData');
      await _firestore.collection('swapOffers').doc(offerId).set(offerData);
      print('SwapService: Offer created successfully with ID: $offerId');
      
      // Update book status to pending
      await _firestore.collection('books').doc(bookId).update({
        'status': SwapStatus.Pending.index,
        'swapRequesterId': requesterId,
      });

      return offerId;
    } catch (e) {
      throw Exception('Failed to create swap offer: $e');
    }
  }

  // Get swap offers for a user (as requester)
  Stream<List<SwapOfferModel>> getUserSwapOffers(String userId) {
    print('SwapService: Getting swap offers for user: $userId');
    return _firestore
        .collection('swapOffers')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('SwapService: Found ${snapshot.docs.length} offers for user $userId');
          List<SwapOfferModel> offers = [];
          
          for (var doc in snapshot.docs) {
            try {
              print('SwapService: Processing offer doc: ${doc.id}');
              print('SwapService: Offer data: ${doc.data()}');
              SwapOfferModel offer = SwapOfferModel.fromMap(doc.data());
              offers.add(offer);
              print('SwapService: Successfully parsed offer: ${offer.bookTitle}');
            } catch (e) {
              print('SwapService: Error parsing offer ${doc.id}: $e');
            }
          }
          
          // Sort locally
          offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          print('SwapService: Returning ${offers.length} parsed offers');
          return offers;
        });
  }

  // Get swap offers received by a user (as owner)
  Stream<List<SwapOfferModel>> getReceivedSwapOffers(String userId) {
    return _firestore
        .collection('swapOffers')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          List<SwapOfferModel> offers = snapshot.docs
              .map((doc) => SwapOfferModel.fromMap(doc.data()))
              .toList();
          // Sort locally
          offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return offers;
        });
  }

  // Respond to swap offer
  Future<void> respondToSwapOffer(String offerId, OfferStatus status) async {
    try {
      print('SwapService: Responding to offer $offerId with status ${status.name}');
      
      await _firestore.collection('swapOffers').doc(offerId).update({
        'status': status.index,
        'respondedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Get the offer to update book status
      DocumentSnapshot offerDoc = await _firestore.collection('swapOffers').doc(offerId).get();
      SwapOfferModel offer = SwapOfferModel.fromMap(offerDoc.data() as Map<String, dynamic>);

      // Update book status based on response
      SwapStatus bookStatus;
      if (status == OfferStatus.accepted) {
        bookStatus = SwapStatus.Accepted;
      } else if (status == OfferStatus.rejected) {
        bookStatus = SwapStatus.Available; // Back to available
      } else {
        bookStatus = SwapStatus.Pending;
      }

      await _firestore.collection('books').doc(offer.bookId).update({
        'status': bookStatus.index,
      });
      
      print('SwapService: Book status updated to ${bookStatus.name}');
    } catch (e) {
      print('SwapService: Error responding to offer: $e');
      throw Exception('Failed to respond to swap offer: $e');
    }
  }

  // Delete swap offer
  Future<void> deleteSwapOffer(String offerId) async {
    try {
      // Get the offer first to update book status
      DocumentSnapshot offerDoc = await _firestore.collection('swapOffers').doc(offerId).get();
      if (offerDoc.exists) {
        SwapOfferModel offer = SwapOfferModel.fromMap(offerDoc.data() as Map<String, dynamic>);
        
        // Reset book status to available
        await _firestore.collection('books').doc(offer.bookId).update({
          'status': SwapStatus.Available.index,
          'swapRequesterId': null,
        });
      }

      await _firestore.collection('swapOffers').doc(offerId).delete();
    } catch (e) {
      throw Exception('Failed to delete swap offer: $e');
    }
  }
}