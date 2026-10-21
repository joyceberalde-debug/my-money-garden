-- Run in your own Supabase project's SQL Editor.
create table if not exists public.transactions (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 kind text not null check (kind in ('income','expense')),
 category text not null,
 description text not null default '',
 amount numeric(12,2) not null check (amount > 0),
 occurred_on date not null,
 created_at timestamptz not null default now()
);
create table if not exists public.budgets (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 category text not null,
 month text not null check (month ~ '^\d{4}-(0[1-9]|1[0-2])$'),
 amount numeric(12,2) not null check (amount >= 0),
 unique(user_id, category, month)
);
create table if not exists public.goals (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 name text not null,
 target numeric(12,2) not null check (target > 0),
 saved numeric(12,2) not null default 0 check (saved >= 0),
 created_at timestamptz not null default now()
);
create table if not exists public.bills (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 name text not null,
 amount numeric(12,2) not null check (amount > 0),
 due_day integer not null check (due_day between 1 and 31),
 category text not null default 'Bills',
 created_at timestamptz not null default now()
);
create table if not exists public.bill_payments (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 bill_id uuid not null references public.bills(id) on delete cascade,
 month text not null check (month ~ '^\d{4}-(0[1-9]|1[0-2])$'),
 paid_at timestamptz not null default now(),
 unique(bill_id, month)
);
create index if not exists transactions_user_date on public.transactions(user_id, occurred_on);
create index if not exists bills_user on public.bills(user_id);
create index if not exists bill_payments_user_month on public.bill_payments(user_id, month);

alter table public.transactions enable row level security;
alter table public.budgets enable row level security;
alter table public.goals enable row level security;
alter table public.bills enable row level security;
alter table public.bill_payments enable row level security;

-- All operations are limited to the authenticated owner.
do $$
declare t text;
begin
 foreach t in array array['transactions','budgets','goals','bills','bill_payments'] loop
  execute format('drop policy if exists owner_only on public.%I',t);
  execute format('create policy owner_only on public.%I for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)',t);
 end loop;
end $$;

-- A payment must also refer to a bill owned by the same user.
drop policy if exists owner_only on public.bill_payments;
create policy owner_only on public.bill_payments for all to authenticated
 using ((select auth.uid()) = user_id and exists (select 1 from public.bills where id = bill_id and user_id = (select auth.uid())))
 with check ((select auth.uid()) = user_id and exists (select 1 from public.bills where id = bill_id and user_id = (select auth.uid())));

-- Optional defense in depth: prevent API callers from spoofing user_id or updating ownership.
create or replace function public.enforce_owner() returns trigger language plpgsql security invoker as $$
begin
 if tg_op = 'INSERT' and new.user_id is distinct from auth.uid() then raise exception 'Invalid owner'; end if;
 if tg_op = 'UPDATE' and new.user_id is distinct from old.user_id then raise exception 'Owner cannot change'; end if;
 return new;
end; $$;
do $$ declare t text; begin
 foreach t in array array['transactions','budgets','goals','bills','bill_payments'] loop
  execute format('drop trigger if exists enforce_owner_trigger on public.%I',t);
  execute format('create trigger enforce_owner_trigger before insert or update on public.%I for each row execute function public.enforce_owner()',t);
 end loop;
end $$;
