create table race
(
    id integer not null primary key,
    name text not null,
    sentient boolean not null default 0,
    karma integer not null default 500
);

create table racerange
(
    rid integer not null,
    aid integer null,
    sid integer null,
    minvalue integer,
    maxvalue integer,

    foreign key (rid) references race(id),
    foreign key (aid) references attribute(id),
    foreign key (sid) references skill(id)
);

create table metatype
(
    id integer not null primary key,
    rid integer not null,
    name text not null,
    sentient boolean null,
    karma integer null,

    foreign key (rid) references race(id)
);

create table metatypemodifier
(
    rid integer not null,
    mid integer not null,
    aid integer null,
    sid integer null,
    value integer not null,

    foreign key (rid) references race(id),
    foreign key (mid) references metatype(id),
    foreign key (aid) references attribute(id),
    foreign key (sid) references skill(id)
);

create view vrace as select distinct
    r.id as rid,
    m.id as mid,
    coalesce (m.sentient, r.sentient) as sentient,
    coalesce (m.name, r.name) as name,
    r.karma + coalesce (m.karma, 0) as karma
from race as r
left join metatype as m on m.rid = r.id
;

create view vrange as
select
    m.id as mid,
    a.id as aid,
    null as sid,
    case when maxvalue is null then coalesce (minvalue, 1) else minvalue end
    + coalesce (mv.value, 0) as minvalue,
    coalesce (maxvalue, case when a.id <= 12 then 6 else null end) + coalesce (mv.value, 0) as maxvalue
from metatype as m
left join attribute as a -- on a.id <= 12
left join racerange as rv on rv.rid = m.rid and rv.aid = a.id
left join metatypemodifier as mv on mv.mid = m.id and mv.aid = a.id
union
select
    m.id as mid,
    null as aid,
    s.id as sid,
    case when mv.value is null then minvalue else coalesce (minvalue, 0) end
    + coalesce (mv.value, 0) as minvalue,
    coalesce (maxvalue, 12) + coalesce (mv.value, 0) as maxvalue
from metatype as m
left join skill as s
left join racerange as rv on rv.rid = m.rid and rv.sid = s.id
left join metatypemodifier as mv on mv.rid = m.rid and mv.mid = m.id and mv.sid = s.id
;

insert into race
    (id, name, sentient, karma)
    values
    (1,  'humanoid',     1, 300),
    (2,  'agent',        0, 200),
    (3,  'spirit',       0, 300),
    (4,  'feline',       0, 100),
    (5,  'canine',       0, 100),
    (6,  'rodent',       0, 50),
    (7,  'serpentes',    0, 100),
    (8,  'fay',          0, 200),
    (9,  'caudata',      0, 50),
    (10, 'aves',         0, 100),
    (11, 'shapeshifter', 0, 800),
    (12, 'lagomorpha',   0, 50)
;

insert into racerange
    (rid, aid, sid, minvalue, maxvalue)
    values
    (1, 11, null, null, 6),
    (1, 12, null, null, 6),

    (1, 20, null, 6, null),
    (1, 21, null, 6, null),

    (2, 1, null, null, 0),
    (2, 2, null, null, 0),
    (2, 3, null, null, 0),
    (2, 4, null, null, 0),
    (2, 11, null, null, 0),
    (2, 12, null, 2, 8),

    (3, 11, null, 2, 7),
    (3, 12, null, null, 0),

    (4, 11, null, null, 6),
    (4, 12, null, null, 6),

    (5, 11, null, null, 6),
    (5, 12, null, null, 6),

    (6, 11, null, null, 6),
    (6, 12, null, null, 6)
;

insert into metatype
    (id, rid, name, sentient)
    values
    ( 0,  1,  'human',       1)
;

insert into metatype
    (id, rid, name, karma)
    values
    ( 1,  2,  'agent',       50),
    ( 2,  3,  'banshee',     50),
    ( 3,  3,  'wisp',        -50),
    ( 4,  3,  'ghost',       null),
    ( 5,  3,  'poltergeist', null),
    ( 6,  3,  'sylph',       null),
    ( 7,  4,  'cat',         null),
    ( 8,  4,  'manx',        null),
    ( 9,  4,  'cougar',      100),
    (10,  4,  'cheetah',     100),
    (11,  4,  'tiger',       300),
    (12,  4,  'lynx',        200),
    (13,  5,  'poodle',      null),
    (14,  5,  'wolf',        100),
    (15,  6,  'squirrel',    null),
    (16,  6,  'rat',         null),
    (17,  6,  'mouse',       null),
    (18,  6,  'hamster',     null),
    (19,  6,  'guinea pig',  null),
    (20,  7,  'snake',       null),
    (21,  7,  'cobra',       100),
    (22,  7,  'rattlesnake', 50),
    (23,  7,  'wyrm',        900),
    (24,  7,  'dragon',      1900),
    (25,  8,  'pixie',       null),
    (26,  8,  'imp',         50),
    (27,  8,  'goblin',      100),
    (28,  8,  'drake',       150),
    (29,  9,  'salamander',  null),
    (30,  9,  'newt',        null),
    (31,  10, 'kestrel',     50),
    (32,  10, 'sparrow',     null),
    (33,  10, 'swallow',     null),
    (34,  10, 'griffin',     500),
    (35,  11, 'neck',        null),
    (36,  11, 'strömkarl',   null),
    (37,  12, 'rabbit',      null),
    (38,  12, 'pika',        null),
    (39,  12, 'leveret',     -25),
    (40,  12, 'hare',        50)
;

