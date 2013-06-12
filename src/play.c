/*

-: PURPLE HAZE :-

play.c: main terminal I/O driver

-----------------------------------------------------------------------------

Copyright (c) 2013, Magnus Achim Deininger <magnus@ef.gy>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

-----------------------------------------------------------------------------
*/

#include "sqlite3.h"
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <signal.h>

#if !defined(DEFAULT_DATABASE)
#define DEFAULT_DATABASE "game.purple-haze"
#endif

#if !defined(GAME_DATA)
#define GAME_DATA "purple-haze.sql"
#endif

#if !defined(BUFFERSIZE)
#define BUFFERSIZE 4096
#endif

static int import_game_data (sqlite3 *database, const char *data)
{
    int fd = open (data, O_RDONLY);
    if (fd)
    {
        char *stm = malloc (BUFFERSIZE);
        if (stm)
        {
            size_t pos = 0;
            ssize_t r = 0;

            while ((r = read(fd, stm + pos, BUFFERSIZE)) > 0)
            {
                char *stmn = realloc (stm, pos + r + BUFFERSIZE);
                if (stmn == 0)
                {
                    free (stm);
                    close (fd);
                    fputs ("error reallocating buffer for game data import\n", stderr);
                    return -4;
                }
                else
                {
                    stm = stmn;
                    pos += r;
                }
            }

            if (r < 0)
            {
                free (stm);
                close (fd);
                fputs ("error reading from game data file\n", stderr);
                return -3;
            }

            if (pos > 0)
            {
                const char *tail = stm;

                do
                {
                    const char *ntail;
                    sqlite3_stmt *stmt = 0;
                    if (sqlite3_prepare_v2 (database, tail, -1, &stmt, &ntail) == SQLITE_OK)
                    {
                        if (sqlite3_step(stmt) == SQLITE_ERROR)
                        {
                            fputs(sqlite3_errmsg(database), stderr);
                        }
                        sqlite3_finalize(stmt);
                        tail = ntail;
                    }
                } while ((tail != 0) && (*tail != (char)0));
            }

            free (stm);
        }
        else
        {
            close (fd);

            fputs ("error allocating buffer for game data import\n", stderr);
            return -2;
        }

        close (fd);
        return 0;
    }

    fprintf (stderr, "could not read game data file: %s\n", data);

    return -1;
}

static char didResize = 0;

#if defined(SIGWINCH)
static void sigwinch(int sig)
{
    didResize = 1;
}

static int set_sigwinch(void)
{
    struct sigaction sa;

    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sa.sa_handler = sigwinch;
    if (sigaction(SIGWINCH, &sa, NULL) == -1)
    {
        return -1;
    }

    return 0;
}
#else
static int set sigwinch(void)
{
    return -2;
}
#endif

