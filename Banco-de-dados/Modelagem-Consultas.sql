--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: agendar_consulta(integer, integer, date, time without time zone, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.agendar_consulta(p_id_paciente integer, p_id_medico integer, p_data date, p_horario time without time zone, p_preco numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_consulta INT;
BEGIN
    -- Verificar se horário está disponível
    IF p_horario NOT IN (
        SELECT horario_disponivel 
        FROM verificar_disponibilidade(p_id_medico, p_data)
    ) THEN
        RAISE EXCEPTION 'Horário não disponível';
    END IF;

    -- Inserir consulta
    INSERT INTO consultas (data, horario, preco, id_paciente, id_medico)
    VALUES (p_data, p_horario, p_preco, p_id_paciente, p_id_medico)
    RETURNING id INTO v_id_consulta;

    -- Criar registro de pagamento pendente
    INSERT INTO pagamentos (id_consulta, metodo_pagamento, status_pagamento, valor_pago)
    VALUES (v_id_consulta, 'PENDENTE', 'AGUARDANDO', p_preco);

    RETURN v_id_consulta;
END;
$$;


--
-- Name: verificar_disponibilidade(integer, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verificar_disponibilidade(p_id_medico integer, p_data date) RETURNS TABLE(horario_disponivel time without time zone)
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	RETURN QUERY
    SELECT hora::TIME
    FROM generate_series(
      '08:00'::TIME,
      '17:00'::TIME,
      '30 minutes':: INTERVAL
    )hora
    WHERE hora NOT IN (
      SELECT horario
      FROM consultas
      WHERE id_medico = p_id_medico
      AND data = p_data
    );
 END
 $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: consultas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consultas (
    id integer NOT NULL,
    data date NOT NULL,
    horario time without time zone NOT NULL,
    preco numeric(10,2) NOT NULL,
    id_paciente integer NOT NULL,
    id_medico integer NOT NULL
);


--
-- Name: medicos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medicos (
    id integer NOT NULL,
    nome character varying(100) NOT NULL
);


--
-- Name: pacientes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pacientes (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    telefone character varying(15) NOT NULL
);


--
-- Name: pagamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pagamentos (
    id integer NOT NULL,
    id_consulta integer NOT NULL,
    metodo_pagamento character varying(50) NOT NULL,
    status_pagamento character varying(20) NOT NULL,
    valor_pago numeric(10,2) NOT NULL
);


--
-- Name: agendar_paciente; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.agendar_paciente AS
 SELECT c.id AS id_consulta,
    p.nome AS paciente,
    m.nome AS medico,
    c.data,
    c.horario,
    c.preco,
    pg.status_pagamento
   FROM (((public.consultas c
     JOIN public.pacientes p ON ((p.id = c.id_paciente)))
     JOIN public.medicos m ON ((m.id = c.id_medico)))
     JOIN public.pagamentos pg ON ((pg.id_consulta = c.id)));


--
-- Name: consultas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.consultas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.consultas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: demo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demo (
    id integer NOT NULL,
    name character varying(200) DEFAULT ''::character varying NOT NULL,
    hint text DEFAULT ''::text NOT NULL
);


--
-- Name: demo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demo_id_seq OWNED BY public.demo.id;


--
-- Name: especialidades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.especialidades (
    id integer NOT NULL,
    nome character varying(100) NOT NULL
);


--
-- Name: especialidades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.especialidades ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.especialidades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: medicos_especialidades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medicos_especialidades (
    id_medico integer NOT NULL,
    id_especialidade integer NOT NULL
);


--
-- Name: medicos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.medicos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.medicos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pacientes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.pacientes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pacientes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pagamentos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.pagamentos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pagamentos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: demo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demo ALTER COLUMN id SET DEFAULT nextval('public.demo_id_seq'::regclass);


--
-- Name: consultas consultas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consultas
    ADD CONSTRAINT consultas_pkey PRIMARY KEY (id);


--
-- Name: demo demo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demo
    ADD CONSTRAINT demo_pkey PRIMARY KEY (id);


--
-- Name: especialidades especialidades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.especialidades
    ADD CONSTRAINT especialidades_pkey PRIMARY KEY (id);


--
-- Name: medicos_especialidades medicos_especialidades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicos_especialidades
    ADD CONSTRAINT medicos_especialidades_pkey PRIMARY KEY (id_medico, id_especialidade);


--
-- Name: medicos medicos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_pkey PRIMARY KEY (id);


--
-- Name: pacientes pacientes_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pacientes
    ADD CONSTRAINT pacientes_email_key UNIQUE (email);


--
-- Name: pacientes pacientes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pacientes
    ADD CONSTRAINT pacientes_pkey PRIMARY KEY (id);


--
-- Name: pagamentos pagamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_pkey PRIMARY KEY (id);


--
-- Name: consultas consultas_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consultas
    ADD CONSTRAINT consultas_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medicos(id);


--
-- Name: consultas consultas_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consultas
    ADD CONSTRAINT consultas_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.pacientes(id);


--
-- Name: medicos_especialidades medicos_especialidades_id_especialidade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicos_especialidades
    ADD CONSTRAINT medicos_especialidades_id_especialidade_fkey FOREIGN KEY (id_especialidade) REFERENCES public.especialidades(id);


--
-- Name: medicos_especialidades medicos_especialidades_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicos_especialidades
    ADD CONSTRAINT medicos_especialidades_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medicos(id);


--
-- Name: pagamentos pagamentos_id_consulta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_id_consulta_fkey FOREIGN KEY (id_consulta) REFERENCES public.consultas(id);


--
-- PostgreSQL database dump complete
--

