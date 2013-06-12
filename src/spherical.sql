-- calculate spherical coordinates for everything visible. this part needs the
-- math extension functions at http://www.sqlite.org/contrib - but since we
-- calculate it now this won't be necessary for the game later.

select load_extension('./sqlite-math-functions.so');

create table spherical
(
    x integer not null,
    y integer not null,

    azimuth number not null,

    width   number not null,

    primary key (x, y)
);

insert into spherical
    (x, y, azimuth, width)
    select distinct
        v.x,
        v.y,
        atan2(1.5*v.y, v.x) as azimuth,
        pi()/(2*sqrt(v.r)) as width
    from visibility as v
    where v.x <> 0 or v.y <> 0;
