# golf course database
A sql database for a golf course w/ stroke play

![ER diagram, made with dbdiagram.io](https://i.imgur.com/ix0PAUQ.png)

## Golf course schema for stroke play
- Create multiple course layouts for each venue.

- Share holes between multiple course layouts.

- Track scores and for each match.

- Track weather conditions during matches.

## Notes
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
