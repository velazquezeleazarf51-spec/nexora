-- Nexora v4 · Estados (stories) + chat con imagen/video
-- Ejecutar después de schema.sql, schema_v2.sql, schema_v3.sql

create table if not exists public.stories (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  media_url text not null,
  media_type text not null check (media_type in ('image', 'video')),
  caption text not null default '' check (char_length(caption) <= 200),
  duration_seconds int check (duration_seconds is null or duration_seconds between 1 and 60),
  allow_download boolean not null default false,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '24 hours')
);

create index if not exists stories_user_idx on public.stories(user_id, created_at desc);
create index if not exists stories_expires_idx on public.stories(expires_at);

create table if not exists public.story_views (
  story_id uuid not null references public.stories(id) on delete cascade,
  viewer_id uuid not null references public.profiles(id) on delete cascade,
  viewed_at timestamptz not null default now(),
  primary key (story_id, viewer_id)
);

alter table public.stories enable row level security;
alter table public.story_views enable row level security;

drop policy if exists "Estados vigentes visibles" on public.stories;
create policy "Estados vigentes visibles" on public.stories
  for select using (expires_at > now() or auth.uid() = user_id or public.is_admin());

drop policy if exists "Usuario crea su estado" on public.stories;
create policy "Usuario crea su estado" on public.stories
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Usuario borra su estado" on public.stories;
create policy "Usuario borra su estado" on public.stories
  for delete to authenticated using (auth.uid() = user_id or public.is_admin());

drop policy if exists "Vistas de estados" on public.story_views;
create policy "Vistas de estados" on public.story_views for select using (true);
drop policy if exists "Registrar vista estado" on public.story_views;
create policy "Registrar vista estado" on public.story_views
  for insert to authenticated with check (auth.uid() = viewer_id);

alter table public.messages add column if not exists media_url text;
alter table public.messages add column if not exists media_type text
  check (media_type is null or media_type in ('image', 'video', 'audio', 'file'));
alter table public.messages add column if not exists media_name text;
do $$ begin
  alter table public.messages alter column content drop not null;
exception when others then null;
end $$;
do $$ begin
  alter table public.messages add constraint messages_content_or_media
    check (coalesce(content, '') <> '' or media_url is not null);
exception when duplicate_object then null;
end $$;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'stories', 'stories', true, 52428800,
  array['image/png','image/jpeg','image/webp','image/gif','video/mp4','video/webm']
)
on conflict (id) do update set
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "stories lectura" on storage.objects;
create policy "stories lectura" on storage.objects for select using (bucket_id = 'stories');
drop policy if exists "stories subir propio" on storage.objects;
create policy "stories subir propio" on storage.objects for insert to authenticated
  with check (bucket_id = 'stories' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "stories borrar propio" on storage.objects;
create policy "stories borrar propio" on storage.objects for delete to authenticated
  using (bucket_id = 'stories' and (storage.foldername(name))[1] = auth.uid()::text);

create or replace function public.cleanup_expired_stories()
returns void language sql security definer set search_path = public as $$
  delete from public.stories where expires_at < now() - interval '1 day';
$$;
grant execute on function public.cleanup_expired_stories() to authenticated;
