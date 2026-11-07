import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';

/// Fila de estados (tipo Instagram / WhatsApp) + publicar estado.
class StoriesStrip extends StatefulWidget {
  const StoriesStrip({super.key, required this.supabaseReady, required this.isDemo, required this.onToast});
  final bool supabaseReady;
  final bool isDemo;
  final void Function(String message) onToast;
  @override
  State<StoriesStrip> createState() => _StoriesStripState();
}

class _StoriesStripState extends State<StoriesStrip> {
  List<_StoryGroup> _groups = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!widget.supabaseReady || widget.isDemo || !Constants.hasSupabaseCredentials) {
      setState(() {
        _groups = [
          _StoryGroup(userId: 'me', name: 'Tu estado', isMe: true, items: []),
          _StoryGroup(userId: 'd1', name: 'Sofía', isMe: false, items: [_StoryItem(id: '1', mediaUrl: '', mediaType: 'image', caption: 'Demo')]),
          _StoryGroup(userId: 'd2', name: 'Leo', isMe: false, items: [_StoryItem(id: '2', mediaUrl: '', mediaType: 'video', caption: '')]),
        ];
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      final rows = await client
          .from('stories')
          .select('id, user_id, media_url, media_type, caption, created_at, profiles(display_name, username)')
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false)
          .limit(80);
      final map = <String, _StoryGroup>{};
      if (uid != null) {
        map[uid] = _StoryGroup(userId: uid, name: 'Tu estado', isMe: true, items: []);
      }
      for (final r in (rows as List)) {
        final userId = r['user_id'] as String;
        final p = r['profiles'] as Map<String, dynamic>?;
        final name = userId == uid ? 'Tu estado' : (p?['display_name'] as String? ?? p?['username'] as String? ?? 'Usuario');
        map.putIfAbsent(userId, () => _StoryGroup(userId: userId, name: name, isMe: userId == uid, items: []));
        map[userId]!.items.add(_StoryItem(
          id: r['id'] as String,
          mediaUrl: r['media_url'] as String? ?? '',
          mediaType: r['media_type'] as String? ?? 'image',
          caption: r['caption'] as String? ?? '',
        ));
      }
      final list = map.values.toList();
      list.sort((a, b) {
        if (a.isMe) return -1;
        if (b.isMe) return 1;
        return 0;
      });
      if (mounted) setState(() { _groups = list; _loading = false; });
    } catch (e) {
      debugPrint('Stories: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _publish() async {
    final picker = ImagePicker();
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.photo), title: const Text('Foto'), onTap: () => Navigator.pop(ctx, 'image')),
          ListTile(leading: const Icon(Icons.videocam), title: const Text('Video (máx. 60 s en estado)'), onTap: () => Navigator.pop(ctx, 'video')),
          ListTile(leading: const Icon(Icons.close), title: const Text('Cancelar'), onTap: () => Navigator.pop(ctx)),
        ]),
      ),
    );
    if (choice == null) return;
    XFile? file;
    if (choice == 'image') {
      file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    } else {
      file = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
    }
    if (file == null) return;
    final captionCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publicar estado'),
        content: TextField(controller: captionCtrl, maxLength: 200, decoration: const InputDecoration(hintText: 'Texto opcional', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Publicar')),
        ],
      ),
    );
    final caption = captionCtrl.text.trim();
    captionCtrl.dispose();
    if (ok != true) return;
    if (!widget.supabaseReady || widget.isDemo || !Constants.hasSupabaseCredentials) {
      widget.onToast('Estado demo añadido (sin servidor)');
      setState(() {
        final me = _groups.where((g) => g.isMe).cast<_StoryGroup?>().firstWhere((g) => true, orElse: () => null);
        me?.items.insert(0, _StoryItem(id: 'local', mediaUrl: file!.path, mediaType: choice, caption: caption));
      });
      return;
    }
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) throw Exception('Sin sesión');
      final ext = file.name.split('.').last.toLowerCase();
      final path = '$uid/${const Uuid().v4()}.$ext';
      final bytes = await file.readAsBytes();
      await client.storage.from('stories').uploadBinary(
        path, bytes,
        fileOptions: FileOptions(contentType: file.mimeType ?? (choice == 'video' ? 'video/mp4' : 'image/jpeg'), upsert: true),
      );
      final url = client.storage.from('stories').getPublicUrl(path);
      await client.from('stories').insert({
        'user_id': uid,
        'media_url': url,
        'media_type': choice,
        'caption': caption,
        if (choice == 'video') 'duration_seconds': 15,
      });
      widget.onToast('Estado publicado (24 h)');
      await _load();
    } catch (e) {
      widget.onToast('No se pudo publicar el estado: $e');
    }
  }

  void _open(_StoryGroup group) {
    if (group.isMe && group.items.isEmpty) { _publish(); return; }
    if (group.items.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        child: SizedBox(
          height: 420,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Text(group.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Expanded(
              child: Center(
                child: group.items.first.mediaType == 'video'
                    ? const Icon(Icons.play_circle_fill, color: Colors.white, size: 64)
                    : const Icon(Icons.image, color: Colors.white70, size: 64),
              ),
            ),
            if (group.items.first.caption.isNotEmpty)
              Padding(padding: const EdgeInsets.all(12), child: Text(group.items.first.caption, style: const TextStyle(color: Colors.white))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox(height: 96, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final g = _groups[i];
          final has = g.items.isNotEmpty;
          return GestureDetector(
            onTap: () => _open(g),
            onLongPress: g.isMe ? _publish : null,
            child: SizedBox(
              width: 72,
              child: Column(children: [
                Container(
                  width: 62, height: 62, padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: has ? const LinearGradient(colors: [Color(0xFF8B7CF6), Color(0xFFFF9C70)]) : null,
                    border: has ? null : Border.all(color: Theme.of(context).dividerColor, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: g.isMe && !has ? const Icon(Icons.add) : Text(g.name.isNotEmpty ? g.name[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _StoryGroup {
  _StoryGroup({required this.userId, required this.name, required this.isMe, required this.items});
  final String userId, name;
  final bool isMe;
  final List<_StoryItem> items;
}

class _StoryItem {
  _StoryItem({required this.id, required this.mediaUrl, required this.mediaType, required this.caption});
  final String id, mediaUrl, mediaType, caption;
}
