-- entity attributes: senses, signatures, capabilities, anatomic details

create table feature
(
    id integer not null primary key,
    name text not null,
    superficial boolean not null default 1,
    symmetric boolean not null default 1,
    vestigial boolean not null default 0
);

create table sense
(
    id integer not null primary key,
    name text not null,
    directional boolean not null default 1,
    signature boolean not null default 1
);
