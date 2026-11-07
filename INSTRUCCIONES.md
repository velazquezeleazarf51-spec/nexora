# Nexora · guía rápida

La carpeta contiene el prototipo Flutter y un esquema inicial de Supabase. El feed, chat, juegos, panel administrativo y analíticas muestran ejemplos; todavía no guardan datos reales en el servidor.

## Explorar sin configurar servicios

1. Instala Flutter: <https://docs.flutter.dev/get-started/install>.
2. Desde la carpeta del proyecto, ejecuta `flutter pub get` y luego `flutter run`.
3. En la pantalla de acceso, pulsa **Continuar en modo demo** para explorar las secciones.

## Activar autenticación con Supabase

1. Crea un proyecto de prueba en <https://supabase.com>.
2. En `lib/core/constants.dart`, sustituye `supabaseUrl` y `supabaseAnonKey` por la URL del proyecto y su clave pública anon/publishable.
3. Ejecuta `supabase/schema.sql` (y después `schema_v2.sql`) en el SQL Editor de una base de datos nueva.
4. Arranca con `flutter pub get` y `flutter run`.

Nunca incluyas una clave `service_role` en una app móvil. El esquema es un punto de partida para pruebas: antes de usar datos reales, revisa y prueba RLS con cuentas de usuario y administrador separadas.

## Funciones representadas

Publicaciones y formatos previstos (imagen, video, PDF y juego), me gusta, guardados y reportes; juegos enviados por usuarios y aprobación administrativa; chat privado; gráficas de actividad y panel de moderación ampliado (ban usuarios e IPs).

La subida de medios, el feed, las conversaciones, las métricas y las acciones administrativas todavía requieren integración completa con Supabase/Storage/Realtime y pruebas de seguridad. Consulta `README.md` para las siguientes etapas recomendadas.

## Links útiles

- Flutter: <https://docs.flutter.dev>
- Supabase: <https://supabase.com>
- Documentación Supabase: <https://supabase.com/docs>
