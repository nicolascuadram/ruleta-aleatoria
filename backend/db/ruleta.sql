--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8
-- Dumped by pg_dump version 16.8

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alumno; Type: TABLE; Schema: public; Owner: furzua
--

CREATE TABLE public.alumno (
    id integer NOT NULL,
    nombre text,
    ref_grupo integer
);


ALTER TABLE public.alumno OWNER TO furzua;

--
-- Name: alumno_id_seq; Type: SEQUENCE; Schema: public; Owner: furzua
--

CREATE SEQUENCE public.alumno_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alumno_id_seq OWNER TO furzua;

--
-- Name: alumno_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: furzua
--

ALTER SEQUENCE public.alumno_id_seq OWNED BY public.alumno.id;


--
-- Name: grupo; Type: TABLE; Schema: public; Owner: furzua
--

CREATE TABLE public.grupo (
    id integer NOT NULL,
    nombre text,
    ref_instancia integer
);


ALTER TABLE public.grupo OWNER TO furzua;

--
-- Name: grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: furzua
--

CREATE SEQUENCE public.grupo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.grupo_id_seq OWNER TO furzua;

--
-- Name: grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: furzua
--

ALTER SEQUENCE public.grupo_id_seq OWNED BY public.grupo.id;


--
-- Name: incidencia; Type: TABLE; Schema: public; Owner: furzua
--

CREATE TABLE public.incidencia (
    id integer NOT NULL,
    categoria text NOT NULL,
    descripcion text,
    alumno boolean
);


ALTER TABLE public.incidencia OWNER TO furzua;

--
-- Name: incidencia_id_seq; Type: SEQUENCE; Schema: public; Owner: furzua
--

CREATE SEQUENCE public.incidencia_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incidencia_id_seq OWNER TO furzua;

--
-- Name: incidencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: furzua
--

ALTER SEQUENCE public.incidencia_id_seq OWNED BY public.incidencia.id;


--
-- Name: instancia; Type: TABLE; Schema: public; Owner: furzua
--

CREATE TABLE public.instancia (
    id integer NOT NULL,
    semestre text,
    profesor text
);


ALTER TABLE public.instancia OWNER TO furzua;

--
-- Name: instancia_id_seq; Type: SEQUENCE; Schema: public; Owner: furzua
--

CREATE SEQUENCE public.instancia_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.instancia_id_seq OWNER TO furzua;

--
-- Name: instancia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: furzua
--

ALTER SEQUENCE public.instancia_id_seq OWNED BY public.instancia.id;


--
-- Name: registro; Type: TABLE; Schema: public; Owner: furzua
--

CREATE TABLE public.registro (
    id integer NOT NULL,
    ref_incidencia integer,
    ref_grupo integer,
    alumnoescogido text,
    fecha timestamp without time zone,
    comentario text
);


ALTER TABLE public.registro OWNER TO furzua;

--
-- Name: registro_id_seq; Type: SEQUENCE; Schema: public; Owner: furzua
--

CREATE SEQUENCE public.registro_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.registro_id_seq OWNER TO furzua;

--
-- Name: registro_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: furzua
--

ALTER SEQUENCE public.registro_id_seq OWNED BY public.registro.id;


--
-- Name: alumno id; Type: DEFAULT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.alumno ALTER COLUMN id SET DEFAULT nextval('public.alumno_id_seq'::regclass);


--
-- Name: grupo id; Type: DEFAULT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.grupo ALTER COLUMN id SET DEFAULT nextval('public.grupo_id_seq'::regclass);


--
-- Name: incidencia id; Type: DEFAULT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.incidencia ALTER COLUMN id SET DEFAULT nextval('public.incidencia_id_seq'::regclass);


--
-- Name: instancia id; Type: DEFAULT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.instancia ALTER COLUMN id SET DEFAULT nextval('public.instancia_id_seq'::regclass);


--
-- Name: registro id; Type: DEFAULT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.registro ALTER COLUMN id SET DEFAULT nextval('public.registro_id_seq'::regclass);


--
-- Data for Name: alumno; Type: TABLE DATA; Schema: public; Owner: furzua
--

COPY public.alumno (id, nombre, ref_grupo) FROM stdin;
1	Ana Torres	1
2	Luis Pérez	1
3	Carlos Soto	2
4	María Ríos	2
5	Tomás Vidal	3
6	Valentina Díaz	3
7	Ana Torres	1
8	Luis Pérez	1
9	Carlos Soto	2
10	María Ríos	2
11	Tomás Vidal	3
12	Valentina Díaz	3
\.


