# Nexora v3 — Videos, hashtags, descarga, secciones y juegos

## 1. SQL
En Supabase SQL Editor ejecuta en orden:
1. `supabase/schema.sql`
2. `supabase/schema_v2.sql`
3. `supabase/schema_v3.sql`

## 2. HomeScreen completo
Si `lib/features/home/home_screen.dart` es un placeholder:
```bash
cd lib/features/home
python3 decode_home_screen.py
```
O descarga el zip `nexora-home-v3.zip` y copia `home_screen.dart`.

## 3. Funciones nuevas

| Función | Dónde |
|---------|--------|
| Video máx 24 min | Botón Crear |
| Switch Permitir descarga | Botón Crear |
| Botón Descargar | Solo si el autor lo permite |
| #Hashtags | En el texto o campo extra; menú lateral |
| Secciones extra | Solo admin, menú lateral |
| Subir juego | Pestaña Juegos → Subir juego |

## 4. APK
```bash
flutter pub get
flutter build apk --release
```
