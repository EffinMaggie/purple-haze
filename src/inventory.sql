create table geartype
(
    id integer not null primary key,
    name text not null
);

create table slottype
(
    id integer not null primary key,
    name text not null
);

create table geartype2slottype
(
    gtid integer not null,
    stid integer not null,

    primary key (gtid, stid),

    foreign key (gtid) references geartype(id),
    foreign key (stid) references slottype(id)
);

create table gear
(
    id integer not null primary key,
    name text not null,
    sid integer null,
    gtid integer not null default 0,
    weight integer null,
    karma integer not null default 1,

    foreign key (sid) references skill(id),
    foreign key (gtid) references geartype(id)
);

create table gear2slot
(
    gid integer not null,
    stid integer not null,
    slots not null default 1,

    foreign key (gid) references gear(id),
    foreign key (stid) references slottype(id)
);

create table geffect
(
    pid integer not null,
    eid integer not null,

    primary key (pid, eid),

    foreign key (pid) references quality(id),
    foreign key (eid) references veffect(id)
);

create table metatype2slot
(
    mid integer not null,
    stid integer not null,
    slots integer not null default 1,

    primary key (mid, stid),

    foreign key (mid) references metatype(id),
    foreign key (stid) references slottype(id)
);

create table item
(
    id integer not null primary key,
    gid integer not null,
    maid integer null,
    identified boolean not null default 0,
    owid integer null,

    foreign key (gid) references gear(id),
    foreign key (maid) references corporation(id),
    foreign key (owid) references character(id)
);

create table citem
(
    cid integer not null,
    iid integer not null,

    foreign key (cid) references character(id),
    foreign key (iid) references item(id)
);

create table iitem
(
    iid integer not null,
    siid integer not null,

    foreign key (iid) references item(id),
    foreign key (siid) references item(id)
);

insert into geartype
    (id, name)
    values
    ( 0, 'miscellaneous'),
    ( 1, 'suit'),
    ( 2, 'boots'),
    ( 3, 'helmet'),
    ( 4, 'mask'),
    ( 5, 'backpack'),
    ( 6, 'messenger bag'),
    (11, 'hypospray'),
    (12, 'vial'),
    (13, 'tool'),
    (20, 'credstick'),
    (21, 'tag')
;

insert into slottype
    (id, name)
    values
    ( 1, 'suit'),
    ( 2, 'boots'),
    ( 3, 'helmet'),
    ( 4, 'mask'),
    ( 5, 'backpack'),
    ( 6, 'bag'),
    ( 7, 'neck'),
    (11, 'strap'),
    (12, 'pocket'),
    (21, 'armament pad')
;

insert into geartype2slottype
    (gtid, stid)
    values
    ( 0, 12),
    ( 1, 1),
    ( 2, 2),
    ( 3, 3),
    ( 4, 4),
    ( 5, 5),
    ( 6, 6),
    (11,11),
    (12,11),
    (13,12),
    (20,12),
    (21, 7)
;

-- gear not to forget:
--   dart guns
--   tasers
--   taser knuckles
--   chains
--   rail guns
--   coil guns
--   ammo packs
--   foof vials
--   hallucinogenics
--   cyanide pills (to give up)
--   breathing mask
--   turret kits (backpack, messenger bag)
-- clutter:
--   gems

insert into gear
    (id, name, sid, gtid, weight, karma)
    values
    ( 0, 'credstick',             null, 20, 0.01, 0),
    ( 1, 'engineer''s jump suit', null,  1, 5, 50),
    ( 2, 'engineer''s boots',     null,  2, 1, 10),
    ( 3, 'breathing mask',        null,  4, 0.5, 10),
    ( 4, 'dog tag',               null, 21, 0.5, 10),
    (10, 'shoulder holster',      null,  5, 0.5, 10)
;

insert into gear2slot
    (gid, stid, slots)
    values
    ( 1, 11, 10),
    ( 1, 12,  6),
    ( 1, 21,  1),
    ( 2, 11,  2),
    (10, 11,  6),
    (10, 21,  1)
;

insert into metatype2slot
    (mid, stid, slots)
    values
    -- human
    ( 0,  1,  1),
    ( 0,  2,  1),
    ( 0,  3,  1),
    ( 0,  4,  1),
    ( 0,  5,  1),
    ( 0,  6,  1)
;

create view vgearslotusage as
select
    gear.id as gid,
    geartype2slottype.stid as stid,
    1 as slots
from gear,
     geartype2slottype
where gear.gtid = geartype2slottype.gtid;

create view vcharactermetatypeslot as
select
    c.id as cid,
    m2s.stid as stid,
    m2s.slots as slots
from metatype2slot as m2s,
     character as c
where c.mid = m2s.mid;

create view vcharactergearslot as
select
    c.cid as cid,
    g2s.stid as stid,
    sum(g2s.slots) as slots
from gear2slot as g2s,
     citem as c,
     item as i
where c.iid = i.id
  and i.gid = g2s.gid
group by c.cid, g2s.stid;

create view vgearslot as
select
    g.id as gid,
    g2s.stid as stid
from gear as g,
     geartype2slottype as g2s
where g.gtid = g2s.gtid;

create view vcharacterslot as
select
    c.id as cid,
    s.id as stid,
    coalesce(ms.slots, 0) + coalesce(gs.slots, 0) as slots
from character as c,
     slottype as s
left join vcharactermetatypeslot as ms on c.id = ms.cid and s.id = ms.stid
left join vcharactergearslot as gs on c.id = gs.cid and s.id = gs.stid
group by c.id, s.id;

create view vitem as
select
    item.id as id,
    corporation.id as maid,
    gear.id as gid,
    geartype2slottype.stid as stid,
    corporation.name || ' ' || gear.name as name
from item, corporation, gear, geartype2slottype
where item.maid = corporation.id
  and item.gid = gear.id
  and gear.gtid = geartype2slottype.gtid;

create view vcharacteritem as
select
    citem.cid as cid,
    vitem.id as iid,
    vitem.maid as maid,
    vitem.gid as gid,
    vitem.stid as stid,
    vitem.name as name
from citem, vitem
where vitem.id = citem.iid;

create view vcharacteritemislot as
select
    (select count(0)
      from vcharacteritem as i2
     where i2.cid = i1.cid
       and i2.iid <= i1.iid) as islot,
    i1.cid as cid,
    i1.iid as iid,
    i1.maid as maid,
    i1.gid as gid,
    i1.stid as stid,
    i1.name as name
from vcharacteritem as i1;

create trigger vcharacteritemInsert instead of insert on vcharacteritem
for each row begin
    insert into item
        (gid, maid, owid)
        values
        (new.gid,
         coalesce(new.maid, (select cnid from character where id = new.cid)),
         new.cid);

    insert into citem
        (cid, iid)
        values
        (new.cid, last_insert_rowid());
end;

create trigger itemInsert after insert on item
for each row begin
    update item
       set maid = (select corporation.id
                     from corporation
                    order by random()
                    limit 1)
     where id = new.id
       and new.maid is null;
end;
