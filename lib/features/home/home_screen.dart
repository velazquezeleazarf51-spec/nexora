import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../../core/providers/profile_provider.dart';
import '../../theme/theme_provider.dart';
import '../auth/presentation/login_screen.dart';

class FeedPost {
  FeedPost({
    required this.author,
    required this.handle,
    required this.time,
    required this.text,
    required this.tag,
    required this.color,
    required this.likes,
    this.id,
    this.liked = false,
    this.saved = false,
    this.remote = false,
  });
  final String? id;
  final String author, handle, time, text, tag;
  final Color color;
  int likes;
  bool liked, saved;
  final bool remote;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.supabaseReady = true,
    this.isDemo = false,
    this.displayName = 'Usuario',
  });
  final bool supabaseReady;
  final bool isDemo;
  final String displayName;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;
  bool _loadingFeed = false;
  int _likesCount = 0, _postsCount = 0, _savesCount = 0, _reportsCount = 0;
  bool _analyticsFromServer = false;
  late List<FeedPost> _posts;

  static const _base = [
    _Dest('Inicio', Icons.home_rounded, Icons.home_outlined),
    _Dest('Juegos', Icons.sports_esports_rounded, Icons.sports_esports_outlined),
    _Dest('Chat', Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded),
    _Dest('Analítica', Icons.insights_rounded, Icons.insights_outlined),
  ];
  static const _adminDest = _Dest('Admin', Icons.admin_panel_settings_rounded, Icons.admin_panel_settings_outlined);

  @override
  void initState() {
    super.initState();
    _posts = _demoPosts();
    if (widget.supabaseReady && !widget.isDemo) {
      _loadFeed();
      _loadAnalytics();
    }
  }

  List<FeedPost> _demoPosts() => [
        FeedPost(author: 'Sofía Martínez', handle: '@sofia.crea', time: 'hace 12 min', text: 'Hoy terminé una ilustración. Crear sin prisa también es avanzar.', tag: 'Ilustración', color: const Color(0xFF8B7CF6), likes: 28),
        FeedPost(author: 'Leo Vargas', handle: '@leo_juega', time: 'hace 38 min', text: 'Minijuego de plataformas listo. ¿Feedback?', tag: 'Proyecto', color: const Color(0xFF29B6A5), likes: 16),
        FeedPost(author: 'Mara Ríos', handle: '@mararios', time: 'hace 1 h', text: 'Tu espacio creativo no tiene que parecerse al de nadie más.', tag: 'Comunidad', color: const Color(0xFFFF9C70), likes: 43),
      ];

  void _toast(String m) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authProvider.notifier).signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  Future<void> _loadFeed() async {
    if (!Constants.hasSupabaseCredentials) return;
    setState(() => _loadingFeed = true);
    try {
      final rows = await Supabase.instance.client
          .from('posts')
          .select('id, content, likes_count, created_at, media_type, profiles(display_name, username)')
          .eq('is_approved', true)
          .order('created_at', ascending: false)
          .limit(40);
      final list = <FeedPost>[];
      for (final r in (rows as List)) {
        final p = r['profiles'] as Map<String, dynamic>?;
        list.add(FeedPost(
          id: r['id'] as String?,
          author: p?['display_name'] as String? ?? 'Usuario',
          handle: '@${p?['username'] ?? 'user'}',
          time: _ago(r['created_at'] as String?),
          text: (r['content'] as String?) ?? '',
          tag: (r['media_type'] as String?) ?? 'Texto',
          color: const Color(0xFF8B7CF6),
          likes: (r['likes_count'] as int?) ?? 0,
          remote: true,
        ));
      }
      if (mounted) setState(() { if (list.isNotEmpty) _posts = list; _loadingFeed = false; });
    } catch (e) {
      debugPrint('Feed: $e');
      if (mounted) setState(() => _loadingFeed = false);
    }
  }

  Future<void> _loadAnalytics() async {
    if (!Constants.hasSupabaseCredentials) return;
    try {
      final c = Supabase.instance.client;
      final uid = c.auth.currentUser?.id;
      if (uid == null) return;
      final posts = await c.from('posts').select('id').eq('user_id', uid);
      final likes = await c.from('likes').select('id').eq('user_id', uid);
      final saves = await c.from('saves').select('id').eq('user_id', uid);
      int reports = 0;
      try {
        final rep = await c.from('reports').select('id').eq('status', 'pending');
        reports = (rep as List).length;
      } catch (_) {}
      if (mounted) {
        setState(() {
          _postsCount = (posts as List).length;
          _likesCount = (likes as List).length;
          _savesCount = (saves as List).length;
          _reportsCount = reports;
          _analyticsFromServer = true;
        });
      }
    } catch (e) {
      debugPrint('Analytics: $e');
    }
  }

  String _ago(String? iso) {
    if (iso == null) return '';
    try {
      final m = DateTime.now().difference(DateTime.parse(iso)).inMinutes;
      if (m < 1) return 'ahora';
      if (m < 60) return 'hace $m min';
      if (m < 1440) return 'hace ${m ~/ 60} h';
      return 'hace ${m ~/ 1440} d';
    } catch (_) {
      return '';
    }
  }

  Future<void> _compose() async {
    final ctrl = TextEditingController();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Nueva publicación', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: ctrl, maxLines: 4, maxLength: 1000, decoration: const InputDecoration(hintText: '¿Qué quieres compartir?', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), icon: const Icon(Icons.send_rounded), label: const Text('Publicar')),
        ]),
      ),
    );
    ctrl.dispose();
    if (text == null || text.isEmpty) return;

    if (widget.supabaseReady && !widget.isDemo && Constants.hasSupabaseCredentials) {
      try {
        final uid = Supabase.instance.client.auth.currentUser?.id;
        if (uid != null) {
          await Supabase.instance.client.from('posts').insert({'user_id': uid, 'content': text, 'is_approved': true});
          _toast('Publicación guardada');
          await _loadFeed();
          await _loadAnalytics();
          return;
        }
      } catch (e) {
        _toast('No se pudo guardar: $e');
      }
    }
    setState(() {
      _posts.insert(0, FeedPost(author: widget.displayName, handle: '@user', time: 'ahora', text: text, tag: 'Nuevo', color: Theme.of(context).colorScheme.primary, likes: 0));
      _index = 0;
    });
    _toast('Publicación creada en esta sesión');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = ref.watch(authProvider).isAdmin;
    final dests = [..._base, if (isAdmin) _adminDest];
    if (_index >= dests.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _index = 0); });
    }
    final i = _index.clamp(0, dests.length - 1);
    final page = switch (i) {
      0 => _feed(),
      1 => _games(),
      2 => _chat(),
      3 => _analytics(),
      4 when isAdmin => _admin(),
      _ => _feed(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.hub_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('nexora', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4)),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
            ),
          ],
        ]),
        actions: [
          IconButton(tooltip: 'Tema', onPressed: ref.read(themeProvider.notifier).toggleDarkMode, icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined)),
          IconButton(tooltip: 'Salir', onPressed: _signOut, icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: Column(children: [
        if (widget.isDemo || !widget.supabaseReady)
          Material(
            color: theme.colorScheme.primaryContainer.withOpacity(0.35),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [Icon(Icons.info_outline, size: 18), SizedBox(width: 8), Expanded(child: Text('Modo demo · conecta Supabase para datos reales', style: TextStyle(fontSize: 13)))]),
            ),
          ),
        Expanded(child: page),
      ]),
      floatingActionButton: i == 0 ? FloatingActionButton.extended(onPressed: _compose, icon: const Icon(Icons.add), label: const Text('Crear')) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: [for (final d in dests) NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selected), label: d.label)],
      ),
    );
  }

  Widget _feed() {
    if (_loadingFeed) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: () async { await _loadFeed(); await _loadAnalytics(); },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
        itemCount: _posts.length + 1,
        itemBuilder: (_, idx) {
          if (idx == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tu comunidad', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                Text('Ideas, proyectos y personas.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ]),
            );
          }
          final post = _posts[idx - 1];
          return _PostCard(
            post: post,
            onLike: () async {
              setState(() { post.liked = !post.liked; post.likes += post.liked ? 1 : -1; });
              if (post.remote && post.id != null && Constants.hasSupabaseCredentials) {
                try {
                  final c = Supabase.instance.client;
                  final uid = c.auth.currentUser?.id;
                  if (uid == null) return;
                  if (post.liked) {
                    await c.from('likes').insert({'user_id': uid, 'post_id': post.id});
                  } else {
                    await c.from('likes').delete().eq('user_id', uid).eq('post_id', post.id!);
                  }
                } catch (_) {}
              }
            },
            onSave: () => setState(() => post.saved = !post.saved),
            onReport: () => _toast('Reporte registrado'),
          );
        },
      ),
    );
  }

  Widget _analytics() {
    final src = _analyticsFromServer ? 'Datos de tu cuenta (Supabase)' : 'Datos de ejemplo';
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      _Header('Tu actividad', src),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Expanded(child: _Metric(Icons.favorite_outline, 'Me gusta', '$_likesCount', const Color(0xFFEA7891))),
          const SizedBox(width: 10),
          Expanded(child: _Metric(Icons.article_outlined, 'Publicaciones', '$_postsCount', const Color(0xFF7281EB))),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(children: [
          Expanded(child: _Metric(Icons.bookmark_border, 'Guardados', '$_savesCount', const Color(0xFFE6A044))),
          const SizedBox(width: 10),
          Expanded(child: _Metric(Icons.flag_outlined, 'Reportes', '$_reportsCount', const Color(0xFF35A98D))),
        ]),
      ),
      Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_analyticsFromServer ? 'Métricas cargadas desde Supabase.' : 'Inicia sesión con Supabase para ver números reales.'),
        ),
      ),
    ]);
  }

  Widget _admin() {
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      const _Header('Administración', 'Solo cuentas con role=admin (tu Gmail en Supabase). Los usuarios no ven este panel.'),
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Moderación', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Reportes pendientes: $_reportsCount'),
            const SizedBox(height: 4),
            const Text('Banear usuarios, IPs, aprobar juegos. RPC: admin_set_user_banned, admin_ban_ip.'),
          ]),
        ),
      ),
      ListTile(leading: const Icon(Icons.people_outline), title: const Text('Usuarios y bans'), onTap: () => _toast('RPC admin_set_user_banned')),
      ListTile(leading: const Icon(Icons.block), title: const Text('IPs baneadas'), onTap: () => _toast('Tabla banned_ips + admin_ban_ip')),
      ListTile(leading: const Icon(Icons.sports_esports_outlined), title: const Text('Juegos pendientes'), onTap: () => _toast('Cola is_approved = false')),
    ]);
  }

  Widget _games() => ListView(padding: const EdgeInsets.all(16), children: [
        Text('Juegos', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Oficiales y de la comunidad (aprobados por admin).'),
        const SizedBox(height: 12),
        for (final g in [('Laberinto Neón', 'Equipo Nexora'), ('Memoria Cósmica', 'Equipo Nexora')])
          Card(child: ListTile(leading: const Icon(Icons.sports_esports_rounded), title: Text(g.$1, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(g.$2), trailing: const Icon(Icons.play_arrow_rounded))),
      ]);

  Widget _chat() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('Chat privado', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Se conectará a Supabase Realtime.', textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _Dest {
  const _Dest(this.label, this.selected, this.icon);
  final String label;
  final IconData selected, icon;
}

class _Header extends StatelessWidget {
  const _Header(this.title, this.subtitle);
  final String title, subtitle;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurface.withOpacity(0.6))),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.label, this.value, this.color);
  final IconData icon;
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65))),
        ]),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onLike, required this.onSave, required this.onReport});
  final FeedPost post;
  final VoidCallback onLike, onSave, onReport;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: post.color.withOpacity(0.2), child: Text(post.author.isNotEmpty ? post.author[0].toUpperCase() : '?', style: TextStyle(color: post.color, fontWeight: FontWeight.w700))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.author, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${post.handle} · ${post.time}', style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurface.withOpacity(0.55))),
            ])),
            Chip(label: Text(post.tag, style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact),
          ]),
          const SizedBox(height: 12),
          Text(post.text, style: t.textTheme.bodyLarge?.copyWith(height: 1.35)),
          const SizedBox(height: 8),
          Row(children: [
            IconButton(onPressed: onLike, icon: Icon(post.liked ? Icons.favorite : Icons.favorite_border, color: post.liked ? Colors.redAccent : null)),
            Text('${post.likes}'),
            IconButton(onPressed: onSave, icon: Icon(post.saved ? Icons.bookmark : Icons.bookmark_border)),
            const Spacer(),
            IconButton(onPressed: onReport, icon: const Icon(Icons.flag_outlined), tooltip: 'Reportar'),
          ]),
        ]),
      ),
    );
  }
}
