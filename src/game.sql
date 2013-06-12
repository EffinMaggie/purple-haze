-- basic game metadata

create table message
(
    id integer not null primary key,
    message text not null,
    popup boolean not null default 0
);

create table gamemode
(
    id integer not null primary key,
    description text
);

insert into gamemode
    (id, description)
    values
    (0,  'Roam'),
    (1,  'Select Direction'),
    (2,  'Select Inventory Slot'),
    (3,  'Select Target');

create table game
(
    id integer not null primary key check (id = 1),
    pov integer not null default 1,
    columns integer not null default 80,
    lines integer not null default 25,
    offsetx integer not null default 1,
    offsety integer not null default 4,
    refresh integer not null default 1,
    turn integer not null default 0,
    moid integer not null default 0,
    cmid integer null,
    msid integer not null default -1,
    -- level generator parameters
    levelwidth integer not null default 90,
    levelheight integer not null default 40,
    levelrooms integer not null default 10,
    levelsplitwidth integer not null default 15,
    levelsplitheight integer nto null default 8,
    levelsplitarea integer not null default 200,

    -- foreign key (pov) references character(id)
    foreign key (moid) references gamemode(id)
    -- foreign key (cmid) references command(id)
    --foreign key (msid) references message(id)
);

create view vgameoffset as
select null as x,
       null as y,
       null as z,
       null as width,
       null as height,
       null as gid,
       null as columns,
       null as lines;

create view vgameoffsetupdate as
select null as gid;

create trigger gameInsert after insert on game
for each row begin
    insert into character
        (name, karma, sentient)
        values
        ('J. Doe', 500, 1);

    update game
       set pov = last_insert_rowid()
     where game.id = new.id;

    insert into vgeneratelevel
        (z)
        values
        (0), (-1);

    update board
       set cid = (select pov
                    from game
                   where id = new.id),
           tid = 5
     where  id = (select id
                    from vboard
                   where z = 0
                     and not opaque
                   order by random()
                   limit 1);

    insert into vgameoffsetupdate
        (gid)
        values
        (new.id);
end;

create trigger gameUpdate after update on game
for each row when old.lines <> new.lines or old.columns <> new.columns or old.moid <> new.moid begin
    insert into vgameoffsetupdate
        (gid)
        values
        (new.id);
end;

create trigger vgameoffsetInsert instead of insert on vgameoffset
for each row begin
    update game
       set offsetx = case when new.width < new.columns then 1 else  - ((new.x * (new.width-new.columns+1)) / (new.width)) end,
           offsety = case when new.height < new.lines then 4 else 3 - ((new.y * (new.height-new.lines+4)) / (new.height)) end,
           refresh = 1
     where id = new.gid
       and (   offsetx <> case when new.width < new.columns then 1 else  - ((new.x * (new.width-new.columns+1)) / (new.width)) end
            or offsety <> case when new.height < new.lines then 4 else 3 - ((new.y * (new.height-new.lines+4)) / (new.height)) end );
end;

create trigger vgameoffsetupdateInsert instead of insert on vgameoffsetupdate
for each row begin
    insert into vgameoffset
        (x, y, z, width, height, gid, columns, lines)
        select board.x as x,
               board.y as y,
               board.z as z,
               game.levelwidth as width,
               game.levelheight as height,
               game.id as gid,
               game.columns + case when game.moid = 2 then -50 else 0 end as columns,
               game.lines as lines
          from board, game
         where game.id = 1
           and board.cid = game.pov;
end;
