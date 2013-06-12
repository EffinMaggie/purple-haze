create table room
(
    id integer not null primary key,
    x integer not null,
    y integer not null,
    width integer not null,
    height integer not null,
    area integer,
    split boolean,
    cx integer default 0,
    cy integer default 0,
    rid integer null
);

create table roomconnection
(
    rid1 integer not null,
    rid2 integer not null,

    primary key (rid1, rid2),

    foreign key (rid1) references room(id),
    foreign key (rid2) references room(id)
);

create table scratchboard
(
    id integer not null primary key,
    x integer not null,
    y integer not null,

    tid integer not null,

    foreign key (tid) references tile(id)
);

create unique index scratchboardXY on scratchboard (x, y);

create view vgeneratelevel as
select null as z;

create view vroomfill as
select null as rid;

create view vroomwall as
select null as rid,
       null as tid;

create view vroompad as
select null as rid,
       null as tidv,
       null as tidh;

create view vroomsplit as
select null as rid;

create view vroomsplith as
select null as rid,
       null as offset;

create view vroomsplitv as
select null as rid,
       null as offset;

create view vaddclutter as
select null as z;

create view vroomconnection as
select rid1, rid2
from roomconnection
where rid1 < rid2;

create trigger vgeneratelevelInsert instead of insert on vgeneratelevel
for each row begin
    insert or replace into scratchboard
        (x, y, tid)
        select
            x.b as x,
            y.b as y,
            2 as tid
        from seq8 as x,
             seq8 as y,
             game
        where game.id = 1
          and x.b < game.levelwidth
          and y.b < game.levelheight;

    insert into room
        (x, y, width, height)
        select
            0 as x,
            0 as y,
            levelwidth - 1 as width,
            levelheight - 1 as height
        from game
        where game.id = 1;

    insert into vroompad (rid) select room.id as rid from room;
    insert into vroompad (rid) select room.id as rid from room;

    insert into vroomsplit (rid) select room.id as rid from room where split;
    insert into vroomsplit (rid) select room.id as rid from room where split;
    insert into vroomsplit (rid) select room.id as rid from room where split;
    insert into vroomsplit (rid) select room.id as rid from room where split;
    insert into vroomsplit (rid) select room.id as rid from room where split;
    insert into vroomsplit (rid) select room.id as rid from room where split;
    insert into vroomsplit (rid) select room.id as rid from room where split;
    insert into vroomsplit (rid) select room.id as rid from room where split;

    insert into vroompad (rid) select room.id as rid from room order by random() limit 10;
    insert into vroompad (rid) select room.id as rid from room order by random() limit 7;
    insert into vroompad (rid) select room.id as rid from room order by random() limit 5;
    insert into vroompad (rid) select room.id as rid from room order by random() limit 5;
    insert into vroompad (rid) select room.id as rid from room order by random() limit 5;

    insert into vroomfill (rid)
    select room.id as rid
      from room
     order by area desc
     limit 50 offset (select levelrooms
                        from game
                       where game.id = 1);

    insert into vroomwall (rid, tid) select room.id as rid, 20 as tid from room;

    insert into vroompad (rid, tidv, tidh) select room.id as rid, 10 as tidv, 11 as tidh from room;
    insert into vroompad (rid, tidv, tidh) select room.id as rid, 12 as tidv, 13 as tidh from room;
    insert into vroompad (rid, tidv, tidh) select room.id as rid, 14 as tidv, 15 as tidh from room;
    insert into vroompad (rid, tidv, tidh) select room.id as rid, 16 as tidv, 17 as tidh from room;
    insert into vroompad (rid, tidv, tidh) select room.id as rid, 18 as tidv, 19 as tidh from room;

    insert into vaddclutter (z) values (new.z);

    insert into vroomconnection (rid1, rid2) select rid1, rid2 from vroomconnection;

    delete
      from scratchboard
     where id in (select b.id
                    from scratchboard as b,
                         scratchboard as q
                   where abs (b.y - q.y) < 2
                     and abs (b.x - q.x) < 2
                     and b.tid = 1
                     and q.tid in (1, 20)
                   group by b.id
                   having count(*) = 9);

    update scratchboard
       set tid = 7
     where id in (select b.id
                    from scratchboard as b,
                         scratchboard as q
                   where b.x = q.x and (b.y = q.y - 1 or b.y = q.y + 1)
                     and b.tid in (1, 20, 90)
                     and q.tid in (2, 10, 11)
                     group by b.id
                     having count(*) = 2)
        or id in (select b.id
                    from scratchboard as b,
                         scratchboard as q
                   where b.y = q.y and (b.x = q.x - 1 or b.x = q.x + 1)
                     and b.tid in (1, 20, 90)
                     and q.tid in (2, 10, 11)
                     group by b.id
                     having count(*) = 2)
        or id in (select b.id
                    from scratchboard as b,
                         scratchboard as q
                   where abs(b.y - q.y) < 2
                     and abs(b.x - q.x) < 2
                     and b.tid = 90
                     and q.tid = 90
                     group by b.id
                     having count(*) > 1);

    update scratchboard
       set tid = 7
     where id in (select b.id
                    from scratchboard as b,
                         scratchboard as q
                   where b.x = q.x and (b.y = q.y - 1 or b.y = q.y + 1)
                     and b.tid = 90
                     and q.tid not in (1, 20)
                     group by b.id
                     having count(*) <> 0)
       and id in (select b.id
                    from scratchboard as b,
                         scratchboard as q
                   where b.y = q.y and (b.x = q.x - 1 or b.x = q.x + 1)
                     and b.tid = 90
                     and q.tid not in (1, 20)
                     group by b.id
                     having count(*) <> 0);

    delete
      from scratchboard
     where (   x = 0
            or x = (select game.levelwidth - 1
                      from game
                     where game.id = 1)
            or y = 0
            or y = (select game.levelheight - 1
                      from game
                     where game.id = 1) );

    delete
      from board
     where z = new.z;

    insert or replace into board
        (x, y, z, tid)
        select
            x, y, new.z as z, tid
        from scratchboard;

    update board
       set tid = 5
     where id = (select b.id
                   from board as b,
                        board as q
                  where q.tid in (2, 12, 13, 14, 15, 16, 17, 18, 19)
                    and b.tid = 2
                    and b.z = new.z
                    and q.z = new.z + 1
                    and q.x = b.x
                    and q.y = b.y
                  order by random ()
                  limit 1);

    update board
       set tid = 4
     where id = (select b.id
                   from board as b,
                        board as q
                  where q.tid = 5
                    and b.z = new.z + 1
                    and q.z = new.z
                    and q.x = b.x
                    and q.y = b.y
                  limit 1);

    delete
      from scratchboard;

    delete
      from room;
