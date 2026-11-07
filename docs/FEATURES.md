# Características de Nexora — Documentación técnica

## 1. Personalización avanzada de colores

El usuario puede cambiar:
- Color primario
- Color secundario
- Color de fondo
- Color de superficies (cards, appbar, etc.)
- Color de texto

Los colores se guardan localmente con Hive y se aplican en tiempo real a toda la app.

Archivos relevantes:
- `lib/theme/app_theme.dart`
- `lib/theme/theme_provider.dart`

## 2. Descarga de contenido controlada

Regla importante:
> Solo se puede descargar una publicación si el **autor** de esa publicación ha activado la opción `allow_download = true`.

Campo en la tabla `posts`:
```sql
allow_download BOOLEAN DEFAULT false
```

En la UI:
- Si `allow_download == true` → se muestra el botón de descarga
- Si `allow_download == false` → el botón no aparece o está deshabilitado

## 3. Camuflaje de icono y nombre de la app

### Realidad técnica:

**Android:**
- Se puede crear un "Activity Alias" o usar iconos adaptativos + shortcuts.
- Cambiar el nombre e icono real del launcher es limitado y requiere reinicio o técnicas avanzadas (no siempre confiables en todos los dispositivos).
- Alternativa viable: modo "Disfraz" dentro de la app + crear un acceso directo con otro nombre/icono.

**iOS:**
- Apple no permite cambiar el icono ni el nombre de la app de forma dinámica de manera libre (solo iconos alternativos predefinidos en el bundle, y el nombre de la app es fijo).
- La única forma real es tener varios iconos alternativos declarados en el `Info.plist`.

**Decisión de diseño actual:**
- Dentro de la app **siempre** se muestra el logo y nombre oficial **Nexora**.
- Se implementará un sistema de "iconos alternativos" predefinidos (para Android e iOS) que el usuario puede elegir.
- El cambio completo de nombre + icono del launcher se documentará como "limitado por el sistema operativo".

## 4. Cookies / Almacenamiento local

Usamos:
- **Hive** → preferencias de tema y configuraciones
- **SharedPreferences** → flags simples y sesión auxiliar
- Supabase Auth maneja el token de sesión de forma segura

No se usan cookies de terceros para tracking.

## 5. Política de privacidad

Ver archivo raíz: `PRIVACY_POLICY.md`

## 6. Administradores

La app está preparada para 3 administradores.
Se manejará con un campo `role` en la tabla `profiles`:
- `user`
- `admin`

Solo los usuarios con `role = 'admin'` podrán acceder al panel de administración.
