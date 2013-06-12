create view vshadow as
select distinct
    q.id as id,
    q.x as x,
    q.y as y,
    q.z as z
from vboard as b,
     shadow as s,
     board as p,
     board as q,
     game as g
where g.id = 1
  and p.cid = g.pov
  and b.opaque
  and s.x = b.x - p.x and s.y = b.y - p.y and s.z = b.z - p.z
  and q.x = s.sx + p.x and q.y = s.sy + p.y and q.z = s.sz + p.z;

create view vvisual as
select
    b.id as id,
    b.x as x,
    b.y as y,
    b.z as z,
    coalesce(b.tile, '#') as tile
from visibility as v,
     game as g,
     board as p,
     vboard as b
left join vshadow as s on s.id = b.id
where g.id = 1
  and p.cid = g.pov
  and v.x + p.x = b.x
  and v.y + p.y = b.y
  and v.z + p.z = b.z
  and s.id is null;
