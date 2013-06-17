create view voutputansiwant as
select
    x.b as x,
    y.b as y,
    case when v.tile is not null then 37
         else 34
    end as colour,
    case when v.tile is not null then v.tile
         when b.tile is not null and b.onmap and c.commlinkactive then b.tile
         else ' '
    end as tile
from seq8 as x,
     seq8 as y,
     game as g,
     vboard as b,
     board as p,
     vcharacter as c
left join vvisual as v on v.id = b.id
where g.id = 1
  and c.id = g.pov
  and x.b > 0 and x.b < (g.columns + case when g.moid = 2 then -50 else 0 end)
  and y.b > 3 and y.b < (g.lines - 1)
  and b.x = (x.b-g.offsetx) and b.y = (y.b-g.offsety) and b.z = p.z
  and p.cid = g.pov
union all
select
  g.columns - 49 as x,
  y.b + 4 as y,
  37 as colour,
  k.key || ') ' || i.name as tile
from game as g, seq8 as y, vcharacteritemislot as i, keymap as k
where g.id = 1
  and g.moid = 2
  and i.cid = g.pov
  and i.islot = y.b
  and k.moid = g.moid
  and k.cmid = 39 + i.islot
  and y.b < (g.lines - 4) and y.b <= (select count(*)
                                        from vcharacteritem
                                       where cid = g.pov)
union all
select
  0 as x,
  game.lines - 1 as y,
  37 as colour,
     'Level: ' || board.z
  || ' Karma: ' || vcharacter.karmatotal || ' (' || vcharacter.karma || ') '
  || vcharacter.name
  || ' (' || profile.name || ')'
  || case when game.moid <> 0 then ' :: ' || gamemode.description else '' end
  || '; Next: '
    || case when vnext.aid is not null then (select name from attribute where vnext.aid = id)
            when vnext.sid is not null then (select name from skill where vnext.sid = id) end
    || ' +1 (' || vnext.karma || ')'
  || X'1B' || '[K'
  as tile
from board, game, vcharacter, profile, gamemode, vnext
where game.id = 1
  and board.cid = game.pov
  and vcharacter.id = game.pov
  and vcharacter.pid = profile.id
  and gamemode.id = game.moid
  and vnext.cid = vcharacter.id
union all
select
  0 as x,
  0 as y,
  37 as colour,
  case when refresh = 1 then X'1B' || '[2J' else '' end ||
  coalesce(group_concat(message, ' '),'') ||
  X'1B' || '[K' as tile
from game
left outer join message on message.id > game.msid
where game.id = 1;

create view voutputansi as
select
    X'1B' || '[' || w.colour || 'm' ||
    X'1B' || '[' || w.y || 'H' ||
    group_concat(X'1B' || '[' || w.x || 'G' || w.tile, '') as diff
from voutputansiwant as w
group by w.y, w.colour;
