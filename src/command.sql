create table command
(
    id integer not null primary key,
    description text
);

create table keymap
(
    key text not null,
    cmid integer not null,
    moid integer not null default 0,

    foreign key (cmid) references command(id),
    foreign key (moid) references gamemode(id)
);

create view vkeymap as
select
    group_concat(keymap.key, ', '),
    command.description
from keymap,
     command
where keymap.cmid = command.id
group by command.id, command.description
order by command.id;

insert into command
    (id, description)
    values
    (0,  'quit'),
    (1,  'refresh'),
    (2,  'ignore / cancel'),
    (7,  'move up'),
    (5,  'move down'),
    (11, 'move north'),
    (12, 'move south'),
    (13, 'move west'),
    (14, 'move east'),
    (15, 'move north west'),
    (16, 'move south west'),
    (17, 'move north east'),
    (18, 'move south east'),
    (21, 'wait'),
    (22, 'search'),
    (23, 'toggle commlink'),
    (24, 'use hypo'),
    (30, 'use object'),
    (31, 'use inventory item'),
    (32, 'shoot firearm / throw wielded object ("apply more Dakka")'),
    (40, 'item slot 1'),
    (41, 'item slot 2'),
    (42, 'item slot 3'),
    (43, 'item slot 4'),
    (44, 'item slot 5'),
    (45, 'item slot 6'),
    (46, 'item slot 7'),
    (47, 'item slot 8'),
    (48, 'item slot 9'),
    (49, 'item slot 10'),
    (50, 'item slot 11'),
    (51, 'item slot 12'),
    (52, 'item slot 13'),
    (53, 'item slot 14'),
    (54, 'item slot 15'),
    (55, 'item slot 16'),
    (56, 'item slot 17'),
    (57, 'item slot 18'),
    (58, 'item slot 19'),
    (59, 'item slot 20'),
    (60, 'item slot 21'),
    (61, 'item slot 22'),
    (62, 'item slot 23'),
    (63, 'item slot 24'),
    (64, 'item slot 25'),
    (65, 'item slot 26'),
    (70, 'target 1'),
    (71, 'target 2'),
    (72, 'target 3'),
    (73, 'target 4'),
    (74, 'target 5'),
    (75, 'target 6'),
    (76, 'target 7'),
    (77, 'target 8'),
    (78, 'target 9'),
    (79, 'target 10'),
    (80, 'target 11'),
    (81, 'target 12'),
    (82, 'target 13'),
    (83, 'target 14'),
    (84, 'target 15'),
    (85, 'target 16'),
    (86, 'target 17'),
    (87, 'target 18'),
    (88, 'target 19'),
    (89, 'target 20'),
    (90, 'target 21'),
    (91, 'target 22'),
    (92, 'target 23'),
    (93, 'target 24'),
    (94, 'target 25'),
    (95, 'target 26');

