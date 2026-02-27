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