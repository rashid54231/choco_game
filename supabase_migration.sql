-- ============================================================================
-- Choco Blast Adventure — Supabase Migration Script
-- Run this in the Supabase SQL Editor (Dashboard -> SQL Editor -> New query)
-- ============================================================================

-- 1. Update profiles table to add coins and booster counts
alter table public.profiles 
  add column if not exists coins bigint default 1000,
  add column if not exists booster_extra_moves int default 3,
  add column if not exists booster_color_bomb int default 2,
  add column if not exists booster_hammer int default 2,
  add column if not exists booster_shuffle int default 3,
  add column if not exists last_daily_reward timestamp with time zone;

-- 2. Seed remaining levels 13 to 30 with incremental difficulty
insert into public.levels (level_number, grid_size, move_limit, time_limit_seconds, goal_type, goal_target, star_thresholds)
values
  (13, 8, 18, null, 'score',       '{"score": 15000}',                         '{"1":15000,"2":22000,"3":30000}'),
  (14, 8, 16, null, 'collect',     '{"color":"blue","count":40}',              '{"1":6000,"2":10000,"3":15000}'),
  (15, 8, null, 80,  'score',      '{"score": 14000}',                         '{"1":14000,"2":20000,"3":28000}'),
  (16, 8, 18, null, 'collect',     '{"color":"yellow","count":30}',            '{"1":5000,"2":8000,"3":12000}'),
  (17, 8, 15, null, 'score',       '{"score": 18000}',                         '{"1":18000,"2":25000,"3":35000}'),
  (18, 8, null, 70,  'score',      '{"score": 16000}',                         '{"1":16000,"2":22000,"3":30000}'),
  (19, 8, 14, null, 'collect',     '{"color":"red","count":35}',               '{"1":6000,"2":9000,"3":13000}'),
  (20, 8, 20, null, 'score',       '{"score": 25000}',                         '{"1":25000,"2":35000,"3":50000}'),
  (21, 8, null, 90,  'collect',    '{"color":"green","count":45}',             '{"1":8000,"2":12000,"3":18000}'),
  (22, 8, 16, null, 'score',       '{"score": 22000}',                         '{"1":22000,"2":30000,"3":42000}'),
  (23, 8, 15, null, 'collect',     '{"color":"purple","count":38}',            '{"1":7000,"2":11000,"3":16000}'),
  (24, 8, null, 60,  'score',      '{"score": 20000}',                         '{"1":20000,"2":28000,"3":38000}'),
  (25, 8, 14, null, 'collect',     '{"color":"orange","count":40}',            '{"1":8000,"2":12000,"3":17000}'),
  (26, 8, 16, null, 'score',       '{"score": 28000}',                         '{"1":28000,"2":38000,"3":52000}'),
  (27, 8, null, 75,  'collect',    '{"color":"blue","count":45}',              '{"1":9000,"2":14000,"3":20000}'),
  (28, 8, 15, null, 'score',       '{"score": 30000}',                         '{"1":30000,"2":42000,"3":58000}'),
  (29, 8, 12, null, 'collect',     '{"color":"red","count":40}',               '{"1":8000,"2":13000,"3":19000}'),
  (30, 8, 25, null, 'score',       '{"score": 50000}',                         '{"1":50000,"2":75000,"3":100000}'),
  (31, 10, 24, null, 'score',      '{"score": 26000}',                         '{"1":26000,"2":36000,"3":50000}'),
  (32, 10, 22, null, 'collect',    '{"color":"yellow","count":45}',            '{"1":9000,"2":14000,"3":20000}'),
  (33, 10, null, 85, 'score',      '{"score": 27500}',                         '{"1":27500,"2":38000,"3":52000}'),
  (34, 10, 20, null, 'collect',    '{"color":"purple","count":42}',            '{"1":8000,"2":12000,"3":18000}'),
  (35, 10, 22, null, 'score',      '{"score": 29000}',                         '{"1":29000,"2":40000,"3":55000}'),
  (36, 10, null, 70, 'score',      '{"score": 30000}',                         '{"1":30000,"2":42000,"3":58000}'),
  (37, 10, 18, null, 'collect',    '{"color":"blue","count":48}',              '{"1":10000,"2":15000,"3":22000}'),
  (38, 10, 20, null, 'score',      '{"score": 32000}',                         '{"1":32000,"2":45000,"3":62000}'),
  (39, 10, null, 90, 'collect',    '{"color":"orange","count":50}',            '{"1":10000,"2":16000,"3":24000}'),
  (40, 10, 22, null, 'score',      '{"score": 35000}',                         '{"1":35000,"2":48000,"3":66000}'),
  (41, 10, 19, null, 'collect',    '{"color":"green","count":50}',             '{"1":10000,"2":15000,"3":22000}'),
  (42, 10, 21, null, 'score',      '{"score": 38000}',                         '{"1":38000,"2":52000,"3":72000}'),
  (43, 10, null, 80, 'score',      '{"score": 40000}',                         '{"1":40000,"2":56000,"3":76000}'),
  (44, 10, 17, null, 'collect',    '{"color":"red","count":48}',               '{"1":9000,"2":14000,"3":20000}'),
  (45, 10, 20, null, 'score',      '{"score": 42000}',                         '{"1":42000,"2":58000,"3":80000}'),
  (46, 10, null, 60, 'collect',    '{"color":"yellow","count":40}',            '{"1":8000,"2":12000,"3":17000}'),
  (47, 10, 18, null, 'score',      '{"score": 45000}',                         '{"1":45000,"2":62000,"3":85000}'),
  (48, 10, null, 75, 'score',      '{"score": 48000}',                         '{"1":48000,"2":66000,"3":90000}'),
  (49, 10, 16, null, 'collect',    '{"color":"purple","count":50}',            '{"1":10000,"2":16000,"3":23000}'),
  (50, 10, 30, null, 'score',      '{"score": 75000}',                         '{"1":75000,"2":11000,"3":150000}')
on conflict (level_number) do nothing;
