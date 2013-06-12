-- behavioural attributes: predator/prey, fight/flight response, grouping, factions

create table behaviour
(
    rid integer not null,
    mid integer null,

    carnivorous boolean not null,
    herbivorous boolean not null,
    detrivorous boolean not null,
    territorial boolean not null,
    fight integer not null,
    flight integer not null,

    foreign key (rid) references race(id),
    foreign key (mid) references metatype(id)
);

create table faction
(
    id integer not null primary key,
    name text not null
);

