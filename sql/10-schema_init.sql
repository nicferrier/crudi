-- -*- mode: sql -*-

CREATE OR REPLACE FUNCTION schema_init () RETURNS void AS $$
begin
    -- This is needed to stop crystal's pg lib barfing on the output
    set client_min_messages = error;
    
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

    -- Wiki, the page store, the materialized view and the trigger joining them
    CREATE SEQUENCE IF NOT EXISTS wiki_ids;
    CREATE TABLE IF NOT EXISTS wiki ("id" INTEGER,
                                     "date" TIMESTAMP WITH TIME ZONE,
                                     "author" TEXT,
                                     "name" TEXT,
                                     "content" JSON);

    CREATE TABLE IF NOT EXISTS wiki_page (LIKE wiki);

    PERFORM tgname FROM pg_trigger WHERE tgname = 'wiki_page_capture';
    if NOT FOUND then
        CREATE TRIGGER wiki_page_capture
        AFTER INSERT OR UPDATE OR DELETE ON wiki
        FOR EACH ROW EXECUTE PROCEDURE wiki_materialize();
    end if;

    -- Now put some data in them
    PERFORM id FROM wiki WHERE name = 'Main' ORDER BY id DESC LIMIT 1;
    if NOT FOUND then
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
    if NOT FOUND then
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
