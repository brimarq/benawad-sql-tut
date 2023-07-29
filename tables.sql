create table users (
  id serial primary key,
  first_name varchar(255) not null,
  last_name text,
  age int,
  email text unique not null
);

-- 1 to m or 1 to many relationship
create table posts (
  id serial primary key,
  title text not null,
  body text default '...',
  /* use "" if using caps in table headings */
  "creatorId" int references users(id) not null -- creates a foreign key
);

-- 1 to many with posts
-- 1 to many with users
create table comments (
  id serial primary key,
  message text not null,
  post_id int references posts(id),
  creator_id int references users(id)
);

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