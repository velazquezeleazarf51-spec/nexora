# HomeScreen actualizado

El archivo completo `home_screen.dart` (con rol admin, feed Supabase y analítica real) está en el zip de esta conversación y en los artefactos.

Cambios principales:
- Pestaña Admin **solo** si `role = 'admin'` en profiles (Gmail autorizado por ti en SQL)
- Los usuarios normales **no ven** ninguna función de administración
- Feed intenta cargar posts reales de Supabase al iniciar sesión
- Analítica carga conteos reales (likes, posts, saves, reportes) desde Supabase
- Si no hay datos o falla la red, muestra demo

Copia `home_screen.dart` desde el zip `nexora-flutter-home.zip` a `lib/features/home/home_screen.dart`.
