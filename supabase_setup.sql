-- ============================================================================
-- Choco Blast Adventure — Supabase setup
-- Run this whole script in the Supabase SQL Editor (Dashboard -> SQL -> New query).
-- It creates the schema, Row Level Security policies, the leaderboard view,
-- and seeds 12 sample levels of increasing difficulty.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. PROFILES (extends auth.users)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  avatar_url text,
  total_score bigint default 0,
  current_level int default 1,
  lives int default 5,
  last_life_regen timestamptz default now(),
  is_premium boolean default false,
  created_at timestamptz default now()
);

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'Player_' || substr(new.id::text, 1, 6))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 2. LEVELS
-- ---------------------------------------------------------------------------
create table if not exists public.levels (
  id serial primary key,
  level_number int unique not null,
  grid_size int default 8,
  move_limit int,
  time_limit_seconds int,
  goal_type text not null check (goal_type in ('score','collect','jelly','ingredient')),
  goal_target jsonb not null,
  star_thresholds jsonb not null
);

-- ---------------------------------------------------------------------------
-- 3. USER PROGRESS
-- ---------------------------------------------------------------------------
create table if not exists public.user_progress (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  level_id int references public.levels(id) on delete cascade not null,
  stars int default 0,
  best_score int default 0,
  completed boolean default false,
  updated_at timestamptz default now(),
  unique(user_id, level_id)
);

-- ---------------------------------------------------------------------------
-- 4. LEADERBOARD VIEW
-- ---------------------------------------------------------------------------
drop view if exists public.leaderboard;
create view public.leaderboard as
  select id, username, avatar_url, total_score
  from public.profiles
  order by total_score desc
  limit 100;

-- ---------------------------------------------------------------------------
-- 5. ROW LEVEL SECURITY
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.levels enable row level security;
alter table public.user_progress enable row level security;

-- profiles: anyone can read; a user can only update their own row.
drop policy if exists "profiles_read_all" on public.profiles;
create policy "profiles_read_all" on public.profiles
  for select using (true);

drop policy if exists "profiles_update_self" on public.profiles;
create policy "profiles_update_self" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "profiles_insert_self" on public.profiles;
create policy "profiles_insert_self" on public.profiles
  for insert with check (auth.uid() = id);

-- levels: public read-only.
drop policy if exists "levels_read_public" on public.levels;
create policy "levels_read_public" on public.levels
  for select using (true);

-- user_progress: a user can read/write only their own rows.
drop policy if exists "progress_read_self" on public.user_progress;
create policy "progress_read_self" on public.user_progress
  for select using (auth.uid() = user_id);

drop policy if exists "progress_write_self" on public.user_progress;
create policy "progress_write_self" on public.user_progress
  for insert with check (auth.uid() = user_id);

drop policy if exists "progress_update_self" on public.user_progress;
create policy "progress_update_self" on public.user_progress
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 6. SEED LEVELS (12 levels, increasing difficulty)
-- ---------------------------------------------------------------------------
insert into public.levels (level_number, grid_size, move_limit, time_limit_seconds, goal_type, goal_target, star_thresholds)
values
  (1, 8, 20, null, 'score',       '{"score": 1000}',                          '{"1":1000,"2":2000,"3":3500}'),
  (2, 8, 18, null, 'score',       '{"score": 2000}',                          '{"1":2000,"2":3500,"3":5000}'),
  (3, 8, 18, null, 'collect',     '{"color":"red","count":15}',               '{"1":2000,"2":3500,"3":5000}'),
  (4, 8, 16, null, 'collect',     '{"color":"blue","count":20}',              '{"1":2500,"2":4000,"3":6000}'),
  (5, 8, 16, null, 'score',       '{"score": 4000}',                          '{"1":4000,"2":6000,"3":8500}'),
  (6, 8, 15, null, 'collect',     '{"color":"green","count":25}',             '{"1":3000,"2":5000,"3":7500}'),
  (7, 8, 14, null, 'score',       '{"score": 6000}',                          '{"1":6000,"2":9000,"3":12000}'),
  (8, 8, null, 90,  'score',      '{"score": 5000}',                          '{"1":5000,"2":8000,"3":11000}'),
  (9, 8, 14, null, 'collect',     '{"color":"purple","count":30}',            '{"1":4000,"2":7000,"3":10000}'),
  (10, 8, null, 75, 'score',      '{"score": 8000}',                          '{"1":8000,"2":12000,"3":16000}'),
  (11, 8, 12, null, 'collect',    '{"color":"orange","count":35}',            '{"1":5000,"2":8500,"3":12000}'),
  (12, 8, null, 60, 'score',      '{"score": 12000}',                         '{"1":12000,"2":18000,"3":25000}')
on conflict (level_number) do nothing;