insert into keymap
    (key, cmid, moid)
    values
    -- mode: roam
    ('Q',  0, 0),
    ('R',  1, 0),
    ('h', 13, 0),
    ('j', 12, 0),
    ('k', 11, 0),
    ('l', 14, 0),
    ('y', 15, 0),
    ('z', 15, 0),
    ('u', 17, 0),
    ('b', 16, 0),
    ('n', 18, 0),
    ('<',  7, 0),
    ('>',  5, 0),
    ('.', 21, 0),
    ('s', 22, 0),
    ('d', 32, 0),
    ('q', 24, 0),
    ('o', 30, 0),
    ('i', 31, 0),
    ('c', 23, 0),

    -- mode: select direction
    (' ',  2, 1),
    ('h', 13, 1),
    ('j', 12, 1),
    ('k', 11, 1),
    ('l', 14, 1),
    ('y', 15, 1),
    ('z', 15, 1),
    ('u', 17, 1),
    ('b', 16, 1),
    ('n', 18, 1),

    -- mode: inventory
    (' ',  2, 2),
    ('a', 40, 2), 
    ('b', 41, 2), 
    ('c', 42, 2), 
    ('d', 43, 2), 
    ('e', 44, 2), 
    ('f', 45, 2), 
    ('g', 46, 2), 
    ('h', 47, 2), 
    ('i', 48, 2), 
    ('j', 49, 2), 
    ('k', 50, 2), 
    ('l', 51, 2), 
    ('m', 52, 2), 
    ('n', 53, 2), 
    ('o', 54, 2), 
    ('p', 55, 2), 
    ('q', 56, 2), 
    ('r', 57, 2), 
    ('s', 58, 2), 
    ('t', 59, 2), 
    ('u', 60, 2), 
    ('v', 61, 2), 
    ('w', 62, 2), 
    ('x', 63, 2), 
    ('y', 64, 2), 
    ('z', 65, 2), 

    -- mode: target
    (' ',  2, 3),
    ('a', 70, 3), 
    ('b', 71, 3), 
    ('c', 72, 3), 
    ('d', 73, 3), 
    ('e', 74, 3), 
    ('f', 75, 3), 
    ('g', 76, 3), 
    ('h', 77, 3), 
    ('i', 78, 3), 
    ('j', 79, 3), 
    ('k', 80, 3), 
    ('l', 81, 3), 
    ('m', 82, 3), 
    ('n', 83, 3), 
    ('o', 84, 3), 
    ('p', 85, 3), 
    ('q', 86, 3), 
    ('r', 87, 3), 
    ('s', 88, 3), 
    ('t', 89, 3), 
    ('u', 90, 3), 
    ('v', 91, 3), 
    ('w', 92, 3), 
    ('x', 93, 3), 
    ('y', 94, 3), 
    ('z', 95, 3) 
    ;

-- data table to match commands to a direction

create table command2direction
(
    cmid integer not null primary key,
    x integer not null,
    y integer not null,

    foreign key (cmid) references command(id)
);

insert into command2direction
    (cmid, x, y)
    values
    (11,  0, -1),
    (12,  0,  1),
    (13, -1,  0),
    (14,  1,  0),
    (15, -1, -1),
    (16, -1,  1),
    (17,  1, -1),
    (18,  1,  1);

create view vuseobject as
select
    null as cid,
    null as tid;

create trigger vuseobjectInsert instead of insert on vuseobject
for each row begin
    insert into message
        (message)
        select
            case when board.tid = 90 then 'You open the door.'
                 when board.tid = 91 then 'You close the door.'
            end as message
        from board, game
        where game.id = 1
          and new.cid = game.pov
          and board.id = new.tid
          and board.tid in (90, 91);

    update board
       set tid = case when tid = 90 then 91
                      when tid = 91 then 90 end
     where id = new.tid
       and tid in (90, 91);
end;

create view vteleport as
select
    null as cid,
    null as oid,
    null as tid;

create view vmove as
select
    null as x,
    null as y,
    null as z;

create view vdirection as
select
    null as cmid,
    null as x,
    null as y;

create trigger vteleportInsert instead of insert on vteleport
for each row begin
    update board
       set cid = new.cid
     where id = new.tid
       and not (select opaque from vboard where id = new.tid);

    update board
       set cid = null
     where id = new.oid
       and (select cid from board where id = new.tid) = new.cid;

    insert into vuseobject
        (cid, tid)
        select
            new.cid as cid,
            new.tid as tid
        from board
        where id = new.oid
          and cid = new.cid;
end;

create view vlevelchange as
select null as z;

create trigger vlevelchangeInsert instead of insert on vlevelchange
for each row begin
    update game set refresh = 1;
    insert into vupdatearchive (z) values (new.z);

    insert into vinvokecommand (cmid, moid) values (22, 0);
end;