end;

create trigger vroomfillInsert instead of insert on vroomfill
for each row begin
    insert or replace into scratchboard
        (x, y, tid)
        select
            scratchboard.x as x,
            scratchboard.y as y,
            1 as tid
        from room, scratchboard
        where room.id = new.rid
          and scratchboard.x >= room.x and scratchboard.x <= room.x + room.width
          and scratchboard.y >= room.y and scratchboard.y <= room.y + room.height;

    delete
      from room
     where room.id = new.rid;
end;

create trigger vaddclutterInsert instead of insert on vaddclutter
for each row begin
    update scratchboard
       set tid = 50
     where id in (select id
                    from scratchboard
                   where tid = 10
                   order by random()
                   limit 30 );

    update scratchboard
       set tid = 51
     where id in (select id
                    from scratchboard
                   where tid = 11
                   order by random()
                   limit 30 );
end;

create trigger vroomconnectionInsert instead of insert on vroomconnection
for each row begin
    insert or replace into scratchboard
        (x, y, tid)
        select
            scratchboard.x,
            scratchboard.y,
            case when tid = 20 then 90 else 6 end as tid
        from scratchboard, room as r1, room as r2
        where r1.id = new.rid1
          and r2.id = new.rid2
          and (    (   (   ( scratchboard.x >= r1.cx and scratchboard.x <= r2.cx )
                        or ( scratchboard.x <= r1.cx and scratchboard.x >= r2.cx ) )
                    and scratchboard.y = r1.cy )
               or  (   (   ( scratchboard.y >= r1.cy and scratchboard.y <= r2.cy )
                        or ( scratchboard.y <= r1.cy and scratchboard.y >= r2.cy ) )
                    and scratchboard.x = r2.cx ) );
end;

create trigger vroomwallInsert instead of insert on vroomwall
for each row begin
    insert or replace into scratchboard
        (x, y, tid)
        select
            scratchboard.x as x,
            scratchboard.y as y,
            coalesce(new.tid, 20) as tid
        from room, scratchboard
        where room.id = new.rid
          and (
                  (    scratchboard.x = room.x - 1
                   and scratchboard.y >= room.y - 1 and scratchboard.y <= room.y + room.height + 1)
               or (    scratchboard.x = room.x + room.width + 1
                   and scratchboard.y >= room.y - 1 and scratchboard.y <= room.y + room.height + 1)
               or (    scratchboard.y = room.y - 1
                   and scratchboard.x >= room.x - 1 and scratchboard.x <= room.x + room.width + 1)
               or (    scratchboard.y = room.y + room.height + 1
                   and scratchboard.x >= room.x - 1 and scratchboard.x <= room.x + room.width + 1)
              );
end;

