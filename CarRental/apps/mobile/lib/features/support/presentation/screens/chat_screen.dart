import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).setOpen(true);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);

    ref.listen(chatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length || prev?.isTyping != next.isTyping) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Column(
          children: [
            Text('SAFRA Concierge', style: AppTypography.headingSmall()),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'ONLINE — 24/7',
                  style: AppTypography.monoStyle(color: AppColors.inkMuted, size: 7),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.clearHistory();
            },
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear history',
          ),
        ],
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: chatState.messages.isEmpty
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length) {
                        return _buildTypingIndicatorBubble();
                      }
                      final msg = chatState.messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),

          // Suggestion Chips (Common questions keywords)
          _buildSuggestionChips(notifier),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 12.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12.0,
            ),
            decoration: const BoxDecoration(
              color: AppColors.panel,
              border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        style: AppTypography.bodyLarge(color: AppColors.ink),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty && !chatState.isTyping) {
                            HapticFeedback.lightImpact();
                            notifier.sendMessage(val);
                            _inputController.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Ask about fleet, pricing...',
                          hintStyle: AppTypography.bodyMedium(color: AppColors.inkSubtle),
                          filled: true,
                          fillColor: AppColors.paper,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        final val = _inputController.text.trim();
                        if (val.isNotEmpty && !chatState.isTyping) {
                          HapticFeedback.lightImpact();
                          notifier.sendMessage(val);
                          _inputController.clear();
                        }
                      },
                      icon: const Icon(Icons.send_rounded, color: AppColors.amber),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg) {
    final isUser = msg.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.amberPale,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.support_agent_rounded, color: AppColors.amber, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isUser ? AppColors.amber : AppColors.panel,
                border: isUser ? null : Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14.0),
                  topRight: const Radius.circular(14.0),
                  bottomLeft: Radius.circular(isUser ? 14.0 : 4.0),
                  bottomRight: Radius.circular(isUser ? 4.0 : 14.0),
                ),
              ),
              child: _buildRichMessageText(msg.text, isUser),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichMessageText(String rawText, bool isUser) {
    final textColor = isUser ? Colors.white : AppColors.ink;
    final List<TextSpan> spans = [];

    final regex = RegExp(r'(\*\*[^*]+\*\*)');
    final matches = regex.allMatches(rawText);

    if (matches.isEmpty) {
      return Text(
        rawText,
        style: AppTypography.bodyMedium(color: textColor),
      );
    }

    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: rawText.substring(lastIndex, match.start),
          style: AppTypography.bodyMedium(color: textColor),
        ));
      }
      final boldText = rawText.substring(match.start + 2, match.end - 2);
      spans.add(TextSpan(
        text: boldText,
        style: AppTypography.bodyMedium(color: textColor).copyWith(fontWeight: FontWeight.bold),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < rawText.length) {
      spans.add(TextSpan(
        text: rawText.substring(lastIndex),
        style: AppTypography.bodyMedium(color: textColor),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildTypingIndicatorBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.amberPale,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.support_agent_rounded, color: AppColors.amber, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: AppColors.panel,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14.0),
                topRight: Radius.circular(14.0),
                bottomLeft: Radius.circular(4.0),
                bottomRight: Radius.circular(14.0),
              ),
            ),
            child: _BouncingDotsIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(ChatNotifier notifier) {
    final suggestions = ['Pricing', 'Insurance', 'Delivery', 'Membership', 'EV Fleet'];
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final query = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                notifier.sendMessage(query);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    query,
                    style: AppTypography.monoStyle(color: AppColors.amber, size: 8),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BouncingDotsIndicator extends StatefulWidget {
  @override
  State<_BouncingDotsIndicator> createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<_BouncingDotsIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final double value = (sin((_controller.value * 2 * pi) - delay) + 1.0) / 2.0;

            return Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                color: AppColors.inkMuted.withValues(alpha: 0.3 + (value * 0.7)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
