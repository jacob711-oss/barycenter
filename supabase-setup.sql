-- Barycenter world leaderboard: run this once in Supabase (SQL Editor -> New query -> Run).
-- Players can read the top 100 and post their own score; nobody can edit or delete someone else's row.

create table if not exists public.leaderboard (
  id uuid primary key,
  secret text not null,
  name text not null check (char_length(name) between 1 and 20),
  stars int not null check (stars between 0 and 400),
  done int not null default 0 check (done between 0 and 200),
  updated_at timestamptz not null default now()
);
alter table public.leaderboard enable row level security;
revoke all on public.leaderboard from anon, authenticated;

-- public, read-only view without the secret column
create or replace view public.leaderboard_top as
  select id, name, stars, done, updated_at from public.leaderboard
  order by stars desc, updated_at asc limit 100;
grant select on public.leaderboard_top to anon;

-- post or update your own score (the secret proves the row is yours)
create or replace function public.submit_score(p_id uuid, p_secret text, p_name text, p_stars int, p_done int)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into leaderboard (id, secret, name, stars, done)
  values (p_id, p_secret, left(trim(p_name), 20), p_stars, p_done)
  on conflict (id) do update
    set name = excluded.name, stars = excluded.stars, done = excluded.done, updated_at = now()
    where leaderboard.secret = p_secret;
end $$;

-- remove your own score (when you hide yourself or delete your account)
create or replace function public.remove_score(p_id uuid, p_secret text)
returns void language plpgsql security definer set search_path = public as $$
begin
  delete from leaderboard where id = p_id and secret = p_secret;
end $$;

revoke all on function public.submit_score(uuid, text, text, int, int) from public;
revoke all on function public.remove_score(uuid, text) from public;
grant execute on function public.submit_score(uuid, text, text, int, int) to anon;
grant execute on function public.remove_score(uuid, text) to anon;

-- ===== World leaderboard for every simulator (Biosphere, Lithosphere, Troposphere, Catalyst, Abyssal and the rest) =====
create table if not exists public.game_scores (
  id uuid not null,
  game text not null check (char_length(game) between 1 and 30),
  secret text not null,
  name text not null check (char_length(name) between 1 and 20),
  stars int not null check (stars between 0 and 600),
  done int not null default 0 check (done between 0 and 200),
  updated_at timestamptz not null default now(),
  primary key (id, game)
);
alter table public.game_scores enable row level security;
revoke all on public.game_scores from anon, authenticated;
create or replace view public.game_scores_top as
  select id, game, name, stars, done, updated_at from public.game_scores;
grant select on public.game_scores_top to anon;
create or replace function public.submit_game_score(p_id uuid, p_secret text, p_game text, p_name text, p_stars int, p_done int)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into game_scores (id, game, secret, name, stars, done)
  values (p_id, p_game, p_secret, left(trim(p_name), 20), p_stars, p_done)
  on conflict (id, game) do update
    set name = excluded.name, stars = excluded.stars, done = excluded.done, updated_at = now()
    where game_scores.secret = p_secret;
end $$;
create or replace function public.remove_game_score(p_id uuid, p_secret text, p_game text)
returns void language plpgsql security definer set search_path = public as $$
begin delete from game_scores where id = p_id and game = p_game and secret = p_secret; end $$;
revoke all on function public.submit_game_score(uuid, text, text, text, int, int) from public;
revoke all on function public.remove_game_score(uuid, text, text) from public;
grant execute on function public.submit_game_score(uuid, text, text, text, int, int) to anon;
grant execute on function public.remove_game_score(uuid, text, text) to anon;
