import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import '../providers/messaging_provider.dart';
import '../providers/auth_provider.dart';
import '../models/messaging_models.dart';
import '../services/messaging_service.dart';
import '../utils/url_helper.dart';
import '../widgets/message_reaction_picker.dart';

class ChatScreen extends StatefulWidget {
  final ConversationResponse conversation;

  const ChatScreen({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  Timer? _typingTimer;
  bool _isTyping = false;
  int _previousMessageCount = 0;
  int? _lastReadMessageId;
  MessagingProvider? _messagingProvider;
  
  @override
  void initState() {
    super.initState();
    
    // Load messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messagingProvider = context.read<MessagingProvider>();
      _messagingProvider!.loadMessages(
        widget.conversation.id,
        refresh: true,
      );
      
      // Scroll to bottom after messages load
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _scrollToBottom();
          _markLatestMessageAsRead();
        }
      });
      
      // Listen to message changes to auto-scroll
      _messagingProvider!.addListener(_onMessagesChanged);
    });
    
    // Listen to text changes for typing indicator
    _messageController.addListener(_onTextChanged);
  }
  
  void _onMessagesChanged() {
    if (!mounted || _messagingProvider == null) return;
    
    final messages = _messagingProvider!.getMessages(widget.conversation.id);
    if (messages != null && messages.length != _previousMessageCount) {
      _previousMessageCount = messages.length;
      // Scroll to bottom when new message arrives
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToBottom();
          _markLatestMessageAsRead();
        }
      });
    }
  }
  
  void _markLatestMessageAsRead() {
    if (!mounted || _messagingProvider == null) return;
    
    final authProvider = context.read<AuthProvider>();
    final messages = _messagingProvider!.getMessages(widget.conversation.id);
    
    if (messages != null && messages.isNotEmpty) {
      final lastMessage = messages.last;
      
      // Only mark as read if:
      // 1. It's not from me
      // 2. We haven't already marked this message as read
      if (lastMessage.senderId != authProvider.user?.id && 
          lastMessage.id != _lastReadMessageId) {
        print('👁️ Marking message ${lastMessage.id} as read (one time)');
        _lastReadMessageId = lastMessage.id;
        _messagingProvider!.markAsRead(widget.conversation.id, lastMessage.id);
      }
    }
  }

  @override
  void dispose() {
    if (_messagingProvider != null) {
      _messagingProvider!.removeListener(_onMessagesChanged);
      
      // Unsubscribe from conversation
      _messagingProvider!.unsubscribeFromConversation(
        widget.conversation.id,
      );
    }
    
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    
    super.dispose();
  }

  void _onTextChanged() {
    if (_messageController.text.trim().isNotEmpty && !_isTyping) {
      _isTyping = true;
      _sendTypingIndicator(true);
    } else if (_messageController.text.trim().isEmpty && _isTyping) {
      _isTyping = false;
      _sendTypingIndicator(false);
    }
    
    // Reset typing indicator after 3 seconds of inactivity
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      if (_isTyping) {
        _isTyping = false;
        _sendTypingIndicator(false);
      }
    });
  }

  void _sendTypingIndicator(bool isTyping) {
    final authProvider = context.read<AuthProvider>();
    final messagingProvider = context.read<MessagingProvider>();
    
    if (authProvider.user != null) {
      messagingProvider.sendTypingIndicator(
        widget.conversation.id,
        authProvider.user!.id,
        authProvider.user!.username,
        isTyping,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final authProvider = context.read<AuthProvider>();
    final messagingProvider = context.read<MessagingProvider>();
    
    if (authProvider.user == null) return;
    
    // Stop typing indicator
    _isTyping = false;
    _sendTypingIndicator(false);
    _typingTimer?.cancel();
    
    final request = SendMessageRequest(
      conversationId: widget.conversation.id,
      content: text,
      messageType: MessageType.text,
    );
    
    _messageController.clear();
    
    await messagingProvider.sendMessage(request);
    
    // Scroll to bottom
    _scrollToBottom();
  }

  Future<void> _reactToMessage(MessageResponse message, ReactionType reactionType) async {
    try {
      final messagingService = MessagingService();
      await messagingService.reactToMessage(message.id, reactionType.name);
      
      // Refresh messages to get updated reactions
      if (mounted) {
        final provider = context.read<MessagingProvider>();
        provider.loadMessages(widget.conversation.id, refresh: true);
      }
    } catch (e) {
      print('Error reacting to message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể thả cảm xúc: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        // TODO: Upload image and send message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải ảnh lên...')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Use a small delay to ensure the list has been rebuilt
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF6366F1)),
              title: const Text('Thư viện ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6366F1)),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.displayTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Consumer<MessagingProvider>(
                    builder: (context, provider, child) {
                      final typingUsers = provider.getTypingUsers(widget.conversation.id);
                      
                      if (typingUsers.isNotEmpty) {
                        return const Text(
                          'Đang nhập...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6366F1),
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }
                      
                      if (widget.conversation.type == ConversationType.direct &&
                          widget.conversation.otherParticipantIsOnline == true) {
                        return const Text(
                          'Đang hoạt động',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B981),
                          ),
                        );
                      }
                      
                      return Text(
                        '${widget.conversation.memberCount} thành viên',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF6B7280)),
            onPressed: () {
              // TODO: Show conversation info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessagingProvider>(
              builder: (context, provider, child) {
                final messages = provider.getMessages(widget.conversation.id);
                
                if (messages == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  );
                }
                
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có tin nhắn nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gửi tin nhắn đầu tiên của bạn',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == 
                        context.read<AuthProvider>().user?.id;
                    
                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                      showAvatar: _shouldShowAvatar(messages, index, isMe),
                      onReact: (reactionType) {
                        _reactToMessage(message, reactionType);
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  bool _shouldShowAvatar(List<MessageResponse> messages, int index, bool isMe) {
    if (widget.conversation.type == ConversationType.direct) {
      return false;
    }
    
    if (index == messages.length - 1) {
      return true;
    }
    
    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];
    
    return currentMessage.senderId != nextMessage.senderId;
  }

  Widget _buildAvatar() {
    if (widget.conversation.type == ConversationType.group) {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.group,
          color: Colors.white,
          size: 20,
        ),
      );
    }

    if (widget.conversation.displayAvatar != null) {
      return FutureBuilder<Map<String, String>>(
        future: UrlHelper.getHeaders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
            );
          }
          
          return CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage: NetworkImage(
              UrlHelper.fixImageUrl(widget.conversation.displayAvatar!),
              headers: snapshot.data,
            ),
          );
        },
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF6366F1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          (widget.conversation.displayTitle.isNotEmpty
                  ? widget.conversation.displayTitle[0]
                  : '?')
              .toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF6366F1)),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageResponse message;
  final bool isMe;
  final bool showAvatar;
  final Function(ReactionType) onReact;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.onReact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) _buildAvatar() else const SizedBox(width: 32),
          if (!isMe && !showAvatar) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showReactionPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF1E88E5) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              message.senderDisplayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                          ),
                        _buildMessageContent(),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(message.createdAt, locale: 'vi'),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Display reactions below the message
                MessageReactionDisplay(
                  reactionCounts: message.reactionCounts,
                  currentUserReaction: message.currentUserReaction,
                  onReactionTap: (reaction) {
                    if (message.currentUserReaction?.toLowerCase() == reaction.name.toLowerCase()) {
                      // Remove reaction if same reaction tapped
                      _removeReaction(context);
                    } else {
                      // Add or change reaction
                      onReact(reaction);
                    }
                  },
                  onReactionLongPress: () => _showReactionPicker(context),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  void _removeReaction(BuildContext context) async {
    try {
      final messagingService = MessagingService();
      await messagingService.removeReaction(message.id);
      
      // Update local state through provider
      final messagingProvider = context.read<MessagingProvider>();
      messagingProvider.loadMessages(message.conversationId, refresh: true);
    } catch (e) {
      print('Error removing reaction: $e');
    }
  }

  Widget _buildAvatar() {
    if (message.senderAvatarUrl != null) {
      return FutureBuilder<Map<String, String>>(
        future: UrlHelper.getHeaders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
            );
          }
          
          return CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage: NetworkImage(
              UrlHelper.fixImageUrl(message.senderAvatarUrl!),
              headers: snapshot.data,
            ),
          );
        },
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF6366F1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          message.senderDisplayName[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.messageType) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.video:
        return _buildVideoMessage();
      case MessageType.file:
        return _buildFileMessage();
      case MessageType.text:
      default:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: isMe ? Colors.white : const Color(0xFF1F2937),
          ),
        );
    }
  }

  Widget _buildImageMessage() {
    if (message.attachments == null || message.attachments!.isEmpty) {
      return Text(
        message.content,
        style: TextStyle(
          fontSize: 15,
          color: isMe ? Colors.white : const Color(0xFF1F2937),
        ),
      );
    }

    return FutureBuilder<Map<String, String>>(
      future: UrlHelper.getHeaders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 200,
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            UrlHelper.fixImageUrl(message.attachments!.first.fileUrl),
            headers: snapshot.data,
            width: 200,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildVideoMessage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildFileMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.insert_drive_file, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: isMe ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Thả cảm xúc',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            MessageReactionPicker(
              onReactionSelected: (reaction) {
                Navigator.pop(context);
                onReact(reaction);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
