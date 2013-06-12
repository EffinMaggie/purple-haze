create table character
(
    id integer not null primary key,
    pid integer,
    mid integer,
    cnid integer,
    name text,
    agility integer,
    reaction integer,
    strength integer,
    intuition integer,
    logic integer,
    willpower integer,
    karma integer null,
    karmacommit integer not null default 0,
    karmatotal integer not null default 0,
    commlinkactive boolean not null default 1,
    sentient boolean not null default 0,

    foreign key (pid) references profile(id),
    foreign key (mid) references metatype(id),
    foreign key (cnid) references corporation(id)
);

create trigger characterInsert after insert on character
for each row when new.mid is null begin
    insert or replace into character
        (id, pid, mid, cnid, name,
         agility, reaction, strength, intuition, logic, willpower,
         karma)
        select
            new.id,
            coalesce (new.pid, (select id as pid from profile order by random() limit 1)),
            metatype.id,
            coalesce (new.cnid, (select id from corporation order by random() limit 1)) as cnid,
            coalesce (new.name, metatype.name) as name,
            (select minvalue from vrange where mid = metatype.id and aid = 1) as agility,
            (select minvalue from vrange where mid = metatype.id and aid = 3) as reaction,
            (select minvalue from vrange where mid = metatype.id and aid = 4) as strength,
            (select minvalue from vrange where mid = metatype.id and aid = 6) as intuition,
            (select minvalue from vrange where mid = metatype.id and aid = 7) as logic,
            (select minvalue from vrange where mid = metatype.id and aid = 8) as willpower,
            0
        from metatype
        left join race on race.id = metatype.rid
        where (new.sentient and (race.sentient or metatype.sentient))
           or (not new.sentient)
        order by random()
        limit 1;
    insert into cattribute
        (cid, aid, rating)
        select
            new.id as cid,
            vrange.aid as aid,
            vrange.minvalue as rating
        from vrange
        inner join character on character.id = new.id and character.mid is vrange.mid
        where vrange.aid > 12
          and vrange.minvalue is not null;
    insert into cskill
        (cid, sid, rating)
        select
            new.id as cid,
            vrange.sid as sid,
            vrange.minvalue as rating
        from vrange
        inner join character on character.id = new.id and character.mid is vrange.mid
        where vrange.sid is not null
          and vrange.minvalue is not null;
    insert into next
        (cid)
        values
        (new.id);
    insert into vspendkarma
        (cid, karma)
        select
            character.id as cid,
            coalesce (new.karma, vrace.karma) as karma
        from vrace
        inner join character on vrace.mid is character.mid
        where character.id = new.id;

    -- starting gear: credstick, jump suit, boots, breathing mask and dog tag
    insert into vcharacteritem
        (cid, gid)
        values
        (new.id, 4),
        (new.id, 1),
        (new.id, 2),
        (new.id, 3),
        (new.id, 0);
end;

create table cquality
(
    cid integer not null,
    pid integer not null,

    primary key (cid, pid),

    foreign key (cid) references character(id),
    foreign key (pid) references quality(id)
);

create table cattribute
(
    cid integer not null,
    aid integer not null,

    rating integer not null default 0,

    primary key (cid, aid),

    foreign key (cid) references character(id),
    foreign key (aid) references attribute(id)
);

create view vattributebase as select
    character.id as cid,
    attribute.id as aid,
    (case when attribute.agility   > 0 then attribute.agility   * character.agility    else 0 end +
     case when attribute.reaction  > 0 then attribute.reaction  * character.reaction   else 0 end +
     case when attribute.strength  > 0 then attribute.strength  * character.strength   else 0 end +
     case when attribute.intuition > 0 then attribute.intuition * character.intuition  else 0 end +
     case when attribute.logic     > 0 then attribute.logic     * character.logic      else 0 end +
     case when attribute.willpower > 0 then attribute.willpower * character.willpower  else 0 end)
    as rating
from character, attribute;

create view vattributenatural as select
    vattributebase.cid, vattributebase.aid,
    vattributebase.rating + coalesce (cattribute.rating, 0) as rating
from vattributebase
left join cattribute on vattributebase.cid = cattribute.cid and vattributebase.aid = cattribute.aid;

create view vattribute as select
    cid, aid,
    rating as natural,
    rating as rating
from vattributenatural;

create table cskill
(
    cid integer not null,
    sid integer not null,

    rating integer not null default 0,

    primary key (cid, sid),

    foreign key (cid) references character(id),
    foreign key (sid) references skill(id)
);

create view vskillnatural as select
    character.id as cid,
    skill.id as sid,
    skill.aid,
    cskill.rating
from character
left join skill
left join cskill on cskill.cid = character.id and cskill.sid = skill.id;

create view vskill as select
    cid, sid, aid,
    rating as natural,
    rating as rating
