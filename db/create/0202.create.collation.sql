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
-- Name: american; Type: COLLATION; Schema: public; Owner: dns
--
CREATE COLLATION american (lc_collate = 'en_US.utf8', lc_ctype = 'en_US.utf8');
ALTER COLLATION public.american OWNER TO dns;

--
-- Name: british; Type: COLLATION; Schema: public; Owner: dns
--
CREATE COLLATION british (lc_collate = 'en_GB.utf8', lc_ctype = 'en_GB.utf8');
ALTER COLLATION public.british OWNER TO dns;

--
-- Name: german; Type: COLLATION; Schema: public; Owner: dns
--
CREATE COLLATION german (lc_collate = 'de_DE.utf8', lc_ctype = 'de_DE.utf8');
ALTER COLLATION public.german OWNER TO dns;


-- vim: ts=8 noet fileencoding=utf-8