create trigger vmoveInsert instead of insert on vmove
for each row begin
    insert into vteleport
        (cid, oid, tid)
        select
            b1.cid as cid,
            b1.id as oid,
            b2.id as tid
        from board as b1,
             board as b2,
             game as g
        where g.id = 1
          and b1.cid = g.pov
          and b2.x = b1.x + coalesce(new.x, 0)
          and b2.y = b1.y + coalesce(new.y, 0)
          and b2.z = b1.z + coalesce(new.z, 0);

    insert into vlevelchange
        (z)
        select
            1 as z
        where coalesce(new.z,0) <> 0;
end;

create trigger vdirectionInsert instead of insert on vdirection
for each row begin
    insert into vuseobject
        (cid, tid)
        select
            b1.cid as cid,
            b2.id as tid
        from board as b1,
             board as b2,
             game as g
        where g.id = 1
          and new.cmid = 30
          and b1.cid = g.pov
          and b2.x = b1.x + coalesce(new.x, 0)
          and b2.y = b1.y + coalesce(new.y, 0)
          and b2.z = b1.z;
end;

create view vinvokecommand as
select
    null as cmid,
    null as moid;

create view vsimulate as
select
    null as turn;

create trigger vinvokecommandInsertRoamSearch instead of insert on vinvokecommand
for each row when new.cmid = 22 and new.moid = 0 begin
    update game
       set turn = turn + 1,
           msid = case when (select max(id) from message) > msid then msid + 1 else msid end;

    insert into vgeneratelevel
        (z)
        select
            p.z - 1
        from board as p,
             game as g
        where g.id = 1
          and p.cid = g.pov
          and not exists (select tid
                            from board as s
                           where s.tid = 4
                             and s.z = p.z);
end;

create trigger vinvokecommandInsertRoam instead of insert on vinvokecommand
for each row when new.cmid is not null and new.cmid <> 22 and new.moid = 0 begin
    update game
       set refresh = (new.cmid = 1),
           turn = case when new.cmid in (1, 30, 31, 32) then turn else turn + 1 end,
           msid = case when (select max(id) from message) > msid then msid + 1 else msid end,
           cmid = case when new.cmid in (30, 31, 32) then new.cmid else null end,
           moid = case when new.cmid in (30, 31, 32) then new.cmid - 29 else 0 end;

    update character
       set commlinkactive = not commlinkactive
     where new.cmid = 23
       and character.id = (select pov from game where id = 1);

    insert into vmove
        (x, y)
        select x, y from command2direction where cmid = new.cmid;

    insert into vmove
        (z)
        select new.cmid - 6
          from board, game
         where new.cmid in (5, 7)
           and game.id = 1
           and board.cid = game.pov
           and board.tid = case when new.cmid = 7 then 5 else 4 end;

    insert into vgameoffsetupdate (gid) select 1 as gid where new.cmid = 1 or (new.cmid >= 11 and new.cmid <= 18);
end;

create trigger vinvokecommandInsertDirection instead of insert on vinvokecommand
for each row when new.cmid is not null and new.moid = 1 begin
    insert into vdirection
        (cmid, x, y)
        select game.cmid, x, y
          from command2direction, game
         where game.id = 1
           and command2direction.cmid = new.cmid;

    update game
       set moid = 0,
           cmid = null,
           turn = turn + 1;
end;

create trigger vinvokecommanInsertInventory instead of insert on vinvokecommand
for each row when new.cmid is not null and new.moid = 2 begin
    update game
       set moid = 0,
           cmid = null,
           turn = turn + 1;
end;

create trigger vinvokecommandInsertTarget instead of insert on vinvokecommand
for each row when new.cmid is not null and new.moid = 3 begin
    update game
       set moid = 0,
           cmid = null,
           turn = turn + 1;
end;

create view vkeypress as
select
    null as key;

create trigger vkeypressInsert instead of insert on vkeypress
for each row when new.key is not null begin
    insert into vinvokecommand
        (cmid, moid)
        select
            keymap.cmid as cmid,
            game.moid as moid
        from keymap, game
        where key = new.key
          and keymap.moid = game.moid
          and game.id = 1;
end;
