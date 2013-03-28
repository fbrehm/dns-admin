--
-- Creating all general stuff
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--
\echo Creating schema public ...
CREATE SCHEMA public;
ALTER SCHEMA public OWNER TO postgres;
COMMENT ON SCHEMA public IS 'standard public schema';

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--
\echo Creating extension plpgsql ...
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

--
-- Name: plpython2u; Type: EXTENSION; Schema: -; Owner: 
--
\echo Creating extension plpython2u ...
CREATE EXTENSION IF NOT EXISTS plpython2u WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpython2u IS 'PL/Python2U untrusted procedural language';

--
-- Name: plpythonu; Type: EXTENSION; Schema: -; Owner: 
--
\echo Creating extension plpythonu ...
CREATE EXTENSION IF NOT EXISTS plpythonu WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpythonu IS 'PL/PythonU untrusted procedural language';


-- vim: ts=8 noet fileencoding=utf-8
