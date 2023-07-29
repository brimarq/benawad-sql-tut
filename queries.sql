create table users (
  id serial primary key,
  first_name varchar(255) not null,
  last_name text,
  age int,
  email text unique not null
);

drop table users; 

-- data type serial is a special int that auto increments
-- PRIMARY KEY ensures not null and UNIQUE

insert into users (id, first_name, last_name, age, email) 
values (default, 'bob', 'bobby', 19, 'bob0@bob.com');

-- this also works: no need to explicitly insert the id
insert into users (first_name, last_name, age, email) 
values ('bob', 'bobby', 19, 'bob4@bob.com');

insert into users (first_name, email) 
values ('bob','bob5@bob.com');

insert into users (first_name, last_name, age, email) 
values ('bob', null, null, 'bob6@bob.com');

select first_name, last_name, age from users;

select * from users;

alter table users drop column age;
/* not null won't work with alter here, as adding a column to an existing table will insert null values */
alter table users add column age int not null;
alter table users add column age int default 20;
alter table users add column age int;

select * from users where id = 3;
select * from users where id = 3 or id = 4;
select * from users where id = 3 and first_name = 'bob';
select * from users where id in (3, 4, 5);
select * from users where age > 10;

/* can use coalesce to sub a default value during query for null entries */
select * from users where coalesce(age, 15) > 10;
select * from users where age is null;
select * from users where age is not null;

update users
set age = 20
where id = 1;

update users
set age = 21,
  last_name = 'tom'
where id = 1;

-- increment int, concat string with || 
update users
set age = age + 1,
  last_name = last_name || ' tom2'
where id = 1;

-- update all ages (except null)
update users
set age = age + 1;

update users
set age = 33
where age is null;

update users
set age = age - 10
where age < 25;

delete from users 
where id = 3;

delete from users 
where last_name is null;


-- 1 to m or 1 to many relationship
create table posts (
  id serial primary key,
  title text not null,
  body text default '...',
  /* use "" if using caps in table headings */
  "creatorId" int references users(id) not null -- creates a foreign key
);

drop table posts;

insert into posts (title, "creatorId") 
values ('my first post', 1);

insert into posts (title, "creatorId") 
values ('my second post', 1);

select * from posts;

/* this will not work if the creatorId does not exist */
insert into posts (title, "creatorId") 
values ('my first post', 10);

/* now this will fail with error:
update or delete on table "users" violates foreign key constraint "posts_creatorid_fkey" on table "posts"
*/
delete from users 
where id = 1;

select first_name from users 
inner join posts on users.id = posts."creatorId"

-- using aliases
select first_name, p.title from users u
inner join posts p on u.id = p."creatorId";

/* can also leave off the p in title if there's only one 
  table being joined and the other table has no title heading */
select first_name, title from users u
inner join posts p on u.id = p."creatorId";

/* selects only from user id 1 b/c of the inner join getting
  rid of users that don't have any posts */
-- 1 single user
-- 2 posts
-- x * (y, z) = (x, y), (x, z)
select u.id user_id, p.id post_id, first_name, title from users u
inner join posts p on u.id = p."creatorId";

/* left join */
select u.id, p.id, first_name, title from users u
left join posts p on u.id = p."creatorId";


insert into posts (title, "creatorId") 
values ('the great sixth article', 4);

delete from posts
where "creatorId" = 4;

select u.id user_id, p.id post_id, first_name, title from users u
inner join posts p on u.id = p."creatorId"
where p.title like '%second%';

select u.id user_id, p.id post_id, first_name, title from users u
inner join posts p on u.id = p."creatorId"
where p.title like 'my%';

select u.id user_id, p.id post_id, first_name, title from users u
inner join posts p on u.id = p."creatorId"
where p.title like '%article';

select u.id user_id, p.id post_id, first_name, title from users u
inner join posts p on u.id = p."creatorId"
where p.title like '%my%post';

-- ilike ignores casing
select u.id user_id, p.id post_id, first_name, title from users u
inner join posts p on u.id = p."creatorId"
where p.title ilike '%my%Post';

select u.id user_id, p.id post_id, first_name, title from users u
inner join posts p on u.id = p."creatorId"
where p.title ilike '%my%Post' and u.id = 1;

-- 1 to many with posts
-- 1 to many with users
create table comments (
  id serial primary key,
  message text not null,
  post_id int references posts(id),
  creator_id int references users(id)
);

select * from users;
select * from posts;

insert into comments (message, post_id, creator_id)
values ('hello, nice post!', 2, 4);

