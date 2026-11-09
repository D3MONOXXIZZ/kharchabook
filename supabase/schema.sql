-- =============================================================================
-- KharchaBook — Supabase PostgreSQL Schema & Security Policies
-- Subject: Mobile Application Development (BS-IT 6A, Bahria University)
-- Authors: Zain Kashif (01-135232-107) & Huraira Minhas (01-135232-030)
-- =============================================================================

-- Enable UUID extension if not already enabled
create extension if not exists "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 1. Profiles Table (Linked 1-to-1 with Supabase auth.users)
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  name text not null,
  email text not null,
  monthly_budget numeric(12, 2) not null default 15000.00 check (monthly_budget > 0),
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- -----------------------------------------------------------------------------
-- 2. Categories Table (Seeded student expense & income categories)
-- -----------------------------------------------------------------------------
create table if not exists public.categories (
  id serial primary key,
  name text not null,
  icon text not null,
  is_income boolean default false
);

-- Seed Categories
insert into public.categories (id, name, icon, is_income) values
  (1, 'Food & Dining', 'utensils', false),
  (2, 'Transport & Metro', 'bus', false),
  (3, 'Hostel & Rent', 'home', false),
  (4, 'Study & Photocopy', 'book-open', false),
  (5, 'Health & Medical', 'heart-pulse', false),
  (6, 'Entertainment & Cafe', 'film', false),
  (7, 'Pocket Money / Allowance', 'wallet', true),
  (8, 'Freelance / Part-time', 'briefcase', true),
  (9, 'Other Expenses', 'more-horizontal', false)
on conflict (id) do update set
  name = excluded.name,
  icon = excluded.icon,
  is_income = excluded.is_income;

-- -----------------------------------------------------------------------------
-- 3. Expenses Table (Core transaction ledger)
-- -----------------------------------------------------------------------------
create table if not exists public.expenses (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  amount numeric(12, 2) not null check (amount > 0),
  type text not null check (type in ('income', 'expense')),
  category_id int references public.categories(id) not null,
  date date not null default current_date,
  note text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- -----------------------------------------------------------------------------
-- 4. Query Performance Indexes
-- -----------------------------------------------------------------------------
create index if not exists idx_expenses_user_date on public.expenses(user_id, date desc);
create index if not exists idx_expenses_user_category on public.expenses(user_id, category_id);

-- -----------------------------------------------------------------------------
-- 5. Row Level Security (RLS) Policies
-- -----------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.expenses enable row level security;

-- Profiles Policies
create policy "Allow users to view own profile"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "Allow users to update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

create policy "Allow users to insert own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- Categories Policies
create policy "Allow all authenticated users to read categories"
  on public.categories for select
  to authenticated
  using (true);

-- Expenses Policies
create policy "Allow users to read own expenses"
  on public.expenses for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Allow users to insert own expenses"
  on public.expenses for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Allow users to update own expenses"
  on public.expenses for update
  to authenticated
  using (auth.uid() = user_id);

create policy "Allow users to delete own expenses"
  on public.expenses for delete
  to authenticated
  using (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
-- 6. User Signup Auto-Profile Trigger
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, email, monthly_budget)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    15000.00
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to run after new row inserted in auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