from vskillnatural;

create table cconduct
(
    coid integer not null,

    foreign key (coid) references conduct(id)
);

--

create view vcharacter as
select
    character.id as id,
    character.pid as pid,
    character.mid as mid,
    character.name as name,
    character.karma as karma,
    character.karmatotal as karmatotal,
    character.commlinkactive as commlinkactive
from character,
     cattribute
where character.id = cattribute.cid
group by character.id, character.pid, character.mid, character.name, character.karma;

--

create table next
(
    cid integer not null,
    aid integer null,
    sid integer null,

    primary key (cid),

    foreign key (cid) references character(id),
    foreign key (aid) references attribute(id),
    foreign key (sid) references skill(id)
);

create trigger nextInsert after insert on next
for each row when new.aid is null and new.sid is null begin
    insert or replace into next
        (cid, aid, sid)
        select
            new.cid,
            vprofileaffinity.aid,
            vprofileaffinity.sid
        from vprofileaffinity
        inner join character on character.id = new.cid and vprofileaffinity.pid = character.pid
        left join vattributenatural on vattributenatural.cid = new.cid and vprofileaffinity.aid = vattributenatural.aid
        left join vskillnatural on vskillnatural.cid = new.cid and vprofileaffinity.sid = vskillnatural.sid
        left join vattributenatural as vattributenatural2 on vattributenatural2.cid = new.cid and vskillnatural.aid = vattributenatural2.aid
        left join vrange on vrange.mid = character.mid and vrange.aid is vprofileaffinity.aid and vrange.sid is vprofileaffinity.sid
        where ((vprofileaffinity.sid is null) or (vattributenatural2.rating is not null))
          and ((vrange.maxvalue is null) or
              (((vprofileaffinity.sid is null) or (coalesce(vskillnatural.rating,0) < vrange.maxvalue))
           and ((vprofileaffinity.aid is null) or (coalesce(vattributenatural.rating,0) < vrange.maxvalue))))
        order by random()
        limit 1;
end;

create trigger nextDelete after delete on next
for each row begin
    insert into next (cid) values (old.cid);
end;

create view vnext as select
    cid,
    aid,
    sid,
    case when aid is null then 0 else (select karma from attribute where id = aid) end +
    case when sid is null then 0 else 3 end
    as karma
from next;

create view vkarmainc as
select
    null as cid;

create trigger karmaincInsert instead of insert on vkarmainc
for each row begin
    update character set karma = karma + 1 where id = new.cid;
    update character set
        agility = case when exists(select 1 from next where cid = character.id and aid = 1) then coalesce(agility + 1, 1) else agility end,
        reaction = case when exists(select 1 from next where cid = character.id and aid = 3) then coalesce(reaction + 1, 1) else reaction end,
        strength = case when exists(select 1 from next where cid = character.id and aid = 4) then coalesce(strength + 1, 1) else strength end,
        intuition = case when exists(select 1 from next where cid = character.id and aid = 6) then coalesce(intuition + 1, 1) else intuition end,
        logic = case when exists(select 1 from next where cid = character.id and aid = 7) then coalesce(logic + 1, 1) else logic end,
        willpower = case when exists(select 1 from next where cid = character.id and aid = 8) then coalesce(willpower + 1, 1) else willpower end,
        karmacommit = karmacommit + (select karma from vnext where cid = character.id)
        where karma >= (select karma from vnext where cid = character.id);
    insert or replace into cattribute
        (cid, aid, rating)
        select
            vnext.cid, vnext.aid,
            coalesce(rating,0) + 1
            from vnext
            inner join character on character.id = vnext.cid
            left join cattribute on cattribute.cid = vnext.cid and cattribute.aid = vnext.aid
            where vnext.aid is not null
              and vnext.aid > 12
              and character.karma >= vnext.karma;
    insert or replace into cskill
        (cid, sid, rating)
        select
            vnext.cid, vnext.sid,
            coalesce(rating,0) + 1
            from vnext
            inner join character on character.id = vnext.cid
            left join cskill on cskill.cid = vnext.cid and cskill.sid = vnext.sid
            where vnext.sid is not null
              and character.karma >= vnext.karma;
    delete from next where
        exists (select 1 from character inner join vnext on character.id = vnext.cid where vnext.cid = next.cid and character.karma >= vnext.karma);
    update character set
        karma = karma - karmacommit,
        karmacommit = 0;
end;

create view vspendkarma as
select
    null as cid,
    null as karma;

create trigger spendkarmaInsert instead of insert on vspendkarma
for each row begin
    insert into vkarmainc
        (cid)
        select
            new.cid
        from vseq16
        where b < new.karma;

    update character
       set karmatotal = karmatotal + new.karma
     where id = new.cid;
end;
