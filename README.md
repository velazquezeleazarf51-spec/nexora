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

## Versión web lista (funciona ya en todos los dispositivos)

La carpeta `web/` es una PWA completa (HTML + CSS + JS, sin dependencias externas):

1. En Supabase → SQL Editor: ejecuta `supabase/schema.sql` y luego `supabase/schema_v2.sql`.
2. Pega tu **URL** y clave **pública anon** en `web/config.js`.
3. Activa GitHub Pages (Settings → Pages → Source: GitHub Actions). El workflow `.github/workflows/pages.yml` publica automáticamente la carpeta `web/`.
4. Para ser admin: `update public.profiles set role='admin' where username='tu_usuario';`

En móvil: desliza desde el borde izquierdo = menú, desde el derecho = Ajustes.

## Flutter (Android, iOS, Windows, tablet)

```sh
flutter pub get
flutter run          # dispositivo o emulador
flutter build apk    # Android
flutter build windows
flutter build ipa    # iOS (Mac)
```

Configura `lib/core/constants.dart` con tu URL y clave anon de Supabase.

**Estado actual del código Flutter:** prototipo navegable con modo demo. El feed, chat, juegos y panel usan datos de muestra hasta que se conecten las consultas reales a Supabase (Auth ya funciona cuando las claves están bien).

## Funciones incluidas

- Personalización de colores, tema claro/oscuro/AMOLED, fondos, redondeo, tamaño de texto
- Publicaciones (texto, imagen, video, PDF, juego) + me gusta / repost / guardar / reportar
- Descarga solo si el autor lo permite
- Biblioteca de juegos con aprobación de administrador
- Chat (demo)
- Analítica con gráficas
- **Panel de administración ampliado**: banear usuarios, banear IPs, reportes, aprobar juegos, ver proyectos
- Esquema SQL completo + RLS + RPCs de moderación (`admin_set_user_banned`, `admin_ban_ip`, `admin_unban_ip`)

## Importante

- Nunca pongas la clave `service_role` en el cliente.
- El ban de IP se registra en la base de datos; el bloqueo real en el borde de la red requiere una Edge Function o WAF.
- Revisa y prueba las políticas RLS en un proyecto de pruebas antes de datos reales.

## Próximos pasos recomendados

1. Conectar feed, likes, guardados, seguimientos y reportes a Supabase.
2. Subida de medios a Storage con validación.
3. Chat con Realtime.
4. Edge Function para aplicar ban de IP en el edge.
5. Builds nativas firmadas y publicación en stores.

---

Desarrollado para una red social más libre.
