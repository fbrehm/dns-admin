
-- Name: rr_type_id_trigger(); Type: FUNCTION; Schema: public; Owner: dns
CREATE FUNCTION rr_type_id_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF NEW.rr_type_id IS NOT NULL THEN
            IF NOT (SELECT is_called FROM "seq_rr_type_id") THEN
                -- bei ganz neuer Sequence ggf. zuerst initialisieren
                PERFORM nextval('seq_rr_type_id');
            END IF;
            IF NEW.rr_type_id > (SELECT last_value FROM "seq_rr_type_id") THEN
                PERFORM setval('seq_rr_type_id', NEW.rr_type_id, true);
            END IF;
        END IF;
        RETURN NEW;
    END;
$$;

-- Name: seq_rr_type_id; Type: SEQUENCE; Schema: public; Owner: dns
CREATE SEQUENCE seq_rr_type_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.seq_rr_type_id OWNER TO dns;


-- Name: da_rr_types; Type: TABLE; Schema: public; Owner: dns; Tablespace:
CREATE TABLE da_rr_types (
    rr_type_id integer DEFAULT nextval('seq_rr_type_id'::regclass) NOT NULL,
    rr_type character varying(20) NOT NULL,
    rr_type_value integer NOT NULL,
    obsolete boolean DEFAULT false,
    rr_type_desc character varying(200),
    rr_type_long_desc character varying(2000)
);
ALTER TABLE public.da_rr_types OWNER TO dns;

COMMENT ON TABLE da_rr_types IS 'All available RR types, like A, AAAA, PTR, SOA a.s.o.';
COMMENT ON COLUMN da_rr_types.rr_type_id IS 'numeric RR type ID';
COMMENT ON COLUMN da_rr_types.rr_type IS 'The underlaying RR type abbriavation';
COMMENT ON COLUMN da_rr_types.rr_type_value IS 'the numeric rr type value (from RFC)';
COMMENT ON COLUMN da_rr_types.obsolete IS 'Is this an obsolete RR type (unusable for new RR records).';
COMMENT ON COLUMN da_rr_types.rr_type_desc IS 'short description of the RR type';
COMMENT ON COLUMN da_rr_types.rr_type_long_desc IS 'long description of the RR type';

-- Data for Name: da_rr_types; Type: TABLE DATA; Schema: public; Owner: dns
COPY da_rr_types (rr_type_id, rr_type, rr_type_value, obsolete, rr_type_desc, rr_type_long_desc) FROM stdin;
1	A	1	f	An IPv4 host address.	Returns a 32-bit IPv4 address, most commonly used to map hostnames to an IP address of the host, but also used for DNSBLs, storing subnet masks in RFC 1101, etc. Described in RFC 1035.
2	AAAA	28	f	An IPv6 address.	Returns a 128-bit IPv6 address, most commonly used to map hostnames to an IP address of the host. Described in RFC 1886.
\.

-- Set sequence seq_rr_type_id to the current value
SELECT pg_catalog.setval('seq_rr_type_id', 2, true);

ALTER TABLE ONLY da_rr_types
    ADD CONSTRAINT pk_rr_types PRIMARY KEY (rr_type_id);

CREATE INDEX uix_rr_type_name ON da_rr_types USING btree (rr_type);

CREATE TRIGGER rr_type_id_trigger BEFORE INSERT OR UPDATE ON da_rr_types FOR EACH ROW EXECUTE PROCEDURE rr_type_id_trigger();

-- vim: ts=8 noet
