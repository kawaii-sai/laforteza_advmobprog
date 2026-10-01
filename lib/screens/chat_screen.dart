import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final ChatService _chatService =
      ChatService();

  final TextEditingController
      _messageController =
      TextEditingController();

  final ScrollController
      _scrollController =
      ScrollController();

  bool _isSending = false;

  int _previousMessageCount = 0;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message =
        _messageController.text.trim();

    if (message.isEmpty ||
        _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(
        receiverId:
            widget.otherUserId,
        message: message,
      );

      _messageController.clear();

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!_scrollController
            .hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController
              .position
              .maxScrollExtent,
          duration:
              const Duration(
            milliseconds: 300,
          ),
          curve: Curves.easeOut,
        );
      },
    );
  }

  String _formatTimestamp(
    Timestamp? timestamp,
  ) {
    if (timestamp == null) {
      return '';
    }

    final date =
        timestamp.toDate();

    final hour =
        date.hour % 12 == 0
            ? 12
            : date.hour % 12;

    final minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Map<String, dynamic> data,
    int index,
  ) {
    final currentUserId =
        _chatService.currentUserId;

    final senderId =
        data['senderId']
                ?.toString() ??
            '';

    final message =
        data['message']
                ?.toString() ??
            '';

    final timestamp =
        data['timestamp'] as Timestamp?;

    final isMe =
        senderId == currentUserId;

    return TweenAnimationBuilder<double>(
      key: ValueKey(
        data['messageId'] ??
            '$senderId-$index',
      ),
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ),
      duration:
          const Duration(
        milliseconds: 350,
      ),
      curve: Curves.easeOutCubic,
      builder: (
        context,
        value,
        child,
      ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              isMe
                  ? 30 * (1 - value)
                  : -30 * (1 - value),
              12 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          constraints:
              BoxConstraints(
            maxWidth:
                MediaQuery.of(
                        context)
                    .size
                    .width *
                0.78,
          ),
          margin:
              const EdgeInsets.only(
            bottom: 10,
          ),
          padding:
              const EdgeInsets.fromLTRB(
            15,
            11,
            12,
            8,
          ),
          decoration:
              BoxDecoration(
            color: isMe
                ? Theme.of(
                    context,
                  )
                    .colorScheme
                    .primary
                : Theme.of(
                    context,
                  )
                    .colorScheme
                    .surfaceContainerHighest,
            borderRadius:
                BorderRadius.only(
              topLeft:
                  const Radius.circular(
                18,
              ),
              topRight:
                  const Radius.circular(
                18,
              ),
              bottomLeft:
                  Radius.circular(
                isMe ? 18 : 4,
              ),
              bottomRight:
                  Radius.circular(
                isMe ? 4 : 18,
              ),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                offset:
                    const Offset(
                  0,
                  2,
                ),
                color: Colors.black
                    .withValues(
                  alpha: 0.06,
                ),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMe
                    ? CrossAxisAlignment
                        .end
                    : CrossAxisAlignment
                        .start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: isMe
                      ? Theme.of(
                          context,
                        )
                          .colorScheme
                          .onPrimary
                      : Theme.of(
                          context,
                        )
                          .colorScheme
                          .onSurface,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  if (timestamp != null)
                    Text(
                      _formatTimestamp(
                        timestamp,
                      ),
                      style:
                          TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? Theme.of(
                                context,
                              )
                                .colorScheme
                                .onPrimary
                                .withValues(
                                  alpha:
                                      0.75,
                                )
                            : Theme.of(
                                context,
                              )
                                .colorScheme
                                .onSurfaceVariant,
                      ),
                    ),
                  if (isMe) ...[
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.done_all,
                      size: 15,
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onPrimary
                          .withValues(
                            alpha: 0.80,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendingIndicator(
    BuildContext context,
  ) {
    if (!_isSending) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        left: 16,
        bottom: 8,
      ),
      child: Align(
        alignment:
            Alignment.centerLeft,
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .primary,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              'Sending...',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .onSurfaceVariant,
                fontStyle:
                    FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        10,
      ),
      decoration:
          BoxDecoration(
        color: Theme.of(
          context,
        )
            .scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset:
                const Offset(
              0,
              -2,
            ),
            color: Colors.black
                .withValues(
              alpha: 0.05,
            ),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller:
                    _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction:
                    TextInputAction
                        .newline,
                decoration:
                    InputDecoration(
                  hintText:
                      'Type a message...',
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  )
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(
                        alpha: 0.55,
                      ),
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      24,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      24,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      24,
                    ),
                    borderSide:
                        BorderSide(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 200,
              ),
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color: _isSending
                    ? Theme.of(
                        context,
                      )
                        .colorScheme
                        .surfaceContainerHighest
                    : Theme.of(
                        context,
                      )
                        .colorScheme
                        .primary,
                shape:
                    BoxShape.circle,
              ),
              child: IconButton(
                onPressed:
                    _isSending
                        ? null
                        : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Theme.of(
                          context,
                        )
                            .colorScheme
                            .onPrimary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              child: Text(
                widget.otherUserName
                        .isNotEmpty
                    ? widget.otherUserName[
                        0]
                        .toUpperCase()
                    : '?',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                widget.otherUserName,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream:
                  _chatService
                      .getMessages(
                widget.otherUserId,
              ),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(24),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          Icon(
                            Icons
                                .error_outline,
                            size: 48,
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .error,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text(
                            'Unable to load messages.',
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            '${snapshot.error}',
                            textAlign:
                                TextAlign
                                    .center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final messages =
                    snapshot.data
                            ?.docs ??
                        [];

                if (messages.length >
                    _previousMessageCount) {
                  _previousMessageCount =
                      messages.length;

                  _scrollToBottom();
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(24),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration:
                                BoxDecoration(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .primary
                                  .withValues(
                                    alpha:
                                        0.10,
                                  ),
                              shape:
                                  BoxShape
                                      .circle,
                            ),
                            child:
                                Icon(
                              Icons
                                  .chat_bubble_outline,
                              size: 36,
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text(
                            'Start a conversation',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            'Send a message to ${widget.otherUserName}.',
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                TextStyle(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller:
                      _scrollController,
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    12,
                    16,
                    12,
                    12,
                  ),
                  itemCount:
                      messages.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return _buildMessageBubble(
                      context,
                      messages[index]
                          .data(),
                      index,
                    );
                  },
                );
              },
            ),
          ),
          _buildSendingIndicator(
            context,
          ),
          _buildMessageInput(
            context,
          ),
        ],
      ),
    );
  }
}