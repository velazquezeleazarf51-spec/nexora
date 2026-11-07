# Videos, hashtags, descarga y juegos

## Crear publicación
- Texto + #hashtags
- Video opcional (máx. 24 minutos)
- Switch "Permitir descarga"

## Descarga
- Solo si `allow_download = true` en el post
- Botón descarga en la tarjeta del post

## Hashtags
- Se extraen del texto (`#tema`) y del campo extra
- Explorar desde el menú lateral
- Filtrar feed por tag

## Secciones (admin)
- Menú lateral (drawer)
- Admin: "Añadir sección" → tabla `app_sections`

## Juegos de usuarios
- En pestaña Juegos: botón "Subir juego"
- Se guarda con `is_approved = false`
- Admin aprueba cambiando `is_approved = true`

## SQL
Ejecutar `supabase/schema_v3.sql` después de v1 y v2.
