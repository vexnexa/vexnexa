-- suppliers: leveranciers
create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  kvk text,
  payout_ref text,
  created_at timestamptz default now()
);

-- parts: generieke onderdelen
create table public.parts (
  id uuid primary key default gen_random_uuid(),
  oem_number text,
  ean text,
  title text not null,
  brand text,
  images text[] default '{}',
  created_at timestamptz default now()
);
create index parts_tsv_idx on public.parts using gin (to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(oem_number,'') || ' ' || coalesce(ean,'')));

-- leveranciersonderdelen
create table public.supplier_parts (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid not null references public.suppliers(id) on delete cascade,
  part_id uuid not null references public.parts(id) on delete cascade,
  sku text,
  price_cents int not null,
  currency text not null default 'EUR',
  stock int not null default 0,
  lead_time_days int not null default 1,
  unique (supplier_id, part_id)
);

-- basis voertuigen
create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  make text,
  model text,
  year int,
  vin_prefix text
);

-- fitments
create table public.fitments (
  part_id uuid references public.parts(id) on delete cascade,
  vehicle_id uuid references public.vehicles(id) on delete cascade,
  primary key (part_id, vehicle_id)
);

-- orders
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references auth.users(id),
  status text not null default 'pending',
  total_cents int not null default 0,
  tracking_code text,
  carrier text,
  created_at timestamptz default now()
);

-- order_items
create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  supplier_part_id uuid not null references public.supplier_parts(id),
  qty int not null,
  unit_price_cents int not null,
  fee_pct numeric not null default 2.0
);
