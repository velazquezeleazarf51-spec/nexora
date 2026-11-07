-- Nexora v3 · hashtags, secciones admin, videos y juegos de usuarios
-- Ejecutar después de schema.sql y schema_v2.sql

alter table public.posts add column if not exists duration_seconds int;
alter table public.posts add column if not exists hashtags text[] not null default '{}';

create table if not exists public.hashtags (
  id uuid primary key default uuid_generate_v4(),
  tag text not null unique check (tag ~ '^[a-z0-9_]{1,40}$'),
  posts_count int not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists hashtags_tag_idx on public.hashtags(tag);
create index if not exists hashtags_count_idx on public.hashtags(posts_count desc);

create table if not exists public.post_hashtags (
  post_id uuid references public.posts(id) on delete cascade,
  hashtag_id uuid references public.hashtags(id) on delete cascade,
  primary key (post_id, hashtag_id)
);

create table if not exists public.app_sections (
  id uuid primary key default uuid_generate_v4(),
  title text not null check (char_length(title) between 1 and 60),
  description text not null default '' check (char_length(description) <= 300),
  icon text not null default 'apps',
  route_key text not null unique check (char_length(route_key) between 1 and 40),
  is_visible boolean not null default true,
  sort_order int not null default 100,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.app_sections enable row level security;
drop policy if exists "Secciones visibles para todos" on public.app_sections;
create policy "Secciones visibles para todos" on public.app_sections
  for select using (is_visible = true or public.is_admin());
drop policy if exists "Admin gestiona secciones" on public.app_sections;
create policy "Admin gestiona secciones" on public.app_sections
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

alter table public.games add column if not exists play_url text;
alter table public.games add column if not exists source_url text;
alter table public.games add column if not exists rejection_reason text;

alter table public.hashtags enable row level security;
alter table public.post_hashtags enable row level security;
drop policy if exists "Hashtags lectura" on public.hashtags;
create policy "Hashtags lectura" on public.hashtags for select using (true);
drop policy if exists "Auth inserta hashtags" on public.hashtags;
create policy "Auth inserta hashtags" on public.hashtags for insert to authenticated with check (true);
drop policy if exists "Post hashtags lectura" on public.post_hashtags;
create policy "Post hashtags lectura" on public.post_hashtags for select using (true);
drop policy if exists "Auth vincula hashtags" on public.post_hashtags;
create policy "Auth vincula hashtags" on public.post_hashtags for insert to authenticated with check (true);

create or replace function public.sync_post_hashtags(p_post_id uuid, p_tags text[])
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t text;
  hid uuid;
  clean text;
begin
  if auth.uid() is null then raise exception 'No autenticado'; end if;
  if not exists (select 1 from public.posts where id = p_post_id and user_id = auth.uid())
     and not public.is_admin() then
    raise exception 'No autorizado';
  end if;
  delete from public.post_hashtags where post_id = p_post_id;
  if p_tags is null then return; end if;
  foreach t in array p_tags loop
    clean := lower(regexp_replace(trim(both '#' from t), '[^a-z0-9_]', '', 'g'));
    if length(clean) < 1 or length(clean) > 40 then continue; end if;
    insert into public.hashtags (tag) values (clean)
    on conflict (tag) do update set tag = excluded.tag
    returning id into hid;
    if hid is null then select id into hid from public.hashtags where tag = clean; end if;
    insert into public.post_hashtags (post_id, hashtag_id) values (p_post_id, hid)
    on conflict do nothing;
  end loop;
  update public.hashtags h
  set posts_count = (select count(*) from public.post_hashtags ph where ph.hashtag_id = h.id)
  where h.id in (select hashtag_id from public.post_hashtags where post_id = p_post_id);
end;
$$;

grant execute on function public.sync_post_hashtags(uuid, text[]) to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('media', 'media', true, 104857600,
  array['image/png','image/jpeg','image/webp','image/gif','video/mp4','video/webm','application/pdf'])
on conflict (id) do update set
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Juegos aprobados visibles" on public.games;
create policy "Juegos aprobados visibles" on public.games
  for select using (is_approved = true or is_official = true or auth.uid() = created_by or public.is_admin());
drop policy if exists "Usuario envía juego" on public.games;
create policy "Usuario envía juego" on public.games
  for insert to authenticated with check (auth.uid() = created_by and is_official = false);
drop policy if exists "Admin actualiza juegos" on public.games;
create policy "Admin actualiza juegos" on public.games
  for update to authenticated using (public.is_admin() or auth.uid() = created_by);

insert into public.app_sections (title, description, icon, route_key, sort_order)
values
  ('Comunidad', 'Feed y publicaciones', 'home', 'home', 10),
  ('Juegos', 'Juegos oficiales y de la comunidad', 'games', 'games', 20),
  ('Chat', 'Mensajes privados', 'chat', 'chat', 30),
  ('Analítica', 'Tu actividad', 'insights', 'analytics', 40)
on conflict (route_key) do nothing;