--
-- Data for Name: grupo; Type: TABLE DATA; Schema: public; Owner: furzua
--

COPY public.grupo (id, nombre, ref_instancia) FROM stdin;
1	Grupo Alfa	1
2	Grupo Beta	1
3	Grupo Gamma	2
4	Grupo Alfa	1
5	Grupo Beta	1
6	Grupo Gamma	2
\.


--
-- Data for Name: incidencia; Type: TABLE DATA; Schema: public; Owner: furzua
--

COPY public.incidencia (id, categoria, descripcion, alumno) FROM stdin;
1	Pausa grupal	El grupo no trabaja esta semana	f
2	Sin herramientas	El grupo no puede usar computador esta semana	f
3	Alumno inactivo	Un alumno del grupo no puede trabajar esta semana	t
4	Cambio de rol	Un alumno debe cambiar su rol habitual	t
5	Doble carga	El grupo debe entregar dos tareas esta semana	f
\.


--
-- Data for Name: instancia; Type: TABLE DATA; Schema: public; Owner: furzua
--

COPY public.instancia (id, semestre, profesor) FROM stdin;
1	2024-1	Prof. González
2	2024-2	Prof. Ramírez
3	2024-1	Prof. González
4	2024-2	Prof. Ramírez
\.


--
-- Data for Name: registro; Type: TABLE DATA; Schema: public; Owner: furzua
--

COPY public.registro (id, ref_incidencia, ref_grupo, alumnoescogido, fecha, comentario) FROM stdin;
6	1	1	\N	2025-04-16 23:17:41.265481	Se pausó al Grupo Alfa por baja participación
7	3	1	Luis Pérez	2025-04-17 23:17:41.265481	Luis no participará esta semana
8	2	2	\N	2025-04-15 23:17:41.265481	Grupo Beta sin acceso a computadores
9	4	2	María Ríos	2025-04-18 23:17:41.265481	María cambia su rol de lider a programadora
10	5	3	\N	2025-04-18 23:17:41.265481	Grupo Gamma tendrá entrega doble esta semana
\.


--
-- Name: alumno_id_seq; Type: SEQUENCE SET; Schema: public; Owner: furzua
--

SELECT pg_catalog.setval('public.alumno_id_seq', 12, true);


--
-- Name: grupo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: furzua
--

SELECT pg_catalog.setval('public.grupo_id_seq', 6, true);


--
-- Name: incidencia_id_seq; Type: SEQUENCE SET; Schema: public; Owner: furzua
--

SELECT pg_catalog.setval('public.incidencia_id_seq', 5, true);


--
-- Name: instancia_id_seq; Type: SEQUENCE SET; Schema: public; Owner: furzua
--

SELECT pg_catalog.setval('public.instancia_id_seq', 4, true);


--
-- Name: registro_id_seq; Type: SEQUENCE SET; Schema: public; Owner: furzua
--

SELECT pg_catalog.setval('public.registro_id_seq', 10, true);


--
-- Name: alumno alumno_pkey; Type: CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.alumno
    ADD CONSTRAINT alumno_pkey PRIMARY KEY (id);


--
-- Name: grupo grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.grupo
    ADD CONSTRAINT grupo_pkey PRIMARY KEY (id);


--
-- Name: incidencia incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.incidencia
    ADD CONSTRAINT incidencia_pkey PRIMARY KEY (id);


--
-- Name: instancia instancia_pkey; Type: CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.instancia
    ADD CONSTRAINT instancia_pkey PRIMARY KEY (id);


--
-- Name: registro registro_pkey; Type: CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT registro_pkey PRIMARY KEY (id);


--
-- Name: alumno alumno_ref_grupo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.alumno
    ADD CONSTRAINT alumno_ref_grupo_fkey FOREIGN KEY (ref_grupo) REFERENCES public.grupo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: grupo grupo_ref_instancia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.grupo
    ADD CONSTRAINT grupo_ref_instancia_fkey FOREIGN KEY (ref_instancia) REFERENCES public.instancia(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro registro_ref_grupo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT registro_ref_grupo_fkey FOREIGN KEY (ref_grupo) REFERENCES public.grupo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro registro_ref_incidencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: furzua
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT registro_ref_incidencia_fkey FOREIGN KEY (ref_incidencia) REFERENCES public.incidencia(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

