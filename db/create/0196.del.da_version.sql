--
-- Droping of all objects belonging to da_version ...
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

\echo Droping index uix_version ...
DROP INDEX public.uix_version;

\echo Disabling constraint pk_da_version ...
ALTER TABLE ONLY public.da_version DROP CONSTRAINT pk_da_version;

\echo Droping table da_version ...
DROP TABLE public.da_version;

\echo Droping function get_da_dbmodel_version ...
DROP FUNCTION public.get_da_dbmodel_version();

-- vim: ts=8 noet fileencoding=utf-8
