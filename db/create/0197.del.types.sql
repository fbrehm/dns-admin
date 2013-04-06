--
-- Droping of all most general stuff
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

\echo Droping type type_std_address ...
DROP TYPE public.type_std_address;

\echo Droping type type_dns_class ...
DROP TYPE public.type_dns_class;


-- vim: ts=8 noet fileencoding=utf-8
