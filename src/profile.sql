create table profile
(
    id integer not null primary key,
    name text not null
);

create table profileaffinity
(
    pid integer not null,
    aid integer null,
    sid integer null,
    value integer not null,

    foreign key (pid) references profile(id),
    foreign key (aid) references attribute(id),
    foreign key (sid) references skill(id)
);

create view vprofileaffinity as select
    profileaffinity.pid as pid,
    profileaffinity.aid as aid,
    profileaffinity.sid as sid
from seq4, profileaffinity
where b < value
union all select profile.id as pid, attribute.id as aid, null as sid from profile, attribute
union all select profile.id as pid, null as aid, skill.id as sid from profile, skill
;

insert into profile
    (id, name)
    values
    (1, 'Rogue'),
    (3, 'Brute'),
    (4, 'Decker'),
    (5, 'Rigger')
;

insert into profileaffinity
    (pid, aid, sid, value)
    values
    (1, 1, null, 10),
    (1, 3, null, 8),

    (3, 4, null, 8),

    (4, 7,  null, 10),
    (4, 8,  null, 8),

    (5, 7,  null, 10),
    (5, 8,  null, 8)
;

