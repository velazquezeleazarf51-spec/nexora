import 'package:flutter/material. ste';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  final _pages = const [
    FeedPlaceholder(),
    ChatPlaceholder(),
    CreatePlaceholder(),
    ProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box_rounded),
            label: 'Crear',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Placeholders temporales
class FeedPlaceholder extends StatelessWidget {
  const FeedPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nexora')),
      body: const Center(child: Text('Feed de publicaciones\n(Próximamente)')),
    );
  }
}

class ChatPlaceholder extends StatelessWidget {
  const ChatPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(child: Text('Chat privado\n(Próximamente)')),
    );
  }
}

class CreatePlaceholder extends StatelessWidget {
  const CreatePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear publicación')),
      body: const Center(child: Text('Crear post / video / imagen\n(Próximamente)')),
    );
  }
}

class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(child: Text('Perfil + Personalización de colores\n(Próximamente)')),
    );
  }
}
