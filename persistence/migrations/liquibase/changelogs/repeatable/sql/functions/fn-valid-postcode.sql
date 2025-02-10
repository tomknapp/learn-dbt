CREATE OR REPLACE FUNCTION fn_valid_postcode(postcode TEXT)
RETURNS TEXT AS $$
DECLARE
    clean_postcode TEXT;
    valid_format BOOLEAN;
    formatted_postcode TEXT;
BEGIN
    -- Return NULL if input is NULL or empty
    IF postcode IS NULL OR TRIM(postcode) = '' THEN
        RETURN NULL;
    END IF;

    -- Remove spaces
    clean_postcode := REGEXP_REPLACE(TRIM(postcode), '\s+', '', 'g');

    -- Insert a space before the last 3 characters
    clean_postcode := REGEXP_REPLACE(clean_postcode, '(.+)(.{3})$', '\1 \2');

    -- Validate postcode using 'official' regex - only treat as an example
    -- This covers:
    -- 1. GIR 0AA special case
    -- 2. Standard format AA9A 9AA
    -- 3. Standard format A9A 9AA
    -- 4. Standard format A9 9AA
    -- 5. Standard format A99 9AA
    -- 6. Standard format AA9 9AA
    -- 7. Standard format AA99 9AA
    valid_format := clean_postcode ~ '^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z])))) [0-9][A-Za-z]{2})$';

    IF NOT valid_format THEN
        RETURN NULL;
    END IF;

    -- Convert to uppercase for consistent output
    formatted_postcode := UPPER(clean_postcode);

    RETURN formatted_postcode;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;
