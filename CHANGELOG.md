# Cambios de Nexora 1.2.0

- Panel de administración ampliado: banear usuarios, gestionar lista de IPs baneadas, revisar reportes, ver proyectos y resumen de moderación.
- Nuevo esquema (schema_v2): tabla `banned_ips`, funciones RPC `admin_ban_ip` y `admin_unban_ip`.
- Notas de los bocetos manuscritos incorporadas (monitorización, aprobación de juegos, personalización ya presente).
- El ban de IP queda registrado para auditoría; el bloqueo real en el borde de red requiere Edge Function o WAF.

# Cambios de Nexora 1.1.0

- El inicio ya no falla cuando Supabase conserva las credenciales de ejemplo; ofrece una entrada al modo demo.
- Se añadió registro, recuperación de contraseña y mejores validaciones de formularios al conectar Supabase.
- Se corrigió el flujo de sesión para abrir el inicio de la app y permitir cerrar sesión.
- Se añadieron pantallas de feed, juegos, chat, analítica y panel administrativo de demostración basadas en el esquema manuscrito.
- Se añadieron acciones locales de me gusta, guardar, reportar, crear publicación y enviar juego a revisión.
- Se amplió el esquema SQL con reportes, revisión de juegos, RPCs protegidas y políticas RLS para conversaciones privadas.
- Se actualizaron README e instrucciones para aclarar qué partes son prototipo y qué trabajo requiere backend.

**Verificación:** el análisis sintáctico de Dart/YAML/SQL pasó. No se pudo ejecutar compilación, `flutter analyze` ni pruebas porque Flutter/Dart no están instalados en el entorno de trabajo.