create trigger vroompadInsert instead of insert on vroompad
for each row begin
    insert or replace into scratchboard
        (x, y, tid)
        select
            scratchboard.x as x,
            scratchboard.y as y,
            case when scratchboard.x = room.x
                   or scratchboard.x = room.x + room.width then coalesce(new.tidv, 1)
                                                           else coalesce(new.tidh, 1)
            end as tid
        from room, scratchboard
        where room.id = new.rid
          and room.height > 2
          and room.width > 2
          and (
                  (    scratchboard.x = room.x
                   and scratchboard.y >= room.y and scratchboard.y <= room.y + room.height)
               or (    scratchboard.x = room.x + room.width
                   and scratchboard.y >= room.y and scratchboard.y <= room.y + room.height)
               or (    scratchboard.y = room.y
                   and scratchboard.x >= room.x and scratchboard.x <= room.x + room.width)
               or (    scratchboard.y = room.y + room.height
                   and scratchboard.x >= room.x and scratchboard.x <= room.x + room.width)
              );

    update room
       set x      = x + 1,
           y      = y + 1,
           width  = width - 2,
           height = height - 2
     where id = new.rid
       and room.height > 2
       and room.width > 2;
end;

create trigger vroomsplitInsert instead of insert on vroomsplit
for each row begin
    insert into vroomsplith
        (rid, offset)
        select
            room.id as rid,
            coalesce(abs(random()) % (room.width - game.levelsplitwidth), 0) + 7 as offset
        from room, game
        where game.id
          and room.id = new.rid
          and room.width > room.height;

    insert into vroomsplitv
        (rid, offset)
        select
            room.id as rid,
            coalesce(abs(random()) % (room.height - game.levelsplitheight), 0) + 3 as offset
        from room, game
        where game.id = 1
          and room.id = new.rid;
end;

create trigger vroomsplithInsert instead of insert on vroomsplith
for each row begin
    insert or replace into scratchboard
        (x, y, tid)
        select
            scratchboard.x as x,
            scratchboard.y as y,
            1 as tid
        from room, scratchboard
        where room.id = new.rid
          and scratchboard.y >= room.y and scratchboard.y <= (room.y + room.height)
          and scratchboard.x = room.x + new.offset;

    insert into room
        (x, y, width, height, rid)
        select
            room.x + new.offset + 1 as x,
            room.y as y,
            room.width - new.offset - 1 as width,
            room.height as height,
            new.rid as rid
        from room
        where room.id = new.rid;

    update room
       set width = new.offset - 1
     where id = new.rid;
end;

create trigger vroomsplitvInsert instead of insert on vroomsplitv
for each row begin
    insert or replace into scratchboard
        (x, y, tid)
        select
            scratchboard.x as x,
            scratchboard.y as y,
            1 as tid
        from room, scratchboard
        where room.id = new.rid
          and scratchboard.y = room.y + new.offset
          and scratchboard.x >= room.x and scratchboard.x <= (room.x + room.width);

    insert into room
        (x, y, width, height, rid)
        select
            room.x as x,
            room.y + new.offset + 1 as y,
            room.width as width,
            room.height - new.offset - 1 as height,
            new.rid as rid
        from room
        where room.id = new.rid;

    update room
       set height = new.offset - 1
     where id = new.rid;
end;

create trigger roomInsert after insert on room
for each row begin
    update room
       set area = width * height,
           split =    (    width > (select levelsplitwidth
                                      from game
                                     where game.id = 1) 
                        or height > (select levelsplitheight
                                       from game
                                      where game.id = 1 ) )
                   and width * height > (select levelsplitarea
                                           from game
                                          where game.id = 1),
           cx = x + 1 + case when width - 3 > 0 then coalesce(abs(random()) % (width-3),0) else 0 end,
           cy = y + 1 + case when height - 3 > 0 then coalesce(abs(random()) % (height-3),0) else 0 end
     where id = new.id;

    insert or ignore into roomconnection
        (rid1, rid2)
        select
            new.id as rid1,
            rid as rid2
        from room
        where room.id = new.id
          and rid is not null;
end;

create trigger roomUpdate after update on room
for each row begin
    update room
       set area = width * height,
           split =    (    width > (select levelsplitwidth
                                      from game
                                     where game.id = 1) 
                        or height > (select levelsplitheight
                                       from game
                                      where game.id = 1 ) )
                   and width * height > (select levelsplitarea
                                           from game
                                          where game.id = 1),
           cx = x + 1 + case when width - 3 > 0 then coalesce(abs(random()) % (width-3),0) else 0 end,
           cy = y + 1 + case when height - 3 > 0 then coalesce(abs(random()) % (height-3),0) else 0 end
     where id = new.id;
end;

create trigger roomDelete before delete on room
for each row begin
    insert or ignore into roomconnection
        (rid1, rid2)
        select
            rc1.rid2 as rid1,
            rc2.rid2 as rid2
        from roomconnection as rc1,
             roomconnection as rc2
        where rc1.rid1 = old.id
          and rc2.rid1 = old.id
          and rc1.rid2 <> rc2.rid2;

    delete from roomconnection where rid1 = old.id or rid2 = old.id;
end;

create trigger roomconnectionInsert after insert on roomconnection
for each row begin
    insert or ignore into roomconnection
        (rid1, rid2)
        values
        (new.rid2, new.rid1);
end;
