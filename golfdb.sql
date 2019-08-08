/*
:: Golf course schema for stroke play
- Create multiple course layouts for each venue.
- Share holes between multiple course layouts.
- Track scores and for each match.
- Track weather conditions during matches.

:: Notes
- This schema assumes Venue_Layout_Hole.hole_num are unique and ordered.
    e.g. 1-2-5-7 is okay but 1-3-2-4-5 or 1-2-2-4-5 is not.
    The reasoning is that holes may be missing, but the order is rarely changed.
- The database is generally very restrictive, i.e. a score may not be entered
    if a player is not part of a match, nor if the course layout does not exist.
- The restrictiveness is a double-edged sword; it sounds safer, but it doesn't
    guarantee correctness. E.g. one may create a course layout without holes.
- If the database is to be extended, it is recommended that the constraints be
    dropped to reduce complexity, and instead ensure validity at the
    transaction or query level.
*/

-- venue
CREATE TABLE IF NOT EXISTS Venue (
    venue_id       INTEGER PRIMARY KEY,

    venue_alias     VARCHAR(50) NOT NULL UNIQUE,
    venue_name      VARCHAR(50) NOT NULL,
    location        VARCHAR(50)
);


-- hole_id is usually hole number, but holes may be changed/rearranged/missing
-- e.g. on venues with two layouts, the latter could be 19-36
CREATE TABLE IF NOT EXISTS Venue_Hole (
    venue_id        INTEGER,
    hole_id         INTEGER,

    par             INTEGER,
    length          INTEGER,
    difficulty      INTEGER,

    CONSTRAINT venue_hole_pk
        PRIMARY KEY (venue_id, hole_id),

    CONSTRAINT venue_hole_fk
        FOREIGN KEY     (venue_id)
        REFERENCES      Venue(venue_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT
);


-- venue_layout keep track of venue version
CREATE TABLE IF NOT EXISTS Venue_Layout (
    layout_id       INTEGER PRIMARY KEY,

    layout_name     VARCHAR(50) NOT NULL UNIQUE,
    venue_id        INTEGER,
    num_holes       INTEGER,

    CONSTRAINT venue_layout_unique
        UNIQUE (layout_id, venue_id),

    CONSTRAINT venue_layout_fk
        FOREIGN KEY     (venue_id)
        REFERENCES      Venue(venue_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT -- superfluous/redundant
);


-- venue_layout_hole
CREATE TABLE IF NOT EXISTS Venue_Layout_Hole (
    layout_id       INTEGER,
    hole_num        INTEGER,

    venue_id        INTEGER,
    hole_id         INTEGER,
    --hole_order      INTEGER, -- slightly redundant

    CONSTRAINT venue_layout_hole_pk
        PRIMARY KEY (layout_id, hole_num),

    CONSTRAINT venue_layout_hole_unique
        UNIQUE (layout_id, hole_id),

    CONSTRAINT venue_layout_fk_1
        FOREIGN KEY     (venue_id, layout_id)
        REFERENCES      Venue_Layout(venue_id, layout_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT,

    CONSTRAINT venue_layout_fk_2
        FOREIGN KEY     (venue_id, hole_id)
        REFERENCES      Venue_Hole(venue_id, hole_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT
);


-- players
CREATE TABLE IF NOT EXISTS Player (
    player_id       INTEGER PRIMARY KEY,

    name            VARCHAR(50),
    num             INTEGER   -- increment if people with same name
);


-- matches
CREATE TABLE IF NOT EXISTS Match (
    match_id        INTEGER PRIMARY KEY,

    layout_id       INTEGER,
    date            TIMESTAMP,
    time            TIMESTAMP,
    round           INTEGER,

    CONSTRAINT match_unique
        UNIQUE (match_id, layout_id),

    CONSTRAINT match_fk
        FOREIGN KEY     (layout_id)
        REFERENCES      Venue_Layout(layout_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT
);


-- conditions during match
CREATE TABLE IF NOT EXISTS Match_Condition (
    match_id        INTEGER PRIMARY KEY,

    duration        TIME,
    wind            REAL,
    temperature     REAL,

    CONSTRAINT match_condition_fk
        FOREIGN KEY     (match_id)
        REFERENCES      Match(match_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT
);


-- players in match
CREATE TABLE IF NOT EXISTS Match_Player (
    match_id        INTEGER,
    player_id       INTEGER,

    CONSTRAINT match_player_pk
        PRIMARY KEY (match_id, player_id),

    CONSTRAINT match_player_fk1
        FOREIGN KEY     (match_id)
        REFERENCES      Match(match_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT,

    CONSTRAINT match_player_fk2
        FOREIGN KEY     (player_id)
        REFERENCES      Player(player_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT
);


-- player score during match
CREATE TABLE IF NOT EXISTS Match_Player_Score (
    match_id        INTEGER,
    layout_id       INTEGER,
    player_id       INTEGER,
    hole_num        INTEGER,

    score           INTEGER,

    CONSTRAINT match_player_score_pk
        PRIMARY KEY (match_id, layout_id, player_id, hole_num),

    -- ensure that the layout is used in the match
    CONSTRAINT match_player_score_fk1
        FOREIGN KEY     (match_id, layout_id)
        REFERENCES      Match(match_id, layout_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT,

    -- ensure that the player is in the match
    CONSTRAINT match_player_score_fk2
        FOREIGN KEY     (match_id, player_id)
        REFERENCES      Match_Player(match_id, player_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT,

    -- ensure that hole matches the layout used in the match
    CONSTRAINT match_player_score_fk3
        FOREIGN KEY     (layout_id, hole_num)
        REFERENCES      Venue_Layout_Hole(layout_id, hole_num)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT
);


-- player penalty during match
CREATE TABLE IF NOT EXISTS Match_Player_Penalty (
    match_id        INTEGER,
    layout_id       INTEGER,
    player_id       INTEGER,
    hole_num        INTEGER,

    penalty         INTEGER,
    rule            TEXT,
    description     TEXT,

    CONSTRAINT match_player_penalty_pk
        PRIMARY KEY (match_id, layout_id, player_id, hole_num),

    -- ensure that the layout is used in the match
    CONSTRAINT match_player_penalty_fk1
        FOREIGN KEY     (match_id, layout_id)
        REFERENCES      Match(match_id, layout_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT,

    -- ensure that the player is in the match
    CONSTRAINT match_player_penalty_fk2
        FOREIGN KEY     (match_id, player_id)
        REFERENCES      Match_Player(match_id, player_id)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT,

    -- ensure that hole matches the layout used in the match
    CONSTRAINT match_player_penalty_fk3
        FOREIGN KEY     (layout_id, hole_num)
        REFERENCES      Venue_Layout_Hole(layout_id, hole_num)
        ON UPDATE       CASCADE
        ON DELETE       RESTRICT
);