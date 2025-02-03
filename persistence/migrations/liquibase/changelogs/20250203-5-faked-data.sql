--liquibase formatted sql
--changeset tomknapp:20250203-5-faked-data.sql
-- Insert customers
INSERT INTO
    public.customer (
        user_name,
        first_name,
        last_name,
        std_first_name,
        std_last_name,
        hashed_password,
        is_disabled,
        is_administrator
    )
VALUES
    (
        'oliverb',
        'Oliver',
        'Barnes',
        'OLIVER',
        'BARNES',
        'hash123abc',
        false,
        false
    ),
    (
        'sophiaw',
        'Sophia',
        'Williams',
        'SOPHIA',
        'WILLIAMS',
        'hash456def',
        false,
        false
    ),
    (
        'harryt',
        'Harry',
        'Taylor',
        'HARRY',
        'TAYLOR',
        'hash789ghi',
        false,
        false
    ),
    (
        'emmad',
        'Emma',
        'Davies',
        'EMMA',
        'DAVIES',
        'hashjklmno',
        false,
        true
    ),
    (
        'jamesc',
        'James',
        'Clarke',
        'JAMES',
        'CLARKE',
        'hashpqrstu',
        true,
        false
    );

-- Insert telephone numbers (UK format)
INSERT INTO
    public.telephone (
        customer_id,
        telephone_number,
        std_telephone_number,
        is_verified
    )
VALUES
    (1, '+44 (0)20 7123 4567', '442071234567', true),
    (1, '+44 (0)7700 900123', '447700900123', false), -- UK mobile
    (2, '+44 (0)161 496 0123', '441614960123', true), -- Manchester area
    (3, '+44 (0)7700 900456', '447700900456', true), -- UK mobile
    (4, '+44 (0)131 496 0123', '441314960123', true);

-- Edinburgh area
-- Insert email addresses
INSERT INTO
    public.email (
        customer_id,
        email_address,
        std_email_address,
        is_verified
    )
VALUES
    (
        1,
        'oliver.barnes@gmail.co.uk',
        'OLIVER.BARNES@GMAIL.CO.UK',
        true
    ),
    (1, 'o.barnes@work.com', 'O.BARNES@WORK.COM', true),
    (
        2,
        'sophia.williams@hotmail.co.uk',
        'SOPHIA.WILLIAMS@HOTMAIL.CO.UK',
        true
    ),
    (
        3,
        'harry.taylor@yahoo.co.uk',
        'HARRY.TAYLOR@YAHOO.CO.UK',
        false
    ),
    (
        4,
        'emma.davies@btinternet.com',
        'EMMA.DAVIES@BTINTERNET.COM',
        true
    );

-- Insert addresses (UK format)
INSERT INTO
    public.address (
        customer_id,
        address_line_1,
        address_line_2,
        address_line_3,
        address_line_4,
        postcode,
        std_address_line_1,
        std_address_line_2,
        std_address_line_3,
        std_address_line_4,
        std_postcode
    )
VALUES
    (
        1,
        '42 High Street',
        'Flat 3b',
        'Kensington',
        'London',
        'SW7 2BE',
        '42 HIGH STREET',
        'FLAT 3B',
        'KENSINGTON',
        'LONDON',
        'SW7 2BE'
    ),
    (
        2,
        '15 Victoria Road',
        NULL,
        'Didsbury',
        'Manchester',
        'M20 2AU',
        '15 VICTORIA ROAD',
        NULL,
        'DIDSBURY',
        'MANCHESTER',
        'M20 2AU'
    ),
    (
        3,
        '27 The Meadows',
        'Apartment 12',
        'Headingley',
        'Leeds',
        'LS6 3RD',
        '27 THE MEADOWS',
        'APARTMENT 12',
        'HEADINGLEY',
        'LEEDS',
        'LS6 3RD'
    ),
    (
        4,
        '8 Queen Street',
        NULL,
        'New Town',
        'Edinburgh',
        'EH2 1JE',
        '8 QUEEN STREET',
        NULL,
        'NEW TOWN',
        'EDINBURGH',
        'EH2 1JE'
    ),
    (
        5,
        '103 Church Lane',
        'Flat 5',
        'Clifton',
        'Bristol',
        'BS8 1BN',
        '103 CHURCH LANE',
        'FLAT 5',
        'CLIFTON',
        'BRISTOL',
        'BS8 1BN'
    );

--rollback TRUNCATE TABLE public.customer;
