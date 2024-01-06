-- Make title_principals category 'actor' unisex

BEGIN;

UPDATE title_principals
SET category = 'actor'
WHERE category = 'actress';

COMMIT;