create extension if not exists pgcrypto;
create table if not exists public.student_profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    email text not null unique,
    full_name text,
    student_id text,
    faculty text,
    program text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index if not exists student_profiles_email_idx on public.student_profiles (email);
alter table public.student_profiles enable row level security;
create policy if not exists "users can read own profile" on public.student_profiles for
select to authenticated using (auth.uid() = id);
create policy if not exists "users can insert own profile" on public.student_profiles for
insert to authenticated with check (auth.uid() = id);
create policy if not exists "users can update own profile" on public.student_profiles for
update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create or replace function public.login_user(p_email text, p_password text) returns table (id text, full_name text, email text, role text) language plpgsql security definer
set search_path = public as $$ begin return query
select a.id::text,
    a.full_name,
    a.email,
    'admin'::text
from public.admins a
where lower(a.email) = lower(p_email)
    and a.password_hash = crypt(p_password, a.password_hash)
limit 1;
if found then return;
end if;
return query
select s.student_id::text,
    s.full_name,
    s.email,
    'student'::text
from public.students s
where lower(s.email) = lower(p_email)
    and s.password_hash = crypt(p_password, s.password_hash)
limit 1;
end;
$$;
grant execute on function public.login_user(text, text) to anon,
    authenticated;