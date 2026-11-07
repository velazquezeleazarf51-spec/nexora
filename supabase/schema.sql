-- ============================================================
-- NEXORA - Esquema de Base de Datos (Supabase / PostgreSQL)
-- ============================================================

-- Extensiones necesarias
create extension if not exists "uuid-ossp";

-- ============================================================
-- PERFILES DE USUARIO
-- ============================================================
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  display_name text,
  bio text,
  avatar_url text,
  role text default 'user' check (role in ('user', 'admin')),
  is_banned boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- PUBLICACIONES
-- ============================================================
create table public.posts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text,
  media_url text,
  media_type text check (media_type in ('image', 'video', 'pdf', 'animation', 'other')),
  thumbnail_url text,
  allow_download boolean default false,  -- Solo se puede descargar si el autor lo permite
  likes_count integer default 0,
  reposts_count integer default 0,
  saves_count integer default 0,
  is_approved boolean default true,      -- Para moderación de admins
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- INTERACCIONES
-- ============================================================
create table public.likes (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.posts(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(user_id, post_id)
);

create table public.reposts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.posts(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(user_id, post_id)
);

create table public.saves (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.posts(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(user_id, post_id)
);

-- ============================================================
-- SEGUIR USUARIOS
-- ============================================================
create table public.follows (
  id uuid default uuid_generate_v4() primary key,
  follower_id uuid references public.profiles(id) on delete cascade not null,
  following_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(follower_id, following_id)
);

-- ============================================================
-- CHAT
-- ============================================================
create table public.conversations (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamptz default now()
);

create table public.conversation_participants (
  conversation_id uuid references public.conversations(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  primary key (conversation_id, user_id)
);

create table public.messages (
  id uuid default uuid_generate_v4() primary key,
  conversation_id uuid references public.conversations(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  is_read boolean default false,
  created_at timestamptz default now()
);

-- ============================================================
-- JUEGOS (fase 2, pero tabla lista)
-- ============================================================
create table public.games (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text,
  cover_url text,
  game_url text,
  created_by uuid references public.profiles(id),
  is_official boolean default false,     -- true = puesto por admin
  is_approved boolean default false,     -- necesita aprobación si es de usuario
  created_at timestamptz default now()
);

-- ============================================================
-- ÍNDICES PARA RENDIMIENTO
-- ============================================================
create index posts_user_id_idx on public.posts(user_id);
create index posts_created_at_idx on public.posts(created_at desc);
create index likes_post_id_idx on public.likes(post_id);
create index follows_follower_id_idx on public.follows(follower_id);
create index follows_following_id_idx on public.follows(following_id);
create index messages_conversation_id_idx on public.messages(conversation_id);

-- ============================================================
-- RLS (Row Level Security) - Básico
-- ============================================================
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.likes enable row level security;
alter table public.reposts enable row level security;
alter table public.saves enable row level security;
alter table public.follows enable row level security;
alter table public.messages enable row level security;
alter table public.games enable row level security;

-- Políticas básicas
create policy "Perfiles públicos visibles" on public.profiles for select using (true);
create policy "Usuario puede editar su perfil" on public.profiles for update using (auth.uid() = id);

create policy "Posts aprobados visibles" on public.posts for select using (is_approved = true or auth.uid() = user_id);
create policy "Usuario puede crear posts" on public.posts for insert with check (auth.uid() = user_id);
create policy "Usuario puede editar sus posts" on public.posts for update using (auth.uid() = user_id);

-- Trigger para crear perfil automáticamente al registrarse
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8)),
    coalesce(new.raw_user_meta_data->>'display_name', 'Usuario')
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
