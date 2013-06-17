create table nameusage
(
    id integer not null primary key,
    description text not null
);

insert into nameusage
    (id, description)
    values
    (1, 'human female'),
    (2, 'human male'),
    (3, 'corporation'),
    (4, 'experiment')
;

create table namescheme
(
    id integer not null primary key,
    nuid integer not null,
    description text not null,
    prio integer not null,

    foreign key (nuid) references nameusage(id)
);

insert into namescheme
    (id, nuid, description, prio)
    values
    (1,  1,  'first/female last', 20),
    (2,  2,  'first/male last',   20)
;

create table namecomponent
(
    id integer not null primary key,
    description text not null
);

insert into namecomponent
    (id, description)
    values
    (1,  'first name, female'),
    (2,  'first name, male'),
    (3,  'first name, any'),
    (4,  'last name'),
    (5,  'hyphen'),
    (6,  'space'),
    (7,  'literal'),
    (8,  'branch')
;

create table nametemplate
(
    id integer not null primary key,
    nsid integer not null,
    pos integer not null,
    ncid integer not null,
    literal text null,
    minlength integer not null default 2,
    maxlength integer not null default 16,
    maxsublen integer not null default 16,

    foreign key (nsid) references namescheme(id),
    foreign key (ncid) references namecomponent(id)
);

insert into nametemplate
    (nsid, pos, ncid, literal)
    values
    (1, 1, 1, null),
    (1, 2, 6, null),
    (1, 3, 4, null),
    (2, 1, 2, null),
    (2, 2, 6, null),
    (2, 3, 4, null)
;

create table nametemplateresult
(
    refid integer not null,
    ntid integer not null,
    result text null,

    foreign key (ntid) references nametemplate(id)
);

create table nameresult
(
    refid integer not null primary key,
    result text null
);

create view vnamecharacter as
select
    null as cid;

create view vnamecharacteru as
select
    null as cid,
    null as nuid;

create view vcreatename as
select
    null as nsid,
    null as refid;

create view vcreatenamewusage as
select
    null as nuid,
    null as refid;

create trigger vnamecharacterInsert instead of insert on vnamecharacter
for each row begin
    insert into vnamecharacteru
        (cid, nuid)
        select new.cid as cid,
               racenameusage.nuid as nuid
          from racenameusage, metatype, character
         where racenameusage.rid = metatype.rid
           and metatype.id = character.mid
           and character.id = new.cid
           and character.sex = racenameusage.sex;
end;

create trigger vnamecharacteruInsert instead of insert on vnamecharacteru
for each row begin
    insert into vcreatenamewusage
        (nuid, refid)
        values
        (new.nuid, 100000 + new.cid);

    update character
       set name = coalesce ((select result
                               from nameresult
                              where refid = 100000 + new.cid),
                            name)
     where id = new.cid;
end;

create trigger vcreatenameInsert instead of insert on vcreatename
for each row begin
    insert into nametemplateresult
        (refid, ntid)
        select new.refid as refid,
               nametemplate.id as ntid
          from nametemplate
         where nametemplate.nsid = new.nsid
         order by nametemplate.pos;

    update nametemplateresult
       set result = upper(substr(result, 1, 1)) || lower(substr(result, 2))
     where refid = new.refid;

    insert or replace into nameresult
        (refid, result)
        select new.refid as refid,
               group_concat(result, '') as result
          from nametemplateresult, nametemplate
         where nametemplateresult.ntid = nametemplate.id
           and nametemplateresult.refid = new.refid
         order by nametemplate.pos;
end;

create trigger vcreatenamewusageInsert instead of insert on vcreatenamewusage
for each row begin
    insert into vcreatename
        (nsid, refid)
        select namescheme.id,
               new.refid
          from namescheme, seq8
         where namescheme.nuid = new.nuid
           and seq8.b < namescheme.prio
         order by random()
         limit 1;
end;

create trigger nametemplateresultInsertFirstNameF after insert on nametemplateresult
for each row when (select ncid from nametemplate where id = new.ntid) = 1 begin
    insert into markovconstruct
        (id)
        select 3 as id
          from seq8
         where seq8.b < 10;

    insert into vautoconstruct (steps) values (20);

    update nametemplateresult
       set result = (select result
                       from markovresult
                      where id = 3
                      order by random()
                      limit 1)
     where ntid = new.ntid
       and result is null;
end;

create trigger nametemplateresultInsertFirstNameM after insert on nametemplateresult
for each row when (select ncid from nametemplate where id = new.ntid) = 2 begin
    insert into markovconstruct
        (id)
        select 4 as id
          from seq8
         where seq8.b < 10;

    insert into vautoconstruct (steps) values (20);

    update nametemplateresult
       set result = (select result
                       from markovresult
                      where id = 4
                      order by random())
     where ntid = new.ntid
       and result is null;
end;

create trigger nametemplateresultInsertLastName after insert on nametemplateresult
for each row when (select ncid from nametemplate where id = new.ntid) = 4 begin
    insert into markovconstruct
        (id)
        select 5 as id
          from seq8
         where seq8.b < 10;

    insert into vautoconstruct (steps) values (20);

    update nametemplateresult
       set result = (select result
                       from markovresult
                      where id = 5
                      order by random())
     where ntid = new.ntid
       and result is null;
end;

create trigger nametemplateresultInsertHyphen after insert on nametemplateresult
for each row when (select ncid from nametemplate where id = new.ntid) = 5 begin
    update nametemplateresult
       set result = '-'
     where ntid = new.ntid
       and refid = new.refid;
end;

create trigger nametemplateresultInsertSpace after insert on nametemplateresult
for each row when (select ncid from nametemplate where id = new.ntid) = 6 begin
    update nametemplateresult
       set result = ' '
     where ntid = new.ntid
       and refid = new.refid;
end;
