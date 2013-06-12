root=http://ef.gy/
name=Magnus Achim Deininger
DATABASES:=base.purple-haze purple-haze.sql
SQLITE3:=sqlite3
CC:=clang
CFLAGS:=-O3
# versions after 3.7.13 keep getting slower and slower...?
#SQLITE3ZIPSRC:=http://www.sqlite.org/sqlite-amalgamation-3070400.zip
#SQLITE3ZIPSRC:=http://www.sqlite.org/sqlite-amalgamation-3071200.zip
#SQLITE3ZIPSRC:=http://www.sqlite.org/sqlite-amalgamation-3071400.zip
#SQLITE3ZIPSRC:=http://www.sqlite.org/sqlite-amalgamation-3071401.zip
#SQLITE3ZIPSRC:=http://www.sqlite.org/sqlite-amalgamation-3071500.zip
#SQLITE3ZIPSRC:=http://www.sqlite.org/sqlite-amalgamation-3071600.zip
#SQLITE3ZIPSRC:=http://www.sqlite.org/2013/sqlite-amalgamation-3071602.zip
SQLITE3ZIPSRC:=http://www.sqlite.org/2013/sqlite-amalgamation-3071700.zip
# this one works rather well:
#SQLITE3ZIPSRC:=http://www.sqlite.org/sqlite-amalgamation-3071300.zip
# shuffle around SQLITE's feature set a bit
SQLITE3CFLAGS:=-DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_THREADSAFE=0 -DSQLITE_DEFAULT_FOREIGN_KEYS=1 -DSQLITE_DEFAULT_MEMSTATUS=0 -DSQLITE_DISABLE_DIRSYNC -DSQLITE_TEMP_STORE=3 -DSQLITE_MAX_ATTACHED=4 -DSQLITE_DEFAULT_MMAP_SIZE=4194304 -DSQLITE_MAX_MMAP_SIZE=8388608
#SQLITE3CFLAGS:=-ldl -pthread
SQLITE3ZIPCL:=http://www.sqlite.org/2013/sqlite-shell-linux-x86-3071700.zip
SQLITEMATHLIB:=sqlite-math-functions.so
CURL:=curl
MAXLINES:=5000

all: databases purple-haze

clean:
	rm -f $(DATABASES) game.purple-haze $(SQLITEMATHLIB) purple-haze sqlite3.zip

scrub: clean

databases: $(DATABASES)

base.purple-haze: src/sequence.sql src/markov.sql src/markov-data.sql src/name.sql src/corporation.sql src/game.sql src/skills.sql src/effect.sql src/race.sql src/profile.sql src/conduct.sql src/character.sql src/dice.sql src/board.sql src/level.sql src/visibility.sql src/spherical.sql src/shadow.sql src/vision.sql src/inventory.sql src/command.sql src/output.sql src/sense.sql src/behaviour.sql $(SQLITEMATHLIB)
	rm -f $@*
	cat $(filter-out $(SQLITEMATHLIB),$^) | $(SQLITE3) $@
	$(SQLITE3) $@ analyze

purple-haze.sql: base.purple-haze
	$(SQLITE3) $^ .dump > $@

game.purple-haze: purple-haze.sql
	rm -f $@*
	$(SQLITE3) $@ < purple-haze.sql
	bash -c 'time $(SQLITE3) $@ < src/data.sql'
	$(SQLITE3) $@ analyze

$(SQLITEMATHLIB): src/sqlite-math-functions.c
	gcc -fPIC -lm -shared $^ -o $@

sqlite3.zip:
	curl "$(SQLITE3ZIPSRC)" -o $@

sqlite3cl.zip:
	curl "$(SQLITE3ZIPCL)" -o $@

src/sqlite3.c: sqlite3.zip
	cd src && unzip -jo ../sqlite3.zip
	touch $@

sqlite3: sqlite3cl.zip
	unzip -jo $^
	chmod a+x $@

purple-haze: src/play.c src/sqlite3.c
	$(CC) $(SQLITE3CFLAGS) $(CFLAGS) $^ -o $@

# based on the markov chains makefile
markov.sqlite3: src/sequence.sql src/markov.sql src/dist.female.first.sql src/dist.male.first.sql src/dist.all.last.sql
	rm -f $@*
	cat $^ | $(SQLITE3) $@
	$(SQLITE3) $@ analyze

src/markov-data.sql: markov.sqlite3
	echo 'drop table markov3; drop table markov2; drop table markov1;' > $@
	$(SQLITE3) $^ '.dump markov3' >> $@
	$(SQLITE3) $^ '.dump markov2' >> $@
	$(SQLITE3) $^ '.dump markov1' >> $@

src/%.sql: data/%
	rm -f $@
	ID=$$(if [ "$*" = "corporations" ]; then echo 2;\
	    elif [ "$*" = "dist.female.first" ]; then echo 3;\
	    elif [ "$*" = "dist.male.first" ]; then echo 4;\
	    elif [ "$*" = "dist.all.last" ]; then echo 5;\
		else echo 1; fi);\
	while read line; do echo "insert into vtrain (id, data) values ($${ID}, '$$(echo $${line} | sed s/\'/\\\'\\\'/g)');" >> $@; done < $^

data/dist.%: data/dist.%.census.gov
	cat $^ | cut -d ' ' -f 1 | head -n $(MAXLINES) - > $@

data/corporations: data/corporations.mass.gov
	cat $^ | cut -d ',' -f 1 | sed 's/^.[ \t\v]*//g' | uniq | sort --random-sort | head -n $(MAXLINES) - > $@

data/dist.%.census.gov:
	$(CURL) 'http://www.census.gov/genealogy/www/data/1990surnames/dist.$*' > $@

data/corporations.mass.gov:
	$(CURL) 'http://www.mass.gov/dor/docs/dls/mdmstuf/propertytax/corporations.txt' > $@
