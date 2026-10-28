-- Members area for courses (B-015c). Paste once into the SQL editor of THIS site's Supabase project,
-- after newsletter.sql. Payments stay with you: when someone has paid, add their email to `members`.
--
--   insert into members (email, note) values ('anna@example.com', 'paid 2026-11-02, course 1');
--   update members set revoked_at = now() where email = 'anna@example.com';   -- end access
--
-- Login is by email link (Supabase Auth). Lessons and videos are only readable for logged-in members:
-- row-level security on `course_lessons`, a storage policy on the private bucket `course-videos`.

create table if not exists public.members (
  email      text primary key check (email = lower(email)),
  note       text,
  granted_at timestamptz not null default now(),
  revoked_at timestamptz
);
alter table public.members enable row level security;   -- no policies: only you (dashboard / SQL) see the list

-- true when the logged-in user's email is on the list and not revoked
create or replace function public.is_member()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from members
     where email = lower(coalesce(auth.jwt() ->> 'email', ''))
       and revoked_at is null
  );
$$;
revoke all on function public.is_member() from public;
grant execute on function public.is_member() to authenticated;

create table if not exists public.course_lessons (
  id         bigint generated always as identity primary key,
  course     text not null default 'course-1',
  position   int  not null default 1,
  title      text not null,
  body       text not null default '',          -- plain text; blank lines start a new paragraph
  video_path text,                              -- file name inside the bucket course-videos, e.g. 'course-1/lesson-1.mp4'
  created_at timestamptz not null default now()
);
alter table public.course_lessons enable row level security;
drop policy if exists "members read lessons" on public.course_lessons;
create policy "members read lessons" on public.course_lessons
  for select to authenticated using (public.is_member());

-- Private bucket for the videos; members get short-lived signed links from the page.
insert into storage.buckets (id, name, public) values ('course-videos', 'course-videos', false)
  on conflict (id) do update set public = false;
drop policy if exists "members read course videos" on storage.objects;
create policy "members read course videos" on storage.objects
  for select to authenticated using (bucket_id = 'course-videos' and public.is_member());

-- Example lesson (delete or edit in the table editor):
--   insert into course_lessons (course, position, title, body, video_path)
--   values ('course-1', 1, 'Welcome', E'What this course is about.\n\nHow to use the lessons.', 'course-1/lesson-1.mp4');
