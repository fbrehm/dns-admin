--
-- Creating all objects belonging to da_version ...
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: get_da_dbmodel_version(); Type: FUNCTION; Schema: public; Owner: dns
--
CREATE FUNCTION get_da_dbmodel_version() RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    vc_version character varying := '';
BEGIN

    SELECT version FROM da_version INTO vc_version ORDER BY id ASC LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No version string found';
    END IF;

    RETURN vc_version;
END;
$$;

ALTER FUNCTION public.get_da_dbmodel_version() OWNER TO dns;

--
-- Name: da_version; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--
CREATE TABLE da_version (
    id integer DEFAULT 1 NOT NULL,
    version character varying(100) NOT NULL
);
ALTER TABLE public.da_version OWNER TO dns;

COMMENT ON TABLE da_version IS 'the version of the databasemodel of dns administrator';
COMMENT ON COLUMN da_version.id IS 'pk column of version, the only essential row is this with ID 1';
COMMENT ON COLUMN da_version.version IS 'The underlaying version string of the database model';


--
-- Data for Name: da_version; Type: TABLE DATA; Schema: public; Owner: dns
--
COPY da_version (id, version) FROM stdin;
1	0.1
\.

--
-- Name: uix_version; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--
CREATE UNIQUE INDEX uix_version ON da_version USING btree (version);

--
-- Name: get_da_dbmodel_version(); Type: ACL; Schema: public; Owner: dns
--
REVOKE ALL ON FUNCTION get_da_dbmodel_version() FROM PUBLIC;
REVOKE ALL ON FUNCTION get_da_dbmodel_version() FROM dns;
GRANT ALL ON FUNCTION get_da_dbmodel_version() TO dns;
GRANT ALL ON FUNCTION get_da_dbmodel_version() TO PUBLIC;


-- vim: ts=8 noet fileencoding=utf-8
