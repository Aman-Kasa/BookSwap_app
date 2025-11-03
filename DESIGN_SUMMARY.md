# BookSwap App - Design Summary

## Database Schema

### Entity Relationship Diagram (ERD)

```
Users ||--o{ Books : owns
Users ||--o{ ChatRooms : participates
Books ||--o{ SwapRequests : has
ChatRooms ||--o{ Messages : contains
```

### Collections Structure

#### Users Collection
- **Purpose**: Store user profile information
- **Fields**:
  - `id` (string): Unique user identifier
  - `email` (string): User's email address
  - `name` (string): User's display name
  - `emailVerified` (boolean): Email verification status

#### Books Collection
- **Purpose**: Store book listings and swap information
- **Fields**:
  - `id` (string): Unique book identifier
  - `title` (string): Book title
  - `author` (string): Book author
  - `condition` (int): Book condition enum (0=New, 1=LikeNew, 2=Good, 3=Used)
  - `imageUrl` (string): Firebase Storage URL for book cover
  - `ownerId` (string): Reference to Users collection
  - `ownerName` (string): Denormalized owner name for quick access
  - `status` (int): Swap status enum (0=Available, 1=Pending, 2=Accepted, 3=Rejected)
  - `createdAt` (timestamp): Book listing creation time
  - `swapRequesterId` (string, optional): User who requested the swap

#### ChatRooms Collection
- **Purpose**: Manage chat sessions between users
- **Fields**:
  - `id` (string): Composite key of sorted user IDs
  - `participants` (array): List of user IDs in the chat
  - `lastMessage` (string, optional): Most recent message preview
  - `lastMessageTime` (timestamp, optional): Time of last message

#### Messages Subcollection (under ChatRooms)
- **Purpose**: Store individual chat messages
- **Fields**:
  - `id` (string): Unique message identifier
  - `senderId` (string): Message sender's user ID
  - `receiverId` (string): Message recipient's user ID
  - `message` (string): Message content
  - `timestamp` (timestamp): Message creation time

## Swap State Modeling

### State Transitions
```
Available → Pending (when swap requested)
Pending → Accepted (owner accepts)
Pending → Rejected (owner rejects)
Accepted → [End State]
Rejected → Available (book becomes available again)
```

### Implementation Details
- **Atomic Updates**: Firestore transactions ensure consistent state changes
- **Real-time Sync**: Firestore listeners provide instant UI updates
- **Denormalization**: Owner name stored in books for efficient queries
- **Composite Keys**: Chat room IDs use sorted user IDs for uniqueness

## State Management Architecture

### Provider Pattern Implementation

#### AuthProvider
- **Responsibility**: Manages authentication state and user session
- **Key Methods**:
  - `signUp()`: Creates new user account with email verification
  - `signIn()`: Authenticates existing user
  - `signOut()`: Clears user session
- **State**: Current user object, loading status, authentication status

#### BookProvider
- **Responsibility**: Handles all book-related operations
- **Key Methods**:
  - `createBook()`: Adds new book listing with image upload
  - `updateBook()`: Modifies existing book details
  - `deleteBook()`: Removes book listing
  - `initiateSwap()`: Creates swap request
  - `updateSwapStatus()`: Changes swap state
- **Streams**: Real-time book lists for different views

#### ChatProvider
- **Responsibility**: Manages chat functionality
- **Key Methods**:
  - `createChatRoom()`: Initializes chat between users
  - `sendMessage()`: Adds message to chat
  - `getChatMessages()`: Streams messages for a chat room
- **Real-time**: All chat operations use Firestore streams

### Data Flow
```
UI Widget → Provider Method → Service Layer → Firebase → Stream → Provider → UI Update
```

## Design Trade-offs and Challenges

### Trade-offs Made

1. **Denormalization vs. Normalization**
   - **Choice**: Store owner name in book documents
   - **Benefit**: Faster queries, fewer reads
   - **Cost**: Data consistency complexity

2. **Real-time vs. Polling**
   - **Choice**: Firestore real-time listeners
   - **Benefit**: Instant updates, better UX
   - **Cost**: Higher Firebase usage costs

3. **Image Storage Strategy**
   - **Choice**: Firebase Storage with URL references
   - **Benefit**: CDN delivery, automatic scaling
   - **Cost**: Additional service dependency

### Challenges Addressed

1. **State Synchronization**
   - **Problem**: Multiple users viewing same book
   - **Solution**: Firestore real-time listeners with Provider pattern
   - **Result**: Instant UI updates across all clients

2. **Chat Room Management**
   - **Problem**: Creating unique chat rooms between users
   - **Solution**: Composite key using sorted user IDs
   - **Result**: Prevents duplicate chat rooms

3. **Image Upload Handling**
   - **Problem**: Large image files affecting performance
   - **Solution**: Firebase Storage with progress indicators
   - **Result**: Smooth upload experience with feedback

4. **Authentication Flow**
   - **Problem**: Email verification requirement
   - **Solution**: Block login until email verified
   - **Result**: Ensures valid user emails

### Performance Optimizations

1. **Cached Network Images**: Reduces repeated downloads
2. **Stream Builders**: Efficient real-time data binding
3. **Pagination Ready**: Architecture supports future pagination
4. **Optimistic Updates**: UI updates before server confirmation

### Security Considerations

1. **Firestore Rules**: Restrict data access to authenticated users
2. **Storage Rules**: Limit file uploads to authenticated users
3. **Input Validation**: Client and server-side validation
4. **Email Verification**: Prevents fake accounts

## Future Enhancements

1. **Push Notifications**: Firebase Cloud Messaging integration
2. **Advanced Search**: Full-text search with Algolia
3. **Rating System**: User and book rating functionality
4. **Geolocation**: Location-based book discovery
5. **Offline Support**: Local caching with sync capabilities