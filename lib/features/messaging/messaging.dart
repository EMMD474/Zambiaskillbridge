import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

({String name, String? photo, int color}) _otherParty(AppState s, Conversation c) {
  if (s.isWorker) return (name: c.clientName, photo: null, color: 0xFFEAF0F6);
  final w = s.worker(c.workerId);
  return (name: w?.name ?? 'Worker', photo: w?.photoPath, color: w?.colorValue ?? 0xFFEAF0F6);
}

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    final list = s.myConversations;
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), automaticallyImplyLeading: false),
      body: Column(children: [
        const Padding(padding: EdgeInsets.fromLTRB(SB.pad, 0, SB.pad, 8), child: InfoNote('Demo messaging. Messages stay on this phone and are not delivered to other devices.', icon: Icons.phone_android)),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No conversations yet',
                  message: s.isWorker ? 'Message a client from a job or booking.' : 'Contact a worker from their profile to start a conversation.',
                  actionLabel: s.isWorker ? 'Find jobs' : 'Browse workers',
                  onAction: () => context.go('/discover'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(SB.pad, 4, SB.pad, 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) => ConversationTile(list[i]),
                ),
        ),
      ]),
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});
  final String conversationId;
  @override
  ConsumerState<ChatScreen> createState() => _ChatState();
}

class _ChatState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  void _send() {
    final t = _input.text;
    if (t.trim().isEmpty) return;
    ref.read(appProvider.notifier).sendMessage(widget.conversationId, t);
    _input.clear();
    _toEnd();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appProvider);
    final c = s.conversation(widget.conversationId);
    if (c == null) return Scaffold(appBar: AppBar(), body: const ErrorState(message: 'This conversation could not be found.'));
    if (s.unreadFor(c) > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(appProvider.notifier).markConversationRead(widget.conversationId);
      });
    }
    final o = _otherParty(s, c);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: s.isWorker ? null : () => context.push('/worker/${c.workerId}'),
          child: Row(children: [Avatar(name: o.name, photoPath: o.photo, size: 36, colorValue: o.color), const SizedBox(width: 10), Flexible(child: Text(o.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17)))]),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: c.messages.isEmpty
              ? const EmptyState(icon: Icons.waving_hand_outlined, title: 'Say hello', message: 'Send the first message. It is saved on this device only.')
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(SB.pad),
                  itemCount: c.messages.length,
                  itemBuilder: (_, i) {
                    final m = c.messages[i];
                    final mine = m.fromWorker == s.isWorker;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(color: mine ? SB.navy : Colors.white, borderRadius: BorderRadius.circular(16), border: mine ? null : Border.all(color: SB.border)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                          Align(alignment: Alignment.centerLeft, child: Text(m.text, style: TextStyle(color: mine ? Colors.white : SB.text, height: 1.35))),
                          const SizedBox(height: 3),
                          Text(fmtTime(m.at), style: TextStyle(fontSize: 10.5, color: mine ? Colors.white70 : SB.text2)),
                        ]),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
            child: Row(children: [
              Expanded(child: TextField(controller: _input, minLines: 1, maxLines: 4, textCapitalization: TextCapitalization.sentences, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Type a message'))),
              const SizedBox(width: 6),
              IconButton.filled(tooltip: 'Send message', onPressed: _send, icon: const Icon(Icons.send_rounded)),
            ]),
          ),
        ),
      ]),
    );
  }
}