select c.message, p.title from comments c
inner join posts p on c.post_id = p.id;

select c.message, p.title, u.first_name from comments c
inner join posts p on c.post_id = p.id
inner join users u on p."creatorId" = u.id;

select c.message, p.title, 
u.first_name first_name_for_post,
u2.first_name first_name_for_comment from comments c
inner join posts p on c.post_id = p.id
inner join users u on p."creatorId" = u.id
inner join users u2 on c.creator_id = u2.id;

select c.message, p.title, 
u.id user_id_for_post,
u2.id user_id_for_comment from comments c
inner join posts p on c.post_id = p.id
inner join users u on p."creatorId" = u.id
inner join users u2 on c.creator_id = u2.id;

-- favorites/upvotes/likes
-- user - post
-- NOT a 1 to many relationship
-- many to many relationship
-- join table
create table favorites (
  user_id int references users(id),
  post_id int references posts(id),
  primary key (user_id, post_id) -- composite key
);

select * from users;
select * from posts;

/* running this twice will error: 
  duplicate key value violates unique constraint "favorites_pkey" */
insert into favorites (user_id, post_id) 
values (1, 8);

insert into favorites (user_id, post_id) 
values (1, 7);

insert into favorites (user_id, post_id) 
values (4, 7);

insert into favorites (user_id, post_id) 
values (2, 7);

select * from favorites;

-- friend
-- user - user
-- NOT a 1 to many
-- many to many
-- bob -> mary
-- bob -> tom
-- tom -> mary
-- tom -> jack
create table friends (
  user_id1 int references users(id),
  user_id2 int references users(id),
  primary key (user_id1, user_id2)
);

insert into friends (user_id1, user_id2) 
values (2, 4);

insert into friends (user_id1, user_id2) 
values (1, 4);

insert into friends (user_id1, user_id2) 
values (1, 2);

select * from friends;

/*
Recap: 

1. create a table for each thing
  - user
  - post
  - comment
2. setup relationships
  - m to n (many users to many posts)
    - join table with foreign keys
  - 1 to m (one user maps to many posts)
    - foreign key
  - 1 to 1 (profile for a user)
    - usually collapse into a single table

*/

select * from users;

-- FEED 
--***************************
select * from posts;

-- grabs ALL columns
select * from posts p 
inner join users u on p."creatorId" = u.id;

-- grabs selected columns from each table
select p.title, p.body, u.first_name from posts p 
inner join users u on p."creatorId" = u.id;

/* Get a random date within 100 days 
  previous to current date.
*/
select now() - (random() * interval '100 days');

/* Add creted_at column to posts table 
  with a random date within 100 days 
  previous to current date.
*/
alter table posts 
add column created_at date default now() - (random() * interval '100 days');


-- grabs selected columns from each table, ordered by date
select p.created_at, p.title, p.body, u.first_name from posts p 
inner join users u on p."creatorId" = u.id
order by created_at;

-- grabs selected columns from each table, ordered by desc date
select p.created_at, p.title, p.body, u.first_name from posts p 
inner join users u on p."creatorId" = u.id
order by created_at desc;

-- get a substring for the post body (1 index, not 0 in postgres)
select p.created_at, p.title, 
  substr(p.body, 1, 30), u.first_name from posts p 
inner join users u on p."creatorId" = u.id
order by created_at desc;

-- limit rows  - must be put at the end.
select p.created_at, p.title, 
  substr(p.body, 1, 30), u.first_name from posts p 
inner join users u on p."creatorId" = u.id
order by created_at desc
limit 20;

-- offset - good for paging.
select p.created_at, p.title, 
  substr(p.body, 1, 30), u.first_name from posts p 
inner join users u on p."creatorId" = u.id
order by created_at desc
offset 20
limit 20;

-- filter by certain date using where.
select p.created_at, p.title, 
  substr(p.body, 1, 30), u.first_name from posts p 
inner join users u on p."creatorId" = u.id
where created_at < '2023-07-07'
order by created_at desc
limit 20;

-- POST 
--***************************

select p.title, u.first_name from posts p
inner join users u on p."creatorId" = u.id
where p.id = 7;

select p.title, u.first_name, c.message from posts p
inner join users u on p."creatorId" = u.id
inner join comments c on p.id = c.post_id
where p.id = 7;

select p.title, 
  u.first_name, 
  c.message,
  u2.first_name comment_creator
from posts p
inner join users u on p."creatorId" = u.id
inner join comments c on p.id = c.post_id
inner join users u2 on u2.id = c.creator_id
where p.id = 7;

