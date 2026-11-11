-- Review and apply to the correct Supabase project before enabling the app UI.
-- Requests are intentionally NOT automatic deletion.
create table if not exists public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  app text not null check (app in ('parceiro')),
  status text not null default 'pending' check (status in ('pending','in_review','completed','rejected')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  internal_notes text
);
create index if not exists account_deletion_requests_user_idx
  on public.account_deletion_requests(user_id, created_at desc);
create unique index if not exists account_deletion_requests_pending_unique
  on public.account_deletion_requests(user_id, app) where status = 'pending';
alter table public.account_deletion_requests enable row level security;
revoke all on public.account_deletion_requests from anon;
grant insert, select on public.account_deletion_requests to authenticated;
create policy "Users can submit own deletion requests"
  on public.account_deletion_requests for insert to authenticated
  with check ((select auth.uid()) = user_id and app = 'parceiro' and status = 'pending');
create policy "Users can read own deletion requests"
  on public.account_deletion_requests for select to authenticated
  using ((select auth.uid()) = user_id);
-- Administrative review must use a separately authorized backend.
-- Do not grant broad update or select privileges to other merchants.
