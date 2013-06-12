-- so now we need to define the shadow cast by a blocking tile

select load_extension('./sqlite-math-functions.so');

create table shadow
(
    x integer not null,
    y integer not null,
    z integer not null default 0,
    sx integer not null,
    sy integer not null,
    sz integer not null default 0
);

create index shadowXY on shadow(x, y);
create index shadowSXY on shadow(sx, sy);

insert into shadow
    (x, y, sx, sy)
    select distinct
        c.x as x,
        c.y as y,
        s.x as sx,
        s.y as sy
    from visibility as c,
         visibility as s,
         spherical as cs,
         spherical as ss
    where (c.x <> 0 or c.y <> 0)
      and (c.x <> s.x or c.y <> s.y)
      and c.x = cs.x and c.y = cs.y
      and s.x = ss.x and s.y = ss.y
      and s.r > c.r
      and  ( abs(cs.azimuth - ss.azimuth) < (cs.width * 0.75)
          or abs(cs.azimuth - ss.azimuth + 2*pi()) < (cs.width * 0.75)
          or abs(cs.azimuth - ss.azimuth - 2*pi()) < (cs.width * 0.75) );

