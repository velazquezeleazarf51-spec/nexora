import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';

/// Chat con texto + imagen/video (estilo WhatsApp).
class ChatMediaPage extends StatefulWidget {
  const ChatMediaPage({super.key, required this.supabaseReady, required this.isDemo, required this.onToast});
  final bool supabaseReady;
  final bool isDemo;
  final void Function(String) onToast;
  @override
  State<ChatMediaPage> createState() => _ChatMediaPageState();
}

class _ChatMsg {
  _ChatMsg({required this.text, this.mediaUrl, this.mediaType, required this.mine, required this.time});
  final String text;
  final String? mediaUrl, mediaType;
  final bool mine;
  final String time;
}

class _ChatMediaPageState extends State<ChatMediaPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatMsg> _msgs = [
    _ChatMsg(text: 'Hola! Este chat admite fotos y videos', mine: false, time: '10:00'),
    _ChatMsg(text: 'Genial, como WhatsApp', mine: true, time: '10:01'),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send({String? text, XFile? file, String? mediaType}) async {
    final body = (text ?? _ctrl.text).trim();
    if (body.isEmpty && file == null) return;
    _ctrl.clear();
    String? url;
    if (file != null && widget.supabaseReady && !widget.isDemo && Constants.hasSupabaseCredentials) {
      try {
        final client = Supabase.instance.client;
        final uid = client.auth.currentUser?.id;
        if (uid == null) throw Exception('Sin sesión');
        final ext = file.name.split('.').last.toLowerCase();
        final path = '$uid/chat_${const Uuid().v4()}.$ext';
        final bytes = await file.readAsBytes();
        await client.storage.from('media').uploadBinary(
          path, bytes,
          fileOptions: FileOptions(contentType: file.mimeType ?? 'application/octet-stream', upsert: true),
        );
        url = client.storage.from('media').getPublicUrl(path);
      } catch (e) {
        widget.onToast('No se pudo subir el archivo: $e');
        return;
      }
    } else if (file != null) {
      url = file.path;
    }
    setState(() {
      _msgs.add(_ChatMsg(text: body, mediaUrl: url, mediaType: mediaType, mine: true, time: TimeOfDay.now().format(context)));
    });
    await Future.delayed(const Duration(milliseconds: 50));
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  Future<void> _attach() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.photo), title: const Text('Imagen'), onTap: () => Navigator.pop(ctx, 'image')),
          ListTile(leading: const Icon(Icons.videocam), title: const Text('Video'), onTap: () => Navigator.pop(ctx, 'video')),
          ListTile(leading: const Icon(Icons.close), title: const Text('Cancelar'), onTap: () => Navigator.pop(ctx)),
        ]),
      ),
    );
    if (choice == null) return;
    final picker = ImagePicker();
    final file = choice == 'image'
        ? await picker.pickImage(source: ImageSource.gallery, imageQuality: 85)
        : await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
    if (file == null) return;
    await _send(file: file, mediaType: choice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          Icon(Icons.chat_bubble_outline_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('Chat', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const Spacer(),
          Text('Fotos y videos', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.55))),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          itemCount: _msgs.length,
          itemBuilder: (_, i) {
            final m = _msgs[i];
            final align = m.mine ? Alignment.centerRight : Alignment.centerLeft;
            final bg = m.mine ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest;
            return Align(
              alignment: align,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (m.mediaType != null)
                    Container(
                      height: 120, width: double.infinity, margin: const EdgeInsets.only(bottom: 6), alignment: Alignment.center,
                      decoration: BoxDecoration(color: theme.colorScheme.surface.withOpacity(0.4), borderRadius: BorderRadius.circular(10)),
                      child: Icon(m.mediaType == 'video' ? Icons.play_circle_outline : Icons.image_outlined, size: 40),
                    ),
                  if (m.text.isNotEmpty) Text(m.text),
                  const SizedBox(height: 2),
                  Text(m.time, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                ]),
              ),
            );
          },
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Row(children: [
            IconButton(onPressed: _attach, icon: const Icon(Icons.attach_file_rounded), tooltip: 'Imagen o video'),
            Expanded(
              child: TextField(
                controller: _ctrl, minLines: 1, maxLines: 4,
                decoration: const InputDecoration(hintText: 'Mensaje', border: OutlineInputBorder(), isDense: true),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(onPressed: () => _send(), icon: const Icon(Icons.send_rounded)),
          ]),
        ),
      ),
    ]);
  }
}
