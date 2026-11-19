-- Capão Entregador 0.2.1 security migration.
-- PREPARED ONLY: review and test before running on the production Supabase project.
-- This migration changes RPC privileges and will break the 0.2.0 driver app.
-- Coordinate deployment with the Play internal-test build.
begin;

create or replace function public.driver_claim_and_status()
returns table(status text)
language plpgsql security definer set search_path = ''
as $$
declare v_uid uuid := auth.uid();
declare v_email text := lower(trim(coalesce(auth.jwt()->>'email','')));
begin
  if v_uid is null or v_email = '' then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  -- Only verified email identities may claim a preexisting application.
  if not exists (
    select 1 from auth.users u
    where u.id = v_uid and u.email_confirmed_at is not null
      and lower(trim(u.email)) = v_email
  ) then
    raise exception 'Verified email required' using errcode = '42501';
  end if;
  update public.driver_applications d
     set user_id = v_uid, updated_at = now()
   where d.user_id is null
     and lower(trim(d.email)) = v_email
     and d.id = (
       select x.id from public.driver_applications x
       where lower(trim(x.email)) = v_email
       order by x.created_at desc limit 1
     );
  return query
    select d.status from public.driver_applications d
    where d.user_id = v_uid and lower(trim(d.email)) = v_email
    order by d.created_at desc limit 1;
end $$;

create or replace function public.get_ready_delivery_offer()
returns table(order_id uuid, store_name text, customer_name text, delivery_address text, delivery_fee numeric, latitude double precision, longitude double precision)
language plpgsql security definer set search_path = ''
as $$
begin
  if auth.uid() is null or not exists (
    select 1 from public.driver_applications d
    where d.user_id = auth.uid() and d.status = 'approved'
  ) then raise exception 'Approved driver required' using errcode = '42501'; end if;
  return query
    select o.id,s.name,o.customer_name,o.delivery_address_text,o.delivery_fee,o.delivery_latitude,o.delivery_longitude
    from public.orders o join public.stores s on s.id=o.store_id
    left join public.delivery_assignments d on d.order_id=o.id
    where o.status='ready' and d.order_id is null
    order by o.updated_at asc limit 1;
end $$;

create or replace function public.driver_accept_delivery(p_order_id uuid,p_driver_name text)
returns text language plpgsql security definer set search_path = ''
as $$
declare v_name text; v_order_status text;
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  select d.full_name into v_name from public.driver_applications d
   where d.user_id=auth.uid() and d.status='approved' order by d.created_at desc limit 1;
  if v_name is null then raise exception 'Approved driver required' using errcode = '42501'; end if;
  select o.status into v_order_status from public.orders o where o.id=p_order_id for update;
  if v_order_status is distinct from 'ready' then raise exception 'Order not available'; end if;
  insert into public.delivery_assignments(order_id,driver_id,driver_name,status,accepted_at)
  values(p_order_id,auth.uid(),v_name,'accepted',now())
  on conflict (order_id) do nothing;
  if not found then raise exception 'Order already assigned'; end if;
  return 'accepted';
end $$;

create or replace function public.driver_advance_delivery(p_order_id uuid,p_status text)
returns text language plpgsql security definer set search_path = ''
as $$
declare v_current text;
begin
  if auth.uid() is null or not exists (
    select 1 from public.driver_applications d
    where d.user_id=auth.uid() and d.status='approved'
  ) then raise exception 'Approved driver required' using errcode = '42501'; end if;
  select d.status into v_current from public.delivery_assignments d
  where d.order_id=p_order_id and d.driver_id=auth.uid() for update;
  if v_current is null then raise exception 'Delivery not assigned to driver' using errcode = '42501'; end if;
  if not ((v_current='accepted' and p_status='picked_up') or
          (v_current='picked_up' and p_status='delivered')) then
    raise exception 'Invalid delivery transition';
  end if;
  update public.delivery_assignments d set status=p_status,
    picked_up_at=case when p_status='picked_up' then now() else d.picked_up_at end,
    delivered_at=case when p_status='delivered' then now() else d.delivered_at end,
    updated_at=now()
  where d.order_id=p_order_id and d.driver_id=auth.uid();
  update public.orders o set
    status=case when p_status='picked_up' then 'out_for_delivery' else 'delivered' end,
    updated_at=now() where o.id=p_order_id;
  return p_status;
end $$;

revoke all on function public.driver_claim_and_status() from public, anon;
revoke all on function public.get_ready_delivery_offer() from public, anon;
revoke all on function public.driver_accept_delivery(uuid,text) from public, anon;
revoke all on function public.driver_advance_delivery(uuid,text) from public, anon;
grant execute on function public.driver_claim_and_status() to authenticated;
grant execute on function public.get_ready_delivery_offer() to authenticated;
grant execute on function public.driver_accept_delivery(uuid,text) to authenticated;
grant execute on function public.driver_advance_delivery(uuid,text) to authenticated;

commit;
