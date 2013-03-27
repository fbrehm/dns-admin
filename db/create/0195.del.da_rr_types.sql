DROP TRIGGER rr_type_id_trigger ON public.da_rr_types;

DROP INDEX public.uix_rr_type_name;
ALTER TABLE ONLY public.da_rr_types DROP CONSTRAINT pk_rr_types;
DROP TABLE public.da_rr_types;
DROP SEQUENCE public.seq_rr_type_id;
DROP FUNCTION public.rr_type_id_trigger();

