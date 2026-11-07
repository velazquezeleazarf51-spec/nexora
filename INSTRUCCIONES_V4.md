# Nexora v4 — Estados + Chat multimedia

## SQL
Ejecuta `supabase/schema_v4.sql` después de v1–v3.

## Archivos Flutter nuevos
- `lib/features/stories/stories_strip.dart` — fila de estados + publicar
- `lib/features/chat/chat_media_page.dart` — chat con imagen/video

Copia también el `home_screen.dart` actualizado del zip de la conversación (conecta estados arriba del feed y el chat nuevo).

## Uso
1. Feed → círculos de estados (toca “Tu estado” para publicar foto/video)
2. Chat → clip 📎 para imagen o video, luego enviar
3. Publicaciones del feed siguen como X + video largo (24 min)
