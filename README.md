# Nexora

**Tu espacio. Tus reglas.**

Nexora es una comunidad para compartir publicaciones y proyectos, conversar y descubrir juegos. Combina personalización avanzada, descargas controladas por el autor, chat y panel de administración.

## Plataformas soportadas

| Plataforma | Cómo usarla |
|------------|-------------|
| **Web / PWA** (recomendado ahora) | Abre la versión web en cualquier navegador. En iPhone, Android, tablet y Windows se puede **instalar como app** (Añadir a pantalla de inicio). |
| **Android** | `flutter build apk` o `appbundle` |
| **iPhone / iPad** | `flutter build ipa` (requiere Mac + cuenta Apple) |
| **Windows** | `flutter build windows` |
| **Tablet** | Funciona tanto en la PWA como en las builds nativas (Flutter es responsive) |

La app necesita internet (Supabase) para autenticación, datos reales y chat.

## Administradores (solo con Gmail / email autorizado)

Los administradores **no** se eligen desde la app. Tú los defines en Supabase:

```sql
-- Después de que el admin se registre con su Gmail:
update public.profiles
set role = 'admin'
where id = (select id from auth.users where email = 'tu-admin@gmail.com');
```

- Solo las cuentas con `role = 'admin'` ven la pestaña **Admin**.
- Los usuarios normales **nunca** ven funciones de administración (ni la pestaña, ni botones de ban, reportes de moderación, etc.).
- Puedes tener los administradores que quieras (recomendado 2–3).
- Funciona con cualquier email; Gmail es el más habitual.

## Generar APK (Android)

```bash
flutter pub get
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

Para Windows: `flutter build windows`  
Para iOS: `flutter build ipa` (requiere Mac).

## Analítica

La pantalla de Analítica muestra métricas de actividad. Cuando Supabase está configurado y hay datos reales, las consultas se preparan para leer likes, publicaciones y reportes. En modo demo usa valores de ejemplo.

## Versión web lista

1. En Supabase → SQL Editor: ejecuta `supabase/schema.sql` y luego `supabase/schema_v2.sql`.
2. Pega tu **URL** y clave **pública anon** en `web/config.js`.
3. Activa GitHub Pages (Settings → Pages → Source: GitHub Actions).
4. Para ser admin usa el SQL de arriba con tu Gmail.

## Flutter (Android, iOS, Windows, tablet)

```sh
flutter pub get
flutter run
```

Configura `lib/core/constants.dart` con tu URL y clave anon de Supabase.

**Estado:** la navegación y el rol de administrador ya están conectados a la base de datos. El feed, chat y juegos todavía muestran datos de demostración hasta completar las consultas a Supabase.

## Funciones incluidas

- Personalización de colores, tema claro/oscuro
- Publicaciones + me gusta / guardar / reportar
- Biblioteca de juegos con aprobación de administrador
- Chat (demo)
- Analítica
- **Panel de administración** (solo visible si `role = 'admin'`): banear usuarios, banear IPs, reportes, aprobar juegos
- Esquema SQL + RLS + RPCs de moderación

## Importante

- Nunca pongas la clave `service_role` en el cliente.
- El ban de IP se registra en la base de datos; el bloqueo real en el borde de la red requiere una Edge Function o WAF.

---

Desarrollado para una red social más libre.