int main(int argc, const char * argv[])
{
    sqlite3 *database = 0;
    sqlite3_stmt *statementUpdateDisplaySize = 0;
    sqlite3_stmt *statementDisplay = 0;
    sqlite3_stmt *statementInsertKeypress = 0;
    struct winsize size = { 80, 25 };
    const char *dbname = argv[1] ? argv[1] : DEFAULT_DATABASE;
    char doQuit = 0;
    struct termios orig;
    struct termios raw;

    set_sigwinch();
    
    if (sqlite3_open(dbname, &database) != SQLITE_OK)
    {
        fputs ("could not open database file.\n", stderr);

        return 1;
    }
    else
    {
        sqlite3_stmt *stmt = 0;
        int r;
        if (sqlite3_prepare_v2(database, "select id from game;", -1, &stmt, 0) != SQLITE_OK)
        {
            puts ("database does not contain game data: importing.");

            if ((r = import_game_data (database, GAME_DATA)) < 0)
            {
                return r;
            }
        }

        if (stmt == 0)
        {
            if (sqlite3_prepare_v2(database, "select id from game;", -1, &stmt, 0) != SQLITE_OK)
            {
                fputs ("could not prepare basic statement; game database file may be corrupt:\n", stderr);
                fputs (sqlite3_errmsg(database), stderr);
                fputs ("\n", stderr);

                return 6;
            }
        }

        if (sqlite3_step(stmt) != SQLITE_ROW)
        {
            puts ("no active game session: creating new session.");

            sqlite3_finalize(stmt);
            if (sqlite3_prepare_v2(database, "insert into game (id) values (1);", -1, &stmt, 0) != SQLITE_OK)
            {
                fputs ("could not prepare basic statement; game database file may be corrupt:\n", stderr);
                fputs (sqlite3_errmsg(database), stderr);
                fputs ("\n", stderr);

                return 7;
            }

            if (sqlite3_step(stmt) == SQLITE_ERROR)
            {
                fputs ("could not create new session; game database file may be corrupt:\n", stderr);
                fputs (sqlite3_errmsg(database), stderr);
                fputs ("\n", stderr);

                return 8;
            }
        }

        sqlite3_finalize(stmt);
    }

    if (sqlite3_prepare_v2(database, "update game set columns=?1, lines=?2;", -1, &statementUpdateDisplaySize, 0) != SQLITE_OK)
    {
        fputs ("could not prepare basic statement; game database file may be corrupt:\n", stderr);
        fputs (sqlite3_errmsg(database), stderr);
        fputs ("\n", stderr);

        return 2;
    }
    if (sqlite3_prepare_v2(database, "select group_concat(diff,'') from voutputansi;", -1, &statementDisplay, 0) != SQLITE_OK)
    {
        fputs ("could not prepare basic statement; game database file may be corrupt:\n", stderr);
        fputs (sqlite3_errmsg(database), stderr);
        fputs ("\n", stderr);

        return 3;
    }
    if (sqlite3_prepare_v2(database, "insert into vkeypress (key) values (?1);", -1, &statementInsertKeypress, 0) != SQLITE_OK)
    {
        fputs ("could not prepare basic statement; game database file may be corrupt:\n", stderr);
        fputs (sqlite3_errmsg(database), stderr);
        fputs ("\n", stderr);

        return 5;
    }

    tcgetattr (0, &orig);
    tcgetattr (0, &raw);
    cfmakeraw (&raw);
    tcsetattr (0, 0, &raw);

    ioctl(0, TIOCGWINSZ, &size);

    puts("\e[2J\e[?25l");

    sqlite3_bind_int (statementUpdateDisplaySize, 1, size.ws_col);
    sqlite3_bind_int (statementUpdateDisplaySize, 2, size.ws_row);

    if (sqlite3_step(statementUpdateDisplaySize) != SQLITE_DONE)
    {
        fputs(sqlite3_errmsg(database), stderr);
    }
    sqlite3_reset(statementUpdateDisplaySize);

    do
    {
        int r;
        char key;
        while ((r = sqlite3_step(statementDisplay)) == SQLITE_ROW)
        {
            const char *output = (const char*)sqlite3_column_text(statementDisplay, 0);
            if (output != 0)
            {
                puts(output);
            }
            else
            {
                fputs(sqlite3_errmsg(database), stderr);
            }
        }

        if (r != SQLITE_DONE)
        {
            fputs(sqlite3_errmsg(database), stderr);
        }

        sqlite3_reset(statementDisplay);

        r = (int)read(0, &key, 1);

        if (didResize) goto resized;

        switch (key)
        {
            case 'Q':
                doQuit = 1;
                break;

            case 'R':
            resized:
                didResize = 0;
                ioctl(0, TIOCGWINSZ, &size);
                sqlite3_bind_int (statementUpdateDisplaySize, 1, size.ws_col);
                sqlite3_bind_int (statementUpdateDisplaySize, 2, size.ws_row);

                if (sqlite3_step(statementUpdateDisplaySize) != SQLITE_DONE)
                {
                    fputs(sqlite3_errmsg(database), stderr);
                }
                sqlite3_reset(statementUpdateDisplaySize);
        }

        if (r > 0)
        {
            char keytext[2] = { key, 0 };
            sqlite3_bind_text (statementInsertKeypress, 1, keytext, -1, SQLITE_TRANSIENT);
            if (sqlite3_step (statementInsertKeypress) != SQLITE_DONE)
            {
                puts("\e[H\e[2J\e[?25h\e[0;39m");
                tcsetattr (0, 0, &orig);
                fputs ("error inserting keypress into database:\n", stderr);
                fputs (sqlite3_errmsg(database), stderr);
                fputs ("\n", stderr);
                return -1;
            }
            sqlite3_reset (statementInsertKeypress);
        }
    } while (!doQuit);

    sqlite3_close(database);

    puts("\e[H\e[2J\e[?25h\e[0;39m");

    tcsetattr (0, 0, &orig);

    return 0;
}
