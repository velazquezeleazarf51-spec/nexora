# Nexora

**Red social más libre**

Nexora es una red social que combina lo mejor de Instagram, X (Twitter) y WhatsApp, con un enfoque en la libertad del usuario, personalización avanzada y control sobre el contenido.

## Características principales (MVP)

- Registro e inicio de sesión
- Perfil de usuario (foto, nombre, bio)
- **Personalización avanzada de colores** (tema completo de la app)
- Publicaciones: imágenes y videos (hasta 24 minutos)
- Interacciones: Me gusta, Repost, Guardar
- **Descarga de contenido** solo si el creador de la publicación lo aprueba
- Seguir usuarios
- Chat privado 1 a 1
- Panel de administración (3 administradores)
- Enlace a Discord para sugerencias de la comunidad

## Características especiales

- El usuario puede personalizar profundamente los colores de la interfaz.
- Opción de camuflaje (cambio de icono y nombre de la app en el dispositivo) — sujeto a limitaciones de Android/iOS.
- Dentro de la app siempre se muestra el logo y nombre oficial de **Nexora**.
- Descarga de publicaciones controlada por el autor.

## Stack tecnológico

- **Frontend**: Flutter (Android, iOS y Web)
- **Backend**: Supabase (Auth, Database, Storage, Realtime)
- **Almacenamiento local**: Shared Preferences + Hive (preferencias, tema, cookies locales)
- **Estado**: Riverpod o Provider

## Estructura del proyecto

```
nexora/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   ├── feed/
│   │   ├── profile/
│   │   ├── chat/
│   │   ├── post/
│   │   └── admin/
│   ├── shared/
│   └── theme/
├── assets/
├── supabase/
└── docs/
```

## Política de privacidad
Ver archivo [PRIVACY_POLICY.md](PRIVACY_POLICY.md)

## Administradores
La aplicación está diseñada para soportar 3 administradores con acceso al panel de moderación y gestión de contenido.

---

Desarrollado para una red social más libre.
