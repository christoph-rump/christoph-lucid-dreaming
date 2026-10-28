-- Newsletter with double opt-in for the lucid dreaming page (B-015b).
-- Paste once into the Supabase SQL editor of THIS site's own project (not the facilitator network's).
--
-- Flow: the form calls nl_request(email, lang) -> a row appears, unconfirmed.
--       The page then asks Supabase Auth to send a magic link (sent by Resend via SMTP).
--       Clicking it signs the address in once -> the trigger below marks the row confirmed.
--       Every newsletter carries <site>#unsubscribe=<unsubscribe_token> -> nl_unsubscribe(token).
-- The anon key can only call the two functions; the table itself has RLS on and no policies.

create table if not exists public.subscribers (
  id                uuid primary key default gen_random_uuid(),
  email             text not null unique,
  lang              text not null default 'en' check (lang in ('en', 'de')),
  requested_at      timestamptz not null default now(),
  confirmed_at      timestamptz,
  unsubscribed_at   timestamptz,
  unsubscribe_token uuid not null default gen_random_uuid(),
  user_id           uuid references auth.users (id) on delete set null,
  created_at        timestamptz not null default now()
);
alter table public.subscribers enable row level security;   -- no policies: no direct access with the anon key

-- Sign-up request (unconfirmed). Re-requesting refreshes the 24 h confirmation window.
create or replace function public.nl_request(p_email text, p_lang text default 'en')
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_email is null or length(p_email) > 254 or p_email !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'invalid email';
  end if;
  insert into subscribers (email, lang) values (lower(trim(p_email)), case when p_lang = 'de' then 'de' else 'en' end)
  on conflict (email) do update set requested_at = now(), lang = excluded.lang;
end $$;

-- Unsubscribe by the token in the newsletter's link. Returns true when a subscription was ended.
create or replace function public.nl_unsubscribe(p_token uuid)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  update subscribers set unsubscribed_at = now() where unsubscribe_token = p_token and unsubscribed_at is null;
  return found;
end $$;

revoke all on function public.nl_request(text, text) from public;
revoke all on function public.nl_unsubscribe(uuid) from public;
grant execute on function public.nl_request(text, text) to anon;
grant execute on function public.nl_unsubscribe(uuid) to anon;

-- Confirmation: the magic link signs the address in; only a sign-in within 24 h of a request confirms it,
-- so later logins (e.g. a members area) never re-subscribe someone who unsubscribed.
create or replace function public.nl_confirm_on_sign_in()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.email_confirmed_at is not null and new.last_sign_in_at is distinct from old.last_sign_in_at then
    update subscribers
       set confirmed_at = now(), unsubscribed_at = null, user_id = new.id
     where email = lower(new.email)
       and requested_at > now() - interval '24 hours'
       and (confirmed_at is null or confirmed_at < requested_at);
  end if;
  return new;
end $$;

drop trigger if exists nl_confirm_on_sign_in on auth.users;
create trigger nl_confirm_on_sign_in after update on auth.users
  for each row execute function public.nl_confirm_on_sign_in();

-- Your list: confirmed, not unsubscribed.
--   select email, lang, confirmed_at from subscribers where confirmed_at is not null and unsubscribed_at is null;
