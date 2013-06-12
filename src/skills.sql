-- attributes, skills, etc

create table attribute
(
    id integer not null primary key,
    name text not null,
    agility integer not null,
    reaction integer not null,
    strength integer not null,
    intuition integer not null,
    logic integer not null,
    willpower integer not null,
    karma integer not null
);

create table skill
(
    id integer not null primary key,
    name text not null,
    aid integer not null,

    foreign key (aid) references attribute(id)
);

insert into attribute
    (id, name, agility, reaction, strength, intuition, logic, willpower, karma)
    values
    (1,  'Agility',              1,   0,   0,   0,   0,   0,   15),
    (3,  'Reaction',             0,   1,   0,   0,   0,   0,   15),
    (4,  'Strength',             0,   0,   1,   0,   0,   0,   15),
    (5,  'Charisma',             0,   0,   0,   0,   0,   0,   15),
    (6,  'Intuition',            0,   0,   0,   1,   0,   0,   15),
    (7,  'Logic',                0,   0,   0,   0,   1,   0,   15),
    (8,  'Willpower',            0,   0,   0,   0,   0,   1,   15),
    (13, 'Initiative',           0,   1,   0,   1,   0,   0,    3),
    (14, 'Memory',               0,   0,   0,   0,   1,   1,    2),
    (15, 'Knowledge',            0,   0,   0,   1,   1,   0,    2),
    (20, 'Hit Points',           0,   0,   1,   0,   0,   1,    2),
    (21, 'Shock Points',         0,   0,   0,   0,   1,   1,    2),
    (31, 'Composure',            0,   0,   1,   0,   0,   1,    2)
;

insert into skill
    (id, name, aid)
    values
    ( 1, 'Perception', 6),
    (10, 'Firearms', 1),
    (11, 'Simple Weapons', 1),
    (12, 'Exotic Weapons', 1)
;

