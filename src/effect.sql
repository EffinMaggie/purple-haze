create table effect
(
    id integer not null primary key,
    name text null,
    aid integer null,
    sid integer null,
    modifier integer not null,
    karma integer not null,

    foreign key (aid) references attribute(id),
    foreign key (sid) references skill(id)
);

create view vattributeeffect as select
    10000 + 20 * a.id + b.b as key,
    a.name || ' ' || case when b.b < 6 then '' else '+' end || (b.b - 6) as name,
    a.id as aid,
    null as sid,
    b.b - 6 as modifier,
    a.karma * (b.b - 6) as karma
from attribute as a, seq4 as b
where b.b < 13 and b.b <> 6;

create view vskilleffect as select
    20000 + 20 * a.id + b.b as key,
    a.name || ' ' || case when b.b < 6 then '' else '+' end || (b.b - 6) as name,
    null as aid,
    a.id as sid,
    b.b - 6 as modifier,
    3 * (b.b - 6) as karma
from skill as a, seq4 as b
where b.b < 13 and b.b <> 6;

create view vautoeffect as
select * from vattributeeffect
union
select * from vskilleffect;

create view veffect as select
    s.id,
    s.name,
    s.aid,
    s.sid,
    s.modifier,
    s.karma
from (select * from effect union select * from vautoeffect) as s;

create table quality
(
    id integer not null primary key,
    name text not null
);

create table qeffect
(
    pid integer not null,
    eid integer not null,

    primary key (pid, eid),

    foreign key (pid) references quality(id),
    foreign key (eid) references veffect(id)
);

insert into effect
    (id, name, aid, sid, modifier, karma)
    values
    (0, 'Retrograde Amnesia', 14, null, -7, -14),
    (1, 'Photographic Memory', 14, null, 10, 20)
;

insert into quality
    (id, name)
    values
    (0,  'Retrograde Amnesia'),
    (1,  'Photographic Memory'),
    (2,  'Cyberpsychosis'),
    (5,  'Combat Paralysis'),
    (10, 'Skillwires'),
    (11, 'Cranial Bomb'),
    (12, 'Implanted Commlink')
;

insert into qeffect
    (pid, eid)
    values
    (0, 0),
    (1, 1)
;

