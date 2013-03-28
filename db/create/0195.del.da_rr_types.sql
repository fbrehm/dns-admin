--
-- Droping all objects belonging to da_rr_types...
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;


\echo Dropinng trigger rr_type_id_trigger ...
DROP TRIGGER rr_type_id_trigger ON public.da_rr_types;

\echo Dropping index uix_rr_type_name ...
DROP INDEX public.uix_rr_type_name;

\echo Disable constraint pk_rr_types ...
ALTER TABLE ONLY public.da_rr_types DROP CONSTRAINT pk_rr_types;

\echo Droping view v_all_rr_types ...
DROP VIEW public.v_all_rr_types;

\echo Droping table da_rr_types ...
DROP TABLE public.da_rr_types;

\echo Droping sequence seq_rr_type_id ...
DROP SEQUENCE public.seq_rr_type_id;

\echo Droping function rr_type_id_trigger ...
DROP FUNCTION public.rr_type_id_trigger();


-- vim: ts=8 noet fileencoding=utf-8
