--
-- Creating collations ...
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: type_dns_class; Type: TYPE; Schema: public; Owner: dns
--
\echo Creating type type_dns_class ...
CREATE TYPE type_dns_class AS ENUM (
    'IN',
    'CH',
    'HS'
);
ALTER TYPE public.type_dns_class OWNER TO dns;

COMMENT ON TYPE type_dns_class IS 'All usable DNS classes - ''IN'' for ''internet'', ''CH'' for ''chaos'' and ''HS'' for ''hesiod''.';


--
-- Name: type_std_address; Type: TYPE; Schema: public; Owner: dns
--
CREATE TYPE type_std_address AS ENUM (
    'any',
    'none',
    'localhost',
    'localnets'
);
ALTER TYPE public.type_std_address OWNER TO dns;

COMMENT ON TYPE type_std_address IS 'A standard address usable in address lists.';


-- vim: ts=8 noet fileencoding=utf-8