select * from comments c
inner join users u2 on u2.id = c.creator_id
where post_id = 7;

-- count the # of rows
select count(*) from users;

select count(*) from comments c
inner join users u2 on u2.id = c.creator_id
where post_id = 7;

select * from favorites 
where post_id = 7 and user_id = 74;

select p.title, 
  u.first_name, 
  c.message,
  u2.first_name comment_creator,
  f.user_id is not null has_favorited -- returns a boolean
from posts p
inner join users u on p."creatorId" = u.id
inner join comments c on p.id = c.post_id
inner join users u2 on u2.id = c.creator_id
left join favorites f 
  on f.post_id = p.id and f.user_id = 74
where p.id = 7;

select p.title, 
  u.first_name, 
  c.message,
  u2.first_name comment_creator,
  f.user_id is not null has_favorited -- returns a boolean
from posts p
inner join users u on p."creatorId" = u.id
inner join comments c on p.id = c.post_id
inner join users u2 on u2.id = c.creator_id
left join favorites f 
  on f.post_id = p.id and f.user_id = 4
where p.id = 7;


-- who has the most friends?
--***************************

select * from users u
inner join friends f on f.user_id1 = u.id;

select * from friends;

-- count # of friends for each user_id1
select user_id1, count(user_id2) from friends
group by user_id1;

-- as above, also aggregate the friends into an array
select user_id1,
  array_agg(user_id2),
  count(user_id2) 
from friends
group by user_id1;

-- sort by # of friends
select user_id1,
  array_agg(user_id2),
  count(*) 
from friends
group by user_id1
order by count(*) desc;


-- error: column "u.first_name" must appear in the GROUP BY clause or be used in an aggregate function
select 
  u.first_name, 
  user_id1,
  array_agg(user_id2),
  count(*) 
from friends f
inner join users u on u.id = f.user_id1
group by user_id1
order by count(*) desc;

-- gives an array of duplicates of u.first_name
select 
  array_agg(u.first_name), 
  user_id1,
  array_agg(user_id2),
  count(*) 
from friends f
inner join users u on u.id = f.user_id1
group by user_id1
order by count(*) desc;

-- use max to reduce the array to single u.first_name
select 
  max(u.first_name), 
  user_id1,
  array_agg(user_id2),
  count(*) 
from friends f
inner join users u on u.id = f.user_id1
group by user_id1
order by count(*) desc;


-- what's the most popular post?
--***************************

-- list post_id with # of favorites
select post_id, count(*) 
from favorites f 
group by post_id
order by count(*) desc;

-- as sbove, also list the post title
select max(p.title), post_id, count(*) 
from favorites f 
inner join posts p on f.post_id = p.id 
group by post_id
order by count(*) desc;


-- Who has no friends?
--***************************

-- all users with friends
select * from users u 
inner join friends f 
  on f.user_id1 = u.id 
    or f.user_id2 = u.id;

-- left join will include null values
-- can then filter by those
select * from users u 
left join friends f 
  on f.user_id1 = u.id 
    or f.user_id2 = u.id
where f.user_id1 is null;


-- Who has written no posts?
--***************************

select * from users u 
left join posts p 
  on p."creatorId" = u.id
where p."creatorId" is null;

-- how many wrote no posts?
select count(*) from users u 
left join posts p 
  on p."creatorId" = u.id
where p."creatorId" is null;

-- how many distinct "creatorId"s wrote posts?
select count(distinct "creatorId") from posts;


-- advanced feed
--***************************

select * from users where id = 1;


/* Get posts written by friends of user 1:
Select posts where the creatorId matches the user_id1 or 
user_id2 in the friends table AND the the user_id1 or 
user_id2 = 1. 
Filter those rows where the creatorId != 1.  
*/
select * from posts p
inner join friends f 
on (f.user_id1 = p."creatorId" 
or f.user_id2 = p."creatorId")
and (f.user_id1 = 1 or f.user_id2 = 1) 
where "creatorId" != 1;


/* See posts liked by a friend as well
*/
select * from posts p
left join friends f 
on (f.user_id1 = p."creatorId" 
or f.user_id2 = p."creatorId")
and (f.user_id1 = 1 or f.user_id2 = 1) 
left join favorites f2 on f2.post_id = p.id 
left join friends f3 
on (f3.user_id1 = f2.user_id or f3.user_id2 = f2.user_id) and (f3.user_id1 = 1 or f3.user_id2 = 1)
where "creatorId" != 1 
and (f.user_id1 is not null or f3.user_id1 is not null);

