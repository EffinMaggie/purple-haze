create table random
(
    b integer not null primary key,
    r integer null
);

create trigger randomInsert after insert on random
for each row when new.r is null begin
    update random set r = random() where b = new.b;
end;

create trigger randomDelete after delete on random
for each row begin
    --insert into random (b,r) values ((select max(b)+1 from random), random());
    insert into random (b,r) values (old.b, random());
end;

create trigger randomUpdate after update on random
for each row when new.r is null begin
    --update random set r = random() where b = old.b;
    delete from random where b = old.b;
end;

insert into random (b) select * from seq8;

create view vd6 as select
    b, (abs(r) % 6) + 1 as d6
from random;

create view vhit as select
    b, d6, d6 > 4 as hit
from vd6;

--create view vd6 as select
--    b, (abs(random()) % 6) + 1 as d6
--from seq8;

--create view vhit as select
--    b, d6, d6 > 4 as hit
--from vd6;

create view vroll as select
    seq8.b as rolls, sum(hit) as hits,
    coalesce((select sum(d6) from vd6 where vd6.b < seq8.b and d6 = 1 group by d6), 0) as glitches
from vhit, seq8
where vhit.b < seq8.b
group by seq8.b
order by seq8.b;

create table test
(
    id integer not null primary key,
    rolls integer not null,
    threshold integer not null default 0,
    hits integer null,
    glitches integer null,
    success boolean null,
    glitch boolean null,
    critical boolean null
);

create trigger testInsert after insert on test
for each row when new.hits is null begin
    insert or replace into test
        (id, rolls, threshold, hits, glitches, success, glitch, critical)
        select new.id, new.rolls, new.threshold, hits, glitches,
               hits > new.threshold,
               (glitches * 2) >= rolls,
               (hits = 0) and ((glitches * 2) >= rolls)
            from vroll
            where vroll.rolls = new.rolls;
    delete from random where b < new.rolls;
end;

create table opposedTest
(
    id integer not null primary key,
    rolls0 integer not null,
    rolls1 integer not null,
    success boolean null,
    glitch0 boolean null,
    critical0 boolean null,
    glitch1 boolean null,
    critical1 boolean null
);

create trigger opposedTestInsert after insert on opposedTest
for each row when new.success is null begin
    insert into test (id, rolls) values (new.id, new.rolls0), (new.id+1, new.rolls1);
    update opposedTest set
        glitch0   = (select glitch   from test where id = new.id),
        critical0 = (select critical from test where id = new.id),
        glitch1   = (select glitch   from test where id = (new.id+1)),
        critical1 = (select critical from test where id = (new.id+1)),
        success   = (select hits from test where id = new.id)
                  > (select hits from test where id = (new.id+1))
        where id = new.id;
end;

create view vdicepool as select
    cid,
    aid,
    null as sid,
    natural,
    rating
from vattribute
union select
    vskill.cid,
    null as aid,
    vskill.sid,
    coalesce(vskill.natural, -1) + vattribute.natural as natural,
    coalesce(vskill.rating, -1)  + vattribute.rating  as rating
from vskill
left join vattribute on vskill.cid = vattribute.cid and vattribute.aid = vskill.aid;
