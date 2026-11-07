-- Nexora v2 · ejecutar DESPUÉS de schema.sql (se puede repetir sin problema)
alter table public.profiles add column if not exists settings jsonb not null default '{}'::jsonb;
do $$ begin alter table public.profiles add constraint profiles_settings_size check (pg_column_size(settings) < 4096); exception when duplicate_object then null; end $$;
alter table public.games add column if not exists min_players int not null default 1 check (min_players between 1 and 50);
alter table public.games add column if not exists max_players int not null default 1 check (max_players between 1 and 50);
do $$ begin alter table public.games add constraint games_players_ok check (max_players >= min_players); exception when duplicate_object then null; end $$;

-- Un usuario no puede darse rol admin ni quitarse un baneo
create or replace function public.protect_profile_fields() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is not null
     and (new.role is distinct from old.role or new.is_banned is distinct from old.is_banned)
     and not exists (select 1 from public.profiles where id = auth.uid() and role = 'admin') then
    raise exception 'No autorizado';
  end if;
  return new;
end $$;
drop trigger if exists profiles_protect on public.profiles;
create trigger profiles_protect before update on public.profiles
  for each row execute function public.protect_profile_fields();

-- Almacenamiento de medios (10 MB, solo formatos permitidos, cada usuario en su carpeta)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('media', 'media', true, 10485760,
  array['image/png','image/jpeg','image/webp','image/gif','video/mp4','video/webm','application/pdf'])
on conflict (id) do update set file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;
drop policy if exists "media lectura" on storage.objects;
create policy "media lectura" on storage.objects for select using (bucket_id = 'media');
drop policy if exists "media subir propio" on storage.objects;
create policy "media subir propio" on storage.objects for insert to authenticated
  with check (bucket_id = 'media' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "media borrar propio" on storage.objects;
create policy "media borrar propio" on storage.objects for delete to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = auth.uid()::text);

-- -----------------------------------------------------------------------------
-- Moderación ampliada: ban de IP y más herramientas de administrador
-- -----------------------------------------------------------------------------
create table if not exists public.banned_ips (
  id uuid primary key default uuid_generate_v4(),
  ip_address text not null unique check (ip_address ~ '^[0-9a-fA-F.:]+$'),
  reason text not null default '' check (char_length(reason) <= 500),
  banned_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  expires_at timestamptz
);

create index if not exists banned_ips_addr_idx on public.banned_ips(ip_address);

alter table public.banned_ips enable row level security;
drop policy if exists "Admin gestiona IPs baneadas" on public.banned_ips;
create policy "Admin gestiona IPs baneadas" on public.banned_ips
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

create or replace function public.admin_ban_ip(p_ip text, p_reason text default '', p_days int default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Solo administradores pueden banear IPs.' using errcode = '42501';
  end if;
  if p_ip is null or length(trim(p_ip)) < 7 then
    raise exception 'IP no válida';
  end if;
  insert into public.banned_ips (ip_address, reason, banned_by, expires_at)
  values (
    trim(p_ip),
    coalesce(p_reason, ''),
    auth.uid(),
    case when p_days is not null and p_days > 0 then now() + (p_days || ' days')::interval else null end
  )
  on conflict (ip_address) do update set
    reason = excluded.reason,
    banned_by = excluded.banned_by,
    expires_at = excluded.expires_at,
    created_at = now();
end;
$$;

create or replace function public.admin_unban_ip(p_ip text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Solo administradores pueden desbanear IPs.' using errcode = '42501';
  end if;
  delete from public.banned_ips where ip_address = trim(p_ip);
end;
$$;

grant execute on function public.admin_ban_ip(text, text, int) to authenticated;
grant execute on function public.admin_unban_ip(text) to authenticated;

-- Nota: el bloqueo real de IP en el edge (antes de auth) requiere Edge Function
-- o WAF. Esta tabla sirve para auditoría y para que un middleware futuro consulte
-- las IPs bloqueadas. La app cliente no puede forzar el ban de IP por sí sola.
