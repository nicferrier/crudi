-- -*- mode: sql -*-

CREATE OR REPLACE FUNCTION schema_init () RETURNS void AS $$
begin
    -- This is needed to stop crystal's pg lib barfing on the output
    SET client_min_messages = error;
    
    -- Routes
    CREATE SEQUENCE IF NOT EXISTS route_ids;
    
    CREATE TABLE IF NOT EXISTS route ("id" INTEGER,
                                      "path" TEXT,
                                      "port" INTEGER);

    PERFORM id FROM route WHERE path = '/';
    if not found then
        INSERT INTO route (id, path, port)
        VALUES (nextval('route_ids'), '/', 8001);
    end if;

    -- Wiki
    CREATE SEQUENCE IF NOT EXISTS wiki_ids;
    
    CREATE TABLE IF NOT EXISTS wiki ("id" INTEGER,
                                     "date" TIMESTAMP WITH TIME ZONE,
                                     "author" TEXT,
                                     "name" TEXT,
                                     "content" JSON);

    PERFORM id FROM wiki WHERE name = 'Main' ORDER BY id DESC LIMIT 1;
    if not found then
        INSERT INTO wiki (id,
                          author,
                          name,
                          content,
                          date)
        VALUES (nextval('wiki_ids'),
                'Crudi',
                'Main',
                '[{"h1": "Main Page"}]'::json,
                now());
    end if;

    -- Tickets
    CREATE SEQUENCE IF NOT EXISTS ticket_ids;
    
    CREATE TABLE IF NOT EXISTS ticket (id INTEGER,
                                       date TIMESTAMP WITH TIME ZONE,
                                       title TEXT,
                                       author TEXT,
                                       assigned TEXT,
                                       description JSON, 
                                       comments JSON);

    PERFORM id FROM ticket WHERE title = 'First';
    if not found then
        INSERT INTO ticket (id, date, title, 
                            author, assigned, 
                            description, comments) 
        VALUES (nextval('ticket_ids'),
                now(),
                'an example ticket',
                'nicferrier', 'nicferrier',
                '{}', '{}');
    end if;

END;
$$ LANGUAGE plpgsql;
  
-- init.sql ends here
