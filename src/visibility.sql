-- this table is holds a precomputed list of offsets of visible tiles for
-- a character at position (0,0,0)

create table visibility
(
    r integer not null,
    x integer not null,
    y integer not null,
    z integer not null default 0,

    primary key (r, x, y, z)
);

-- our default vision range is supposed to look something like this:

-- ##########.##########
-- #######.......#######
-- ####.............####
-- ###...............###
-- ##.................##
-- #.........@.........#
-- ##.................##
-- ###...............###
-- ####.............####
-- #######.......#######
-- ##########.##########

-- the unit length is one tile width in the x direction. one tile in the y
-- direction counts as 2 unit lengths.

insert into visibility
    (r, x, y)
    select distinct
           (x.b - 100) * (x.b - 100)
         + (y.b - 100) * (y.b - 100) * 2 * 2
        as r,
        x.b - 100 as x,
        y.b - 100 as y
    from seq8 as x,
         seq8 as y
    where  (x.b - 100) * (x.b - 100)
         + (y.b - 100) * (y.b - 100) * 2 * 2
        <= 300;

