create table nameusage
(
    id integer not null primary key,
    description text not null
);

insert into nameusage
    (id, description)
    values
    (1, 'human female'),
    (2, 'human male'),
    (3, 'corporation'),
    (4, 'experiment')
;

create table namescheme
(
    id integer not null primary key,
    nuid integer not null,
    description text not null,
    prio integer not null,

    foreign key (nuid) references nameusage(id)
);

insert into namescheme
    (id, nuid, description, prio)
    values
    (1,  1,  'first/female last', 20),
    (2,  2,  'first/male last',   20)
;

create table namecomponent
(
    id integer not null primary key,
    description text not null
);

insert into namecomponent
    (id, description)
    values
    (1,  'first name, female'),
    (2,  'first name, male'),
    (3,  'first name, any'),
    (4,  'last name'),
    (5,  'hyphen'),
    (6,  'space'),
    (7,  'literal'),
    (8,  'branch')
;

create table nametemplate
(
    nsid integer not null,
    pos integer not null,
    ncid integer not null,
    literal text null,
    minlength integer not null default 2,
    maxlength integer not null default 16,
    maxsublen integer not null default 16,

    foreign key (nsid) references namescheme(id),
    foreign key (ncid) references namecomponent(id)
);
