--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1
-- Dumped by pg_dump version 13.1

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
-- Name: orderdetails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orderdetails (
    orderid integer,
    productid integer,
    productname text,
    unitprice numeric,
    quantity integer,
    discount numeric,
    totaldiscount numeric
);


ALTER TABLE public.orderdetails OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    orderid integer NOT NULL,
    customerid text,
    employeeid integer,
    orderdate text,
    requireddate text,
    shippeddate text,
    shipperid integer,
    freight numeric,
    shipname text,
    shipaddress text,
    shipcity text,
    shipregion text,
    shippostalcode text,
    shipcountry text
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customerid text NOT NULL,
    companyname text,
    address text,
    contactname text,
    contacttitle text,
    city text,
    region text,
    postalcode text,
    country text,
    phone text,
    fax text
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    productid integer NOT NULL,
    productname text,
    supplierid integer,
    categoryid integer,
    quantityperunit text,
    priceperunit numeric,
    unitsinstock integer,
    unitsonorder integer,
    reorderlevel integer,
    discontinued integer
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: vendors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendors (
    supplierid integer NOT NULL,
    companyname text,
    contactname text,
    contacttitle text,
    address text,
    city text,
    region text,
    postalcode text,
    country text,
    phone text,
    fax text,
    homepage text
);


ALTER TABLE public.vendors OWNER TO postgres;

--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (customerid, companyname, address, contactname, contacttitle, city, region, postalcode, country, phone, fax) FROM stdin;
ALFKI	Alfreds Futterkiste	Obere Str. 57	Maria Anders	Sales Representative	Berlin	\N	12209	Germany	030-0074321	030-0076545
ANATR	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	Ana Trujillo	Owner	México D.F.	\N	5021	Mexico	(5) 555-4729	(5) 555-3745
ANTON	Antonio Moreno Taquería	Mataderos  2312	Antonio Moreno	Owner	México D.F.	\N	5023	Mexico	(5) 555-3932	\N
AROUT	Around the Horn	120 Hanover Sq.	Thomas Hardy	Sales Representative	London	\N	WA1 1DP	UK	(171) 555-7788	(171) 555-6750
BERGS	Berglunds snabbköp	Berguvsvägen  8	Christina Berglund	Order Administrator	Luleå	\N	S-958 22	Sweden	0921-12 34 65	0921-12 34 67
BLAUS	Blauer See Delikatessen	Forsterstr. 57	Hanna Moos	Sales Representative	Mannheim	\N	68306	Germany	0621-08460	0621-08924
BLONP	Blondel père et fils	24 place Kléber	Frédérique Citeaux	Marketing Manager	Strasbourg	\N	67000	France	88.60.15.31	88.60.15.32
BOLID	Bólido Comidas preparadas	C/ Araquil 67	Martín Sommer	Owner	Madrid	\N	28023	Spain	(91) 555 22 82	(91) 555 91 99
BONAP	Bon app'	12 rue des Bouchers	Laurence Lebihan	Owner	Marseille	\N	13008	France	91.24.45.40	91.24.45.41
BOTTM	Bottom-Dollar Markets	23 Tsawassen Blvd.	Elizabeth Lincoln	Accounting Manager	Tsawassen	BC	T2F 8M4	Canada	(604) 555-4729	(604) 555-3745
BSBEV	B's Beverages	Fauntleroy Circus	Victoria Ashworth	Sales Representative	London	\N	EC2 5NT	UK	(171) 555-1212	\N
CACTU	Cactus Comidas para llevar	Cerrito 333	Patricio Simpson	Sales Agent	Buenos Aires	\N	1010	Argentina	(1) 135-5555	(1) 135-4892
CENTC	Centro comercial Moctezuma	Sierras de Granada 9993	Francisco Chang	Marketing Manager	México D.F.	\N	5022	Mexico	(5) 555-3392	(5) 555-7293
CHOPS	Chop-suey Chinese	Hauptstr. 29	Yang Wang	Owner	Bern	\N	3012	Switzerland	0452-076545	\N
COMMI	Comércio Mineiro	Av. dos Lusíadas 23	Pedro Afonso	Sales Associate	São Paulo	SP	05432-043	Brazil	(11) 555-7647	\N
CONSH	Consolidated Holdings	Berkeley Gardens12  Brewery	Elizabeth Brown	Sales Representative	London	\N	WX1 6LT	UK	(171) 555-2282	(171) 555-9199
DRACD	Drachenblut Delikatessen	Walserweg 21	Sven Ottlieb	Order Administrator	Aachen	\N	52066	Germany	0241-039123	0241-059428
DUMON	Du monde entier	67 rue des Cinquante Otages	Janine Labrune	Owner	Nantes	\N	44000	France	40.67.88.88	40.67.89.89
EASTC	Eastern Connection	35 King George	Ann Devon	Sales Agent	London	\N	WX3 6FW	UK	(171) 555-0297	(171) 555-3373
ERNSH	Ernst Handel	Kirchgasse 6	Roland Mendel	Sales Manager	Graz	\N	8010	Austria	7675-3425	7675-3426
FAMIA	Familia Arquibaldo	Rua Orós 92	Aria Cruz	Marketing Assistant	São Paulo	SP	05442-030	Brazil	(11) 555-9857	\N
FISSA	FISSA Fabrica Inter. Salchichas S.A.	C/ Moralzarzal 86	Diego Roel	Accounting Manager	Madrid	\N	28034	Spain	(91) 555 94 44	(91) 555 55 93
FOLIG	Folies gourmandes	184 chaussée de Tournai	Martine Rancé	Assistant Sales Agent	Lille	\N	59000	France	20.16.10.16	20.16.10.17
FOLKO	Folk och fä HB	Åkergatan 24	Maria Larsson	Owner	Bräcke	\N	S-844 67	Sweden	0695-34 67 21	\N
FRANK	Frankenversand	Berliner Platz 43	Peter Franken	Marketing Manager	München	\N	80805	Germany	089-0877310	089-0877451
FRANR	France restauration	54 rue Royale	Carine Schmitt	Marketing Manager	Nantes	\N	44000	France	40.32.21.21	40.32.21.20
FRANS	Franchi S.p.A.	Via Monte Bianco 34	Paolo Accorti	Sales Representative	Torino	\N	10100	Italy	011-4988260	011-4988261
FURIB	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lino Rodriguez	Sales Manager	Lisboa	\N	1675	Portugal	(1) 354-2534	(1) 354-2535
GALED	Galería del gastrónomo	Rambla de Cataluña 23	Eduardo Saavedra	Marketing Manager	Barcelona	\N	8022	Spain	(93) 203 4560	(93) 203 4561
GODOS	Godos Cocina Típica	C/ Romero 33	José Pedro Freyre	Sales Manager	Sevilla	\N	41101	Spain	(95) 555 82 82	\N
GOURL	Gourmet Lanchonetes	Av. Brasil 442	André Fonseca	Sales Associate	Campinas	SP	04876-786	Brazil	(11) 555-9482	\N
GREAL	Great Lakes Food Market	2732 Baker Blvd.	Howard Snyder	Marketing Manager	Eugene	OR	97403	USA	(503) 555-7555	\N
GROSR	GROSELLA-Restaurante	5ª Ave. Los Palos Grandes	Manuel Pereira	Owner	Caracas	DF	1081	Venezuela	(2) 283-2951	(2) 283-3397
HANAR	Hanari Carnes	Rua do Paço 67	Mario Pontes	Accounting Manager	Rio de Janeiro	RJ	05454-876	Brazil	(21) 555-0091	(21) 555-8765
HILAA	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	Carlos Hernández	Sales Representative	San Cristóbal	Táchira	5022	Venezuela	(5) 555-1340	(5) 555-1948
HUNGC	Hungry Coyote Import Store	City Center Plaza516 Main St.	Yoshi Latimer	Sales Representative	Elgin	OR	97827	USA	(503) 555-6874	(503) 555-2376
HUNGO	Hungry Owl All-Night Grocers	8 Johnstown Road	Patricia McKenna	Sales Associate	Cork	Co. Cork	\N	Ireland	2967 542	2967 3333
ISLAT	Island Trading	Garden HouseCrowther Way	Helen Bennett	Marketing Manager	Cowes	Isle of Wight	PO31 7PJ	UK	(198) 555-8888	\N
KOENE	Königlich Essen	Maubelstr. 90	Philip Cramer	Sales Associate	Brandenburg	\N	14776	Germany	0555-09876	\N
LACOR	La corne d'abondance	67 avenue de l'Europe	Daniel Tonini	Sales Representative	Versailles	\N	78000	France	30.59.84.10	30.59.85.11
LAMAI	La maison d'Asie	1 rue Alsace-Lorraine	Annette Roulet	Sales Manager	Toulouse	\N	31000	France	61.77.61.10	61.77.61.11
LAUGB	Laughing Bacchus Wine Cellars	1900 Oak St.	Yoshi Tannamuri	Marketing Assistant	Vancouver	BC	V3F 2K1	Canada	(604) 555-3392	(604) 555-7293
LAZYK	Lazy K Kountry Store	12 Orchestra Terrace	John Steel	Marketing Manager	Walla Walla	WA	99362	USA	(509) 555-7969	(509) 555-6221
LEHMS	Lehmanns Marktstand	Magazinweg 7	Renate Messner	Sales Representative	Frankfurt a.M.	\N	60528	Germany	069-0245984	069-0245874
LETSS	Let's Stop N Shop	87 Polk St.Suite 5	Jaime Yorres	Owner	San Francisco	CA	94117	USA	(415) 555-5938	\N
LILAS	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Carlos González	Accounting Manager	Barquisimeto	Lara	3508	Venezuela	(9) 331-6954	(9) 331-7256
LINOD	LINO-Delicateses	Ave. 5 de Mayo Porlamar	Felipe Izquierdo	Owner	I. de Margarita	Nueva Esparta	4980	Venezuela	(8) 34-56-12	(8) 34-93-93
LONEP	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Fran Wilson	Sales Manager	Portland	OR	97219	USA	(503) 555-9573	(503) 555-9646
MAGAA	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Giovanni Rovelli	Marketing Manager	Bergamo	\N	24100	Italy	035-640230	035-640231
MAISD	Maison Dewey	Rue Joseph-Bens 532	Catherine Dewey	Sales Agent	Bruxelles	\N	B-1180	Belgium	(02) 201 24 67	(02) 201 24 68
MEREP	Mère Paillarde	43 rue St. Laurent	Jean Fresnière	Marketing Assistant	Montréal	Québec	H1J 1C3	Canada	(514) 555-8054	(514) 555-8055
MORGK	Morgenstern Gesundkost	Heerstr. 22	Alexander Feuer	Marketing Assistant	Leipzig	\N	4179	Germany	0342-023176	\N
NORTS	North/South	South House300 Queensbridge	Simon Crowther	Sales Associate	London	\N	SW7 1RZ	UK	(171) 555-7733	(171) 555-2530
OCEAN	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585Piso 20-A	Yvonne Moncada	Sales Agent	Buenos Aires	\N	1010	Argentina	(1) 135-5333	(1) 135-5535
OLDWO	Old World Delicatessen	2743 Bering St.	Rene Phillips	Sales Representative	Anchorage	AK	99508	USA	(907) 555-7584	(907) 555-2880
OTTIK	Ottilies Käseladen	Mehrheimerstr. 369	Henriette Pfalzheim	Owner	Köln	\N	50739	Germany	0221-0644327	0221-0765721
PARIS	Paris spécialités	265 boulevard Charonne	Marie Bertrand	Owner	Paris	\N	75012	France	(1) 42.34.22.66	(1) 42.34.22.77
PERIC	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	Guillermo Fernández	Sales Representative	México D.F.	\N	5033	Mexico	(5) 552-3745	(5) 545-3745
PICCO	Piccolo und mehr	Geislweg 14	Georg Pipps	Sales Manager	Salzburg	\N	5020	Austria	6562-9722	6562-9723
PRINI	Princesa Isabel Vinhos	Estrada da saúde n. 58	Isabel de Castro	Sales Representative	Lisboa	\N	1756	Portugal	(1) 356-5634	\N
QUEDE	Que Delícia	Rua da Panificadora 12	Bernardo Batista	Accounting Manager	Rio de Janeiro	RJ	02389-673	Brazil	(21) 555-4252	(21) 555-4545
QUEEN	Queen Cozinha	Alameda dos Canàrios 891	Lúcia Carvalho	Marketing Assistant	São Paulo	SP	05487-020	Brazil	(11) 555-1189	\N
QUICK	QUICK-Stop	Taucherstraße 10	Horst Kloss	Accounting Manager	Cunewalde	\N	1307	Germany	0372-035188	\N
RANCH	Rancho grande	Av. del Libertador 900	Sergio Gutiérrez	Sales Representative	Buenos Aires	\N	1010	Argentina	(1) 123-5555	(1) 123-5556
RATTC	Rattlesnake Canyon Grocery	2817 Milton Dr.	Paula Wilson	Assistant Sales Representative	Albuquerque	NM	87110	USA	(505) 555-5939	(505) 555-3620
REGGC	Reggiani Caseifici	Strada Provinciale 124	Maurizio Moroni	Sales Associate	Reggio Emilia	\N	42100	Italy	0522-556721	0522-556722
RICAR	Ricardo Adocicados	Av. Copacabana 267	Janete Limeira	Assistant Sales Agent	Rio de Janeiro	RJ	02389-890	Brazil	(21) 555-3412	\N
RICSU	Richter Supermarkt	Grenzacherweg 237	Michael Holz	Sales Manager	Genève	\N	1203	Switzerland	0897-034214	\N
ROMEY	Romero y tomillo	Gran Vía 1	Alejandra Camino	Accounting Manager	Madrid	\N	28001	Spain	(91) 745 6200	(91) 745 6210
SANTG	Santé Gourmet	Erling Skakkes gate 78	Jonas Bergulfsen	Owner	Stavern	\N	4110	Norway	07-98 92 35	07-98 92 47
SAVEA	Save-a-lot Markets	187 Suffolk Ln.	Jose Pavarotti	Sales Representative	Boise	ID	83720	USA	(208) 555-8097	\N
SEVES	Seven Seas Imports	90 Wadhurst Rd.	Hari Kumar	Sales Manager	London	\N	OX15 4NB	UK	(171) 555-1717	(171) 555-5646
SIMOB	Simons bistro	Vinbæltet 34	Jytte Petersen	Owner	København	\N	1734	Denmark	31 12 34 56	31 13 35 57
SPECD	Spécialités du monde	25 rue Lauriston	Dominique Perrier	Marketing Manager	Paris	\N	75016	France	(1) 47.55.60.10	(1) 47.55.60.20
SPLIR	Split Rail Beer & Ale	P.O. Box 555	Art Braunschweiger	Sales Manager	Lander	WY	82520	USA	(307) 555-4680	(307) 555-6525
SUPRD	Suprêmes délices	Boulevard Tirou 255	Pascale Cartrain	Accounting Manager	Charleroi	\N	B-6000	Belgium	(071) 23 67 22 20	(071) 23 67 22 21
THEBI	The Big Cheese	89 Jefferson WaySuite 2	Liz Nixon	Marketing Manager	Portland	OR	97201	USA	(503) 555-3612	\N
THECR	The Cracker Box	55 Grizzly Peak Rd.	Liu Wong	Marketing Assistant	Butte	MT	59801	USA	(406) 555-5834	(406) 555-8083
TOMSP	Toms Spezialitäten	Luisenstr. 48	Karin Josephs	Marketing Manager	Münster	\N	44087	Germany	0251-031259	0251-035695
TORTU	Tortuga Restaurante	Avda. Azteca 123	Miguel Angel Paolino	Owner	México D.F.	\N	5033	Mexico	(5) 555-2933	\N
TRADH	Tradição Hipermercados	Av. Inês de Castro 414	Anabela Domingues	Sales Representative	São Paulo	SP	05634-030	Brazil	(11) 555-2167	(11) 555-2168
TRAIH	Trail's Head Gourmet Provisioners	722 DaVinci Blvd.	Helvetius Nagy	Sales Associate	Kirkland	WA	98034	USA	(206) 555-8257	(206) 555-2174
VAFFE	Vaffeljernet	Smagsløget 45	Palle Ibsen	Sales Manager	Århus	\N	8200	Denmark	86 21 32 43	86 22 33 44
VICTE	Victuailles en stock	2 rue du Commerce	Mary Saveley	Sales Agent	Lyon	\N	69004	France	78.32.54.86	78.32.54.87
VINET	Vins et alcools Chevalier	59 rue de l'Abbaye	Paul Henriot	Accounting Manager	Reims	\N	51100	France	26.47.15.10	26.47.15.11
WANDK	Die Wandernde Kuh	Adenauerallee 900	Rita Müller	Sales Representative	Stuttgart	\N	70563	Germany	0711-020361	0711-035428
WARTH	Wartian Herkku	Torikatu 38	Pirkko Koskitalo	Accounting Manager	Oulu	\N	90110	Finland	981-443655	981-443655
WELLI	Wellington Importadora	Rua do Mercado 12	Paula Parente	Sales Manager	Resende	SP	08737-363	Brazil	(14) 555-8122	\N
WHITC	White Clover Markets	305 - 14th Ave. S.Suite 3B	Karl Jablonski	Owner	Seattle	WA	98128	USA	(206) 555-4112	(206) 555-4115
WILMK	Wilman Kala	Keskuskatu 45	Matti Karttunen	Owner/Marketing Assistant	Helsinki	\N	21240	Finland	90-224 8858	90-224 8858
WOLZA	Wolski  Zajazd	ul. Filtrowa 68	Zbyszek Piestrzeniewicz	Owner	Warszawa	\N	01-012	Poland	(26) 642-7012	(26) 642-7012
\.


--
-- Data for Name: orderdetails; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orderdetails (orderid, productid, productname, unitprice, quantity, discount, totaldiscount) FROM stdin;
10248	11	Queso Cabrales	14.0	12	0.0	0.0
10248	42	Singaporean Hokkien Fried Mee	9.8	10	0.0	0.0
10248	72	Mozzarella di Giovanni	34.8	5	0.0	0.0
10249	14	Tofu	18.6	9	0.0	0.0
10249	51	Manjimup Dried Apples	42.4	40	0.0	0.0
10250	41	Jack's New England Clam Chowder	7.7	10	0.0	0.0
10250	51	Manjimup Dried Apples	42.4	35	0.15	222.6
10250	65	Louisiana Fiery Hot Pepper Sauce	16.8	15	0.15	37.8
10251	22	Gustaf's Knäckebröd	16.8	6	0.05	5.04
10251	57	Ravioli Angelo	15.6	15	0.05	11.7
10251	65	Louisiana Fiery Hot Pepper Sauce	16.8	20	0.0	0.0
10252	20	Sir Rodney's Marmalade	64.8	40	0.05	129.6
10252	33	Geitost	2.0	25	0.05	2.5
10252	60	Camembert Pierrot	27.2	40	0.0	0.0
10253	31	Gorgonzola Telino	10.0	20	0.0	0.0
10253	39	Chartreuse verte	14.4	42	0.0	0.0
10253	49	Maxilaku	16.0	40	0.0	0.0
10254	24	Guaraná Fantástica	3.6	15	0.15	8.1
10254	55	Pâté chinois	19.2	21	0.15	60.48
10254	74	Longlife Tofu	8.0	21	0.0	0.0
10255	2	Chang	15.2	20	0.0	0.0
10255	16	Pavlova	13.9	35	0.0	0.0
10255	36	Inlagd Sill	15.2	25	0.0	0.0
10255	59	Raclette Courdavault	44.0	30	0.0	0.0
10256	53	Perth Pasties	26.2	15	0.0	0.0
10256	77	Original Frankfurter grüne Soße	10.4	12	0.0	0.0
10257	27	Schoggi Schokolade	35.1	25	0.0	0.0
10257	39	Chartreuse verte	14.4	6	0.0	0.0
10257	77	Original Frankfurter grüne Soße	10.4	15	0.0	0.0
10258	2	Chang	15.2	50	0.2	152.0
10258	5	Chef Anton's Gumbo Mix	17.0	65	0.2	221.0
10258	32	Mascarpone Fabioli	25.6	6	0.2	30.72
10259	21	Sir Rodney's Scones	8.0	10	0.0	0.0
10259	37	Gravad lax	20.8	1	0.0	0.0
10260	41	Jack's New England Clam Chowder	7.7	16	0.25	30.8
10260	57	Ravioli Angelo	15.6	50	0.0	0.0
10260	62	Tarte au sucre	39.4	15	0.25	147.75
10260	70	Outback Lager	12.0	21	0.25	63.0
10261	21	Sir Rodney's Scones	8.0	20	0.0	0.0
10261	35	Steeleye Stout	14.4	20	0.0	0.0
10262	5	Chef Anton's Gumbo Mix	17.0	12	0.2	40.8
10262	7	Uncle Bob's Organic Dried Pears	24.0	15	0.0	0.0
10262	56	Gnocchi di nonna Alice	30.4	2	0.0	0.0
10263	16	Pavlova	13.9	60	0.25	208.5
10263	24	Guaraná Fantástica	3.6	28	0.0	0.0
10263	30	Nord-Ost Matjeshering	20.7	60	0.25	310.5
10263	74	Longlife Tofu	8.0	36	0.25	72.0
10264	2	Chang	15.2	35	0.0	0.0
10264	41	Jack's New England Clam Chowder	7.7	25	0.15	28.87
10265	17	Alice Mutton	31.2	30	0.0	0.0
10265	70	Outback Lager	12.0	20	0.0	0.0
10266	12	Queso Manchego La Pastora	30.4	12	0.05	18.24
10267	40	Boston Crab Meat	14.7	50	0.0	0.0
10267	59	Raclette Courdavault	44.0	70	0.15	462.0
10267	76	Lakkalikööri	14.4	15	0.15	32.4
10268	29	Thüringer Rostbratwurst	99.0	10	0.0	0.0
10268	72	Mozzarella di Giovanni	27.8	4	0.0	0.0
10269	33	Geitost	2.0	60	0.05	6.0
10269	72	Mozzarella di Giovanni	27.8	20	0.05	27.8
10270	36	Inlagd Sill	15.2	30	0.0	0.0
10270	43	Ipoh Coffee	36.8	25	0.0	0.0
10271	33	Geitost	2.0	24	0.0	0.0
10272	20	Sir Rodney's Marmalade	64.8	6	0.0	0.0
10272	31	Gorgonzola Telino	10.0	40	0.0	0.0
10272	72	Mozzarella di Giovanni	27.8	24	0.0	0.0
10273	10	Ikura	24.8	24	0.05	29.76
10273	31	Gorgonzola Telino	10.0	15	0.05	7.5
10273	33	Geitost	2.0	20	0.0	0.0
10273	40	Boston Crab Meat	14.7	60	0.05	44.1
10273	76	Lakkalikööri	14.4	33	0.05	23.76
10274	71	Fløtemysost	17.2	20	0.0	0.0
10274	72	Mozzarella di Giovanni	27.8	7	0.0	0.0
10275	24	Guaraná Fantástica	3.6	12	0.05	2.16
10275	59	Raclette Courdavault	44.0	6	0.05	13.2
10276	10	Ikura	24.8	15	0.0	0.0
10276	13	Konbu	4.8	10	0.0	0.0
10277	28	Rössle Sauerkraut	36.4	20	0.0	0.0
10277	62	Tarte au sucre	39.4	12	0.0	0.0
10278	44	Gula Malacca	15.5	16	0.0	0.0
10278	59	Raclette Courdavault	44.0	15	0.0	0.0
10278	63	Vegie-spread	35.1	8	0.0	0.0
10278	73	Röd Kaviar	12.0	25	0.0	0.0
10279	17	Alice Mutton	31.2	15	0.25	117.0
10280	24	Guaraná Fantástica	3.6	12	0.0	0.0
10280	55	Pâté chinois	19.2	20	0.0	0.0
10280	75	Rhönbräu Klosterbier	6.2	30	0.0	0.0
10281	19	Teatime Chocolate Biscuits	7.3	1	0.0	0.0
10281	24	Guaraná Fantástica	3.6	6	0.0	0.0
10281	35	Steeleye Stout	14.4	4	0.0	0.0
10282	30	Nord-Ost Matjeshering	20.7	6	0.0	0.0
10282	57	Ravioli Angelo	15.6	2	0.0	0.0
10283	15	Genen Shouyu	12.4	20	0.0	0.0
10283	19	Teatime Chocolate Biscuits	7.3	18	0.0	0.0
10283	60	Camembert Pierrot	27.2	35	0.0	0.0
10283	72	Mozzarella di Giovanni	27.8	3	0.0	0.0
10284	27	Schoggi Schokolade	35.1	15	0.25	131.62
10284	44	Gula Malacca	15.5	21	0.0	0.0
10284	60	Camembert Pierrot	27.2	20	0.25	136.0
10284	67	Laughing Lumberjack Lager	11.2	5	0.25	14.0
10285	1	Chai	14.4	45	0.2	129.6
10285	40	Boston Crab Meat	14.7	40	0.2	117.6
10285	53	Perth Pasties	26.2	36	0.2	188.64
10286	35	Steeleye Stout	14.4	100	0.0	0.0
10286	62	Tarte au sucre	39.4	40	0.0	0.0
10287	16	Pavlova	13.9	40	0.15	83.4
10287	34	Sasquatch Ale	11.2	20	0.0	0.0
10287	46	Spegesild	9.6	15	0.15	21.6
10288	54	Tourtière	5.9	10	0.1	5.9
10288	68	Scottish Longbreads	10.0	3	0.1	3.0
10289	3	Aniseed Syrup	8.0	30	0.0	0.0
10289	64	Wimmers gute Semmelknödel	26.6	9	0.0	0.0
10290	5	Chef Anton's Gumbo Mix	17.0	20	0.0	0.0
10290	29	Thüringer Rostbratwurst	99.0	15	0.0	0.0
10290	49	Maxilaku	16.0	15	0.0	0.0
10290	77	Original Frankfurter grüne Soße	10.4	10	0.0	0.0
10291	13	Konbu	4.8	20	0.1	9.6
10291	44	Gula Malacca	15.5	24	0.1	37.2
10291	51	Manjimup Dried Apples	42.4	2	0.1	8.48
10292	20	Sir Rodney's Marmalade	64.8	20	0.0	0.0
10293	18	Carnarvon Tigers	50.0	12	0.0	0.0
10293	24	Guaraná Fantástica	3.6	10	0.0	0.0
10293	63	Vegie-spread	35.1	5	0.0	0.0
10293	75	Rhönbräu Klosterbier	6.2	6	0.0	0.0
10294	1	Chai	14.4	18	0.0	0.0
10294	17	Alice Mutton	31.2	15	0.0	0.0
10294	43	Ipoh Coffee	36.8	15	0.0	0.0
10294	60	Camembert Pierrot	27.2	21	0.0	0.0
10294	75	Rhönbräu Klosterbier	6.2	6	0.0	0.0
10295	56	Gnocchi di nonna Alice	30.4	4	0.0	0.0
10296	11	Queso Cabrales	16.8	12	0.0	0.0
10296	16	Pavlova	13.9	30	0.0	0.0
10296	69	Gudbrandsdalsost	28.8	15	0.0	0.0
10297	39	Chartreuse verte	14.4	60	0.0	0.0
10297	72	Mozzarella di Giovanni	27.8	20	0.0	0.0
10298	2	Chang	15.2	40	0.0	0.0
10298	36	Inlagd Sill	15.2	40	0.25	152.0
10298	59	Raclette Courdavault	44.0	30	0.25	330.0
10298	62	Tarte au sucre	39.4	15	0.0	0.0
10299	19	Teatime Chocolate Biscuits	7.3	15	0.0	0.0
10299	70	Outback Lager	12.0	20	0.0	0.0
10300	66	Louisiana Hot Spiced Okra	13.6	30	0.0	0.0
10300	68	Scottish Longbreads	10.0	20	0.0	0.0
10301	40	Boston Crab Meat	14.7	10	0.0	0.0
10301	56	Gnocchi di nonna Alice	30.4	20	0.0	0.0
10302	17	Alice Mutton	31.2	40	0.0	0.0
10302	28	Rössle Sauerkraut	36.4	28	0.0	0.0
10302	43	Ipoh Coffee	36.8	12	0.0	0.0
10303	40	Boston Crab Meat	14.7	40	0.1	58.8
10303	65	Louisiana Fiery Hot Pepper Sauce	16.8	30	0.1	50.4
10303	68	Scottish Longbreads	10.0	15	0.1	15.0
10304	49	Maxilaku	16.0	30	0.0	0.0
10304	59	Raclette Courdavault	44.0	10	0.0	0.0
10304	71	Fløtemysost	17.2	2	0.0	0.0
10305	18	Carnarvon Tigers	50.0	25	0.1	125.0
10305	29	Thüringer Rostbratwurst	99.0	25	0.1	247.5
10305	39	Chartreuse verte	14.4	30	0.1	43.2
10306	30	Nord-Ost Matjeshering	20.7	10	0.0	0.0
10306	53	Perth Pasties	26.2	10	0.0	0.0
10306	54	Tourtière	5.9	5	0.0	0.0
10307	62	Tarte au sucre	39.4	10	0.0	0.0
10307	68	Scottish Longbreads	10.0	3	0.0	0.0
10308	69	Gudbrandsdalsost	28.8	1	0.0	0.0
10308	70	Outback Lager	12.0	5	0.0	0.0
10309	4	Chef Anton's Cajun Seasoning	17.6	20	0.0	0.0
10309	6	Grandma's Boysenberry Spread	20.0	30	0.0	0.0
10309	42	Singaporean Hokkien Fried Mee	11.2	2	0.0	0.0
10309	43	Ipoh Coffee	36.8	20	0.0	0.0
10309	71	Fløtemysost	17.2	3	0.0	0.0
10310	16	Pavlova	13.9	10	0.0	0.0
10310	62	Tarte au sucre	39.4	5	0.0	0.0
10311	42	Singaporean Hokkien Fried Mee	11.2	6	0.0	0.0
10311	69	Gudbrandsdalsost	28.8	7	0.0	0.0
10312	28	Rössle Sauerkraut	36.4	4	0.0	0.0
10312	43	Ipoh Coffee	36.8	24	0.0	0.0
10312	53	Perth Pasties	26.2	20	0.0	0.0
10312	75	Rhönbräu Klosterbier	6.2	10	0.0	0.0
10313	36	Inlagd Sill	15.2	12	0.0	0.0
10314	32	Mascarpone Fabioli	25.6	40	0.1	102.4
10314	58	Escargots de Bourgogne	10.6	30	0.1	31.8
10314	62	Tarte au sucre	39.4	25	0.1	98.5
10315	34	Sasquatch Ale	11.2	14	0.0	0.0
10315	70	Outback Lager	12.0	30	0.0	0.0
10316	41	Jack's New England Clam Chowder	7.7	10	0.0	0.0
10316	62	Tarte au sucre	39.4	70	0.0	0.0
10317	1	Chai	14.4	20	0.0	0.0
10318	41	Jack's New England Clam Chowder	7.7	20	0.0	0.0
10318	76	Lakkalikööri	14.4	6	0.0	0.0
10319	17	Alice Mutton	31.2	8	0.0	0.0
10319	28	Rössle Sauerkraut	36.4	14	0.0	0.0
10319	76	Lakkalikööri	14.4	30	0.0	0.0
10320	71	Fløtemysost	17.2	30	0.0	0.0
10321	35	Steeleye Stout	14.4	10	0.0	0.0
10322	52	Filo Mix	5.6	20	0.0	0.0
10323	15	Genen Shouyu	12.4	5	0.0	0.0
10323	25	NuNuCa Nuß-Nougat-Creme	11.2	4	0.0	0.0
10323	39	Chartreuse verte	14.4	4	0.0	0.0
10324	16	Pavlova	13.9	21	0.15	43.78
10324	35	Steeleye Stout	14.4	70	0.15	151.2
10324	46	Spegesild	9.6	30	0.0	0.0
10324	59	Raclette Courdavault	44.0	40	0.15	264.0
10324	63	Vegie-spread	35.1	80	0.15	421.2
10325	6	Grandma's Boysenberry Spread	20.0	6	0.0	0.0
10325	13	Konbu	4.8	12	0.0	0.0
10325	14	Tofu	18.6	9	0.0	0.0
10325	31	Gorgonzola Telino	10.0	4	0.0	0.0
10325	72	Mozzarella di Giovanni	27.8	40	0.0	0.0
10326	4	Chef Anton's Cajun Seasoning	17.6	24	0.0	0.0
10326	57	Ravioli Angelo	15.6	16	0.0	0.0
10326	75	Rhönbräu Klosterbier	6.2	50	0.0	0.0
10327	2	Chang	15.2	25	0.2	76.0
10327	11	Queso Cabrales	16.8	50	0.2	168.0
10406	1	Chai	14.4	10	0.0	0.0
10327	30	Nord-Ost Matjeshering	20.7	35	0.2	144.9
10327	58	Escargots de Bourgogne	10.6	30	0.2	63.6
10328	59	Raclette Courdavault	44.0	9	0.0	0.0
10328	65	Louisiana Fiery Hot Pepper Sauce	16.8	40	0.0	0.0
10328	68	Scottish Longbreads	10.0	10	0.0	0.0
10329	19	Teatime Chocolate Biscuits	7.3	10	0.05	3.65
10329	30	Nord-Ost Matjeshering	20.7	8	0.05	8.28
10329	38	Côte de Blaye	210.8	20	0.05	210.8
10329	56	Gnocchi di nonna Alice	30.4	12	0.05	18.24
10330	26	Gumbär Gummibärchen	24.9	50	0.15	186.75
10330	72	Mozzarella di Giovanni	27.8	25	0.15	104.25
10331	54	Tourtière	5.9	15	0.0	0.0
10332	18	Carnarvon Tigers	50.0	40	0.2	400.0
10332	42	Singaporean Hokkien Fried Mee	11.2	10	0.2	22.4
10332	47	Zaanse koeken	7.6	16	0.2	24.32
10333	14	Tofu	18.6	10	0.0	0.0
10333	21	Sir Rodney's Scones	8.0	10	0.1	8.0
10333	71	Fløtemysost	17.2	40	0.1	68.8
10334	52	Filo Mix	5.6	8	0.0	0.0
10334	68	Scottish Longbreads	10.0	10	0.0	0.0
10335	2	Chang	15.2	7	0.2	21.28
10335	31	Gorgonzola Telino	10.0	25	0.2	50.0
10335	32	Mascarpone Fabioli	25.6	6	0.2	30.72
10335	51	Manjimup Dried Apples	42.4	48	0.2	407.04
10336	4	Chef Anton's Cajun Seasoning	17.6	18	0.1	31.68
10337	23	Tunnbröd	7.2	40	0.0	0.0
10337	26	Gumbär Gummibärchen	24.9	24	0.0	0.0
10337	36	Inlagd Sill	15.2	20	0.0	0.0
10337	37	Gravad lax	20.8	28	0.0	0.0
10337	72	Mozzarella di Giovanni	27.8	25	0.0	0.0
10338	17	Alice Mutton	31.2	20	0.0	0.0
10338	30	Nord-Ost Matjeshering	20.7	15	0.0	0.0
10339	4	Chef Anton's Cajun Seasoning	17.6	10	0.0	0.0
10339	17	Alice Mutton	31.2	70	0.05	109.2
10339	62	Tarte au sucre	39.4	28	0.0	0.0
10340	18	Carnarvon Tigers	50.0	20	0.05	50.0
10340	41	Jack's New England Clam Chowder	7.7	12	0.05	4.62
10340	43	Ipoh Coffee	36.8	40	0.05	73.6
10341	33	Geitost	2.0	8	0.0	0.0
10341	59	Raclette Courdavault	44.0	9	0.15	59.4
10342	2	Chang	15.2	24	0.2	72.96
10342	31	Gorgonzola Telino	10.0	56	0.2	112.0
10342	36	Inlagd Sill	15.2	40	0.2	121.6
10342	55	Pâté chinois	19.2	40	0.2	153.6
10343	64	Wimmers gute Semmelknödel	26.6	50	0.0	0.0
10343	68	Scottish Longbreads	10.0	4	0.05	2.0
10343	76	Lakkalikööri	14.4	15	0.0	0.0
10344	4	Chef Anton's Cajun Seasoning	17.6	35	0.0	0.0
10344	8	Northwoods Cranberry Sauce	32.0	70	0.25	560.0
10345	8	Northwoods Cranberry Sauce	32.0	70	0.0	0.0
10345	19	Teatime Chocolate Biscuits	7.3	80	0.0	0.0
10345	42	Singaporean Hokkien Fried Mee	11.2	9	0.0	0.0
10346	17	Alice Mutton	31.2	36	0.1	112.32
10346	56	Gnocchi di nonna Alice	30.4	20	0.0	0.0
10347	25	NuNuCa Nuß-Nougat-Creme	11.2	10	0.0	0.0
10347	39	Chartreuse verte	14.4	50	0.15	108.0
10347	40	Boston Crab Meat	14.7	4	0.0	0.0
10347	75	Rhönbräu Klosterbier	6.2	6	0.15	5.58
10348	1	Chai	14.4	15	0.15	32.4
10348	23	Tunnbröd	7.2	25	0.0	0.0
10349	54	Tourtière	5.9	24	0.0	0.0
10350	50	Valkoinen suklaa	13.0	15	0.1	19.5
10350	69	Gudbrandsdalsost	28.8	18	0.1	51.84
10351	38	Côte de Blaye	210.8	20	0.05	210.8
10351	41	Jack's New England Clam Chowder	7.7	13	0.0	0.0
10351	44	Gula Malacca	15.5	77	0.05	59.67
10351	65	Louisiana Fiery Hot Pepper Sauce	16.8	10	0.05	8.4
10352	24	Guaraná Fantástica	3.6	10	0.0	0.0
10352	54	Tourtière	5.9	20	0.15	17.7
10353	11	Queso Cabrales	16.8	12	0.2	40.32
10353	38	Côte de Blaye	210.8	50	0.2	2108.0
10354	1	Chai	14.4	12	0.0	0.0
10354	29	Thüringer Rostbratwurst	99.0	4	0.0	0.0
10355	24	Guaraná Fantástica	3.6	25	0.0	0.0
10355	57	Ravioli Angelo	15.6	25	0.0	0.0
10356	31	Gorgonzola Telino	10.0	30	0.0	0.0
10356	55	Pâté chinois	19.2	12	0.0	0.0
10356	69	Gudbrandsdalsost	28.8	20	0.0	0.0
10357	10	Ikura	24.8	30	0.2	148.8
10357	26	Gumbär Gummibärchen	24.9	16	0.0	0.0
10357	60	Camembert Pierrot	27.2	8	0.2	43.52
10358	24	Guaraná Fantástica	3.6	10	0.05	1.8
10358	34	Sasquatch Ale	11.2	10	0.05	5.6
10358	36	Inlagd Sill	15.2	20	0.05	15.2
10359	16	Pavlova	13.9	56	0.05	38.92
10359	31	Gorgonzola Telino	10.0	70	0.05	35.0
10359	60	Camembert Pierrot	27.2	80	0.05	108.8
10360	28	Rössle Sauerkraut	36.4	30	0.0	0.0
10360	29	Thüringer Rostbratwurst	99.0	35	0.0	0.0
10360	38	Côte de Blaye	210.8	10	0.0	0.0
10360	49	Maxilaku	16.0	35	0.0	0.0
10360	54	Tourtière	5.9	28	0.0	0.0
10361	39	Chartreuse verte	14.4	54	0.1	77.76
10361	60	Camembert Pierrot	27.2	55	0.1	149.6
10362	25	NuNuCa Nuß-Nougat-Creme	11.2	50	0.0	0.0
10362	51	Manjimup Dried Apples	42.4	20	0.0	0.0
10362	54	Tourtière	5.9	24	0.0	0.0
10363	31	Gorgonzola Telino	10.0	20	0.0	0.0
10363	75	Rhönbräu Klosterbier	6.2	12	0.0	0.0
10363	76	Lakkalikööri	14.4	12	0.0	0.0
10364	69	Gudbrandsdalsost	28.8	30	0.0	0.0
10364	71	Fløtemysost	17.2	5	0.0	0.0
10365	11	Queso Cabrales	16.8	24	0.0	0.0
10366	65	Louisiana Fiery Hot Pepper Sauce	16.8	5	0.0	0.0
10366	77	Original Frankfurter grüne Soße	10.4	5	0.0	0.0
10367	34	Sasquatch Ale	11.2	36	0.0	0.0
10367	54	Tourtière	5.9	18	0.0	0.0
10367	65	Louisiana Fiery Hot Pepper Sauce	16.8	15	0.0	0.0
10367	77	Original Frankfurter grüne Soße	10.4	7	0.0	0.0
10368	21	Sir Rodney's Scones	8.0	5	0.1	4.0
10368	28	Rössle Sauerkraut	36.4	13	0.1	47.32
10368	57	Ravioli Angelo	15.6	25	0.0	0.0
10368	64	Wimmers gute Semmelknödel	26.6	35	0.1	93.1
10369	29	Thüringer Rostbratwurst	99.0	20	0.0	0.0
10369	56	Gnocchi di nonna Alice	30.4	18	0.25	136.8
10370	1	Chai	14.4	15	0.15	32.4
10370	64	Wimmers gute Semmelknödel	26.6	30	0.0	0.0
10370	74	Longlife Tofu	8.0	20	0.15	24.0
10371	36	Inlagd Sill	15.2	6	0.2	18.24
10372	20	Sir Rodney's Marmalade	64.8	12	0.25	194.4
10372	38	Côte de Blaye	210.8	40	0.25	2108.0
10372	60	Camembert Pierrot	27.2	70	0.25	476.0
10372	72	Mozzarella di Giovanni	27.8	42	0.25	291.9
10373	58	Escargots de Bourgogne	10.6	80	0.2	169.6
10373	71	Fløtemysost	17.2	50	0.2	172.0
10374	31	Gorgonzola Telino	10.0	30	0.0	0.0
10374	58	Escargots de Bourgogne	10.6	15	0.0	0.0
10375	14	Tofu	18.6	15	0.0	0.0
10375	54	Tourtière	5.9	10	0.0	0.0
10376	31	Gorgonzola Telino	10.0	42	0.05	21.0
10377	28	Rössle Sauerkraut	36.4	20	0.15	109.2
10377	39	Chartreuse verte	14.4	20	0.15	43.2
10378	71	Fløtemysost	17.2	6	0.0	0.0
10379	41	Jack's New England Clam Chowder	7.7	8	0.1	6.16
10379	63	Vegie-spread	35.1	16	0.1	56.16
10379	65	Louisiana Fiery Hot Pepper Sauce	16.8	20	0.1	33.6
10380	30	Nord-Ost Matjeshering	20.7	18	0.1	37.26
10380	53	Perth Pasties	26.2	20	0.1	52.4
10380	60	Camembert Pierrot	27.2	6	0.1	16.32
10380	70	Outback Lager	12.0	30	0.0	0.0
10381	74	Longlife Tofu	8.0	14	0.0	0.0
10382	5	Chef Anton's Gumbo Mix	17.0	32	0.0	0.0
10382	18	Carnarvon Tigers	50.0	9	0.0	0.0
10382	29	Thüringer Rostbratwurst	99.0	14	0.0	0.0
10382	33	Geitost	2.0	60	0.0	0.0
10382	74	Longlife Tofu	8.0	50	0.0	0.0
10383	13	Konbu	4.8	20	0.0	0.0
10383	50	Valkoinen suklaa	13.0	15	0.0	0.0
10383	56	Gnocchi di nonna Alice	30.4	20	0.0	0.0
10384	20	Sir Rodney's Marmalade	64.8	28	0.0	0.0
10384	60	Camembert Pierrot	27.2	15	0.0	0.0
10385	7	Uncle Bob's Organic Dried Pears	24.0	10	0.2	48.0
10385	60	Camembert Pierrot	27.2	20	0.2	108.8
10385	68	Scottish Longbreads	10.0	8	0.2	16.0
10386	24	Guaraná Fantástica	3.6	15	0.0	0.0
10386	34	Sasquatch Ale	11.2	10	0.0	0.0
10387	24	Guaraná Fantástica	3.6	15	0.0	0.0
10387	28	Rössle Sauerkraut	36.4	6	0.0	0.0
10387	59	Raclette Courdavault	44.0	12	0.0	0.0
10387	71	Fløtemysost	17.2	15	0.0	0.0
10388	45	Røgede sild	7.6	15	0.2	22.8
10388	52	Filo Mix	5.6	20	0.2	22.4
10388	53	Perth Pasties	26.2	40	0.0	0.0
10389	10	Ikura	24.8	16	0.0	0.0
10389	55	Pâté chinois	19.2	15	0.0	0.0
10389	62	Tarte au sucre	39.4	20	0.0	0.0
10389	70	Outback Lager	12.0	30	0.0	0.0
10390	31	Gorgonzola Telino	10.0	60	0.1	60.0
10390	35	Steeleye Stout	14.4	40	0.1	57.6
10390	46	Spegesild	9.6	45	0.0	0.0
10390	72	Mozzarella di Giovanni	27.8	24	0.1	66.72
10391	13	Konbu	4.8	18	0.0	0.0
10392	69	Gudbrandsdalsost	28.8	50	0.0	0.0
10393	2	Chang	15.2	25	0.25	95.0
10393	14	Tofu	18.6	42	0.25	195.3
10393	25	NuNuCa Nuß-Nougat-Creme	11.2	7	0.25	19.6
10393	26	Gumbär Gummibärchen	24.9	70	0.25	435.75
10393	31	Gorgonzola Telino	10.0	32	0.0	0.0
10394	13	Konbu	4.8	10	0.0	0.0
10394	62	Tarte au sucre	39.4	10	0.0	0.0
10395	46	Spegesild	9.6	28	0.1	26.88
10395	53	Perth Pasties	26.2	70	0.1	183.4
10395	69	Gudbrandsdalsost	28.8	8	0.0	0.0
10396	23	Tunnbröd	7.2	40	0.0	0.0
10396	71	Fløtemysost	17.2	60	0.0	0.0
10396	72	Mozzarella di Giovanni	27.8	21	0.0	0.0
10397	21	Sir Rodney's Scones	8.0	10	0.15	12.0
10397	51	Manjimup Dried Apples	42.4	18	0.15	114.48
10398	35	Steeleye Stout	14.4	30	0.0	0.0
10398	55	Pâté chinois	19.2	120	0.1	230.4
10399	68	Scottish Longbreads	10.0	60	0.0	0.0
10399	71	Fløtemysost	17.2	30	0.0	0.0
10399	76	Lakkalikööri	14.4	35	0.0	0.0
10399	77	Original Frankfurter grüne Soße	10.4	14	0.0	0.0
10400	29	Thüringer Rostbratwurst	99.0	21	0.0	0.0
10400	35	Steeleye Stout	14.4	35	0.0	0.0
10400	49	Maxilaku	16.0	30	0.0	0.0
10401	30	Nord-Ost Matjeshering	20.7	18	0.0	0.0
10401	56	Gnocchi di nonna Alice	30.4	70	0.0	0.0
10401	65	Louisiana Fiery Hot Pepper Sauce	16.8	20	0.0	0.0
10401	71	Fløtemysost	17.2	60	0.0	0.0
10402	23	Tunnbröd	7.2	60	0.0	0.0
10402	63	Vegie-spread	35.1	65	0.0	0.0
10403	16	Pavlova	13.9	21	0.15	43.78
10403	48	Chocolade	10.2	70	0.15	107.1
10404	26	Gumbär Gummibärchen	24.9	30	0.05	37.35
10404	42	Singaporean Hokkien Fried Mee	11.2	40	0.05	22.4
10404	49	Maxilaku	16.0	30	0.05	24.0
10405	3	Aniseed Syrup	8.0	50	0.0	0.0
10406	21	Sir Rodney's Scones	8.0	30	0.1	24.0
10406	28	Rössle Sauerkraut	36.4	42	0.1	152.88
10406	36	Inlagd Sill	15.2	5	0.1	7.6
10406	40	Boston Crab Meat	14.7	2	0.1	2.94
10407	11	Queso Cabrales	16.8	30	0.0	0.0
10407	69	Gudbrandsdalsost	28.8	15	0.0	0.0
10407	71	Fløtemysost	17.2	15	0.0	0.0
10408	37	Gravad lax	20.8	10	0.0	0.0
10408	54	Tourtière	5.9	6	0.0	0.0
10408	62	Tarte au sucre	39.4	35	0.0	0.0
10409	14	Tofu	18.6	12	0.0	0.0
10409	21	Sir Rodney's Scones	8.0	12	0.0	0.0
10410	33	Geitost	2.0	49	0.0	0.0
10410	59	Raclette Courdavault	44.0	16	0.0	0.0
10411	41	Jack's New England Clam Chowder	7.7	25	0.2	38.5
10411	44	Gula Malacca	15.5	40	0.2	124.0
10411	59	Raclette Courdavault	44.0	9	0.2	79.2
10412	14	Tofu	18.6	20	0.1	37.2
10413	1	Chai	14.4	24	0.0	0.0
10413	62	Tarte au sucre	39.4	40	0.0	0.0
10413	76	Lakkalikööri	14.4	14	0.0	0.0
10414	19	Teatime Chocolate Biscuits	7.3	18	0.05	6.57
10414	33	Geitost	2.0	50	0.0	0.0
10415	17	Alice Mutton	31.2	2	0.0	0.0
10415	33	Geitost	2.0	20	0.0	0.0
10416	19	Teatime Chocolate Biscuits	7.3	20	0.0	0.0
10416	53	Perth Pasties	26.2	10	0.0	0.0
10416	57	Ravioli Angelo	15.6	20	0.0	0.0
10417	38	Côte de Blaye	210.8	50	0.0	0.0
10417	46	Spegesild	9.6	2	0.25	4.8
10417	68	Scottish Longbreads	10.0	36	0.25	90.0
10417	77	Original Frankfurter grüne Soße	10.4	35	0.0	0.0
10418	2	Chang	15.2	60	0.0	0.0
10418	47	Zaanse koeken	7.6	55	0.0	0.0
10418	61	Sirop d'érable	22.8	16	0.0	0.0
10418	74	Longlife Tofu	8.0	15	0.0	0.0
10419	60	Camembert Pierrot	27.2	60	0.05	81.6
10419	69	Gudbrandsdalsost	28.8	20	0.05	28.8
10420	9	Mishi Kobe Niku	77.6	20	0.1	155.2
10420	13	Konbu	4.8	2	0.1	0.96
10420	70	Outback Lager	12.0	8	0.1	9.6
10420	73	Röd Kaviar	12.0	20	0.1	24.0
10421	19	Teatime Chocolate Biscuits	7.3	4	0.15	4.38
10421	26	Gumbär Gummibärchen	24.9	30	0.0	0.0
10421	53	Perth Pasties	26.2	15	0.15	58.95
10421	77	Original Frankfurter grüne Soße	10.4	10	0.15	15.6
10422	26	Gumbär Gummibärchen	24.9	2	0.0	0.0
10423	31	Gorgonzola Telino	10.0	14	0.0	0.0
10423	59	Raclette Courdavault	44.0	20	0.0	0.0
10424	35	Steeleye Stout	14.4	60	0.2	172.8
10424	38	Côte de Blaye	210.8	49	0.2	2065.84
10424	68	Scottish Longbreads	10.0	30	0.2	60.0
10425	55	Pâté chinois	19.2	10	0.25	48.0
10425	76	Lakkalikööri	14.4	20	0.25	72.0
10426	56	Gnocchi di nonna Alice	30.4	5	0.0	0.0
10426	64	Wimmers gute Semmelknödel	26.6	7	0.0	0.0
10427	14	Tofu	18.6	35	0.0	0.0
10428	46	Spegesild	9.6	20	0.0	0.0
10429	50	Valkoinen suklaa	13.0	40	0.0	0.0
10429	63	Vegie-spread	35.1	35	0.25	307.12
10430	17	Alice Mutton	31.2	45	0.2	280.8
10430	21	Sir Rodney's Scones	8.0	50	0.0	0.0
10430	56	Gnocchi di nonna Alice	30.4	30	0.0	0.0
10430	59	Raclette Courdavault	44.0	70	0.2	616.0
10431	17	Alice Mutton	31.2	50	0.25	390.0
10431	40	Boston Crab Meat	14.7	50	0.25	183.75
10431	47	Zaanse koeken	7.6	30	0.25	57.0
10432	26	Gumbär Gummibärchen	24.9	10	0.0	0.0
10432	54	Tourtière	5.9	40	0.0	0.0
10433	56	Gnocchi di nonna Alice	30.4	28	0.0	0.0
10434	11	Queso Cabrales	16.8	6	0.0	0.0
10434	76	Lakkalikööri	14.4	18	0.15	38.88
10435	2	Chang	15.2	10	0.0	0.0
10435	22	Gustaf's Knäckebröd	16.8	12	0.0	0.0
10435	72	Mozzarella di Giovanni	27.8	10	0.0	0.0
10436	46	Spegesild	9.6	5	0.0	0.0
10436	56	Gnocchi di nonna Alice	30.4	40	0.1	121.6
10436	64	Wimmers gute Semmelknödel	26.6	30	0.1	79.8
10436	75	Rhönbräu Klosterbier	6.2	24	0.1	14.88
10437	53	Perth Pasties	26.2	15	0.0	0.0
10438	19	Teatime Chocolate Biscuits	7.3	15	0.2	21.9
10438	34	Sasquatch Ale	11.2	20	0.2	44.8
10438	57	Ravioli Angelo	15.6	15	0.2	46.8
10439	12	Queso Manchego La Pastora	30.4	15	0.0	0.0
10439	16	Pavlova	13.9	16	0.0	0.0
10439	64	Wimmers gute Semmelknödel	26.6	6	0.0	0.0
10439	74	Longlife Tofu	8.0	30	0.0	0.0
10440	2	Chang	15.2	45	0.15	102.6
10440	16	Pavlova	13.9	49	0.15	102.16
10440	29	Thüringer Rostbratwurst	99.0	24	0.15	356.4
10440	61	Sirop d'érable	22.8	90	0.15	307.8
10441	27	Schoggi Schokolade	35.1	50	0.0	0.0
10442	11	Queso Cabrales	16.8	30	0.0	0.0
10442	54	Tourtière	5.9	80	0.0	0.0
10442	66	Louisiana Hot Spiced Okra	13.6	60	0.0	0.0
10443	11	Queso Cabrales	16.8	6	0.2	20.16
10443	28	Rössle Sauerkraut	36.4	12	0.0	0.0
10444	17	Alice Mutton	31.2	10	0.0	0.0
10444	26	Gumbär Gummibärchen	24.9	15	0.0	0.0
10444	35	Steeleye Stout	14.4	8	0.0	0.0
10444	41	Jack's New England Clam Chowder	7.7	30	0.0	0.0
10445	39	Chartreuse verte	14.4	6	0.0	0.0
10445	54	Tourtière	5.9	15	0.0	0.0
10446	19	Teatime Chocolate Biscuits	7.3	12	0.1	8.76
10446	24	Guaraná Fantástica	3.6	20	0.1	7.2
10446	31	Gorgonzola Telino	10.0	3	0.1	3.0
10446	52	Filo Mix	5.6	15	0.1	8.4
10447	19	Teatime Chocolate Biscuits	7.3	40	0.0	0.0
10447	65	Louisiana Fiery Hot Pepper Sauce	16.8	35	0.0	0.0
10447	71	Fløtemysost	17.2	2	0.0	0.0
10448	26	Gumbär Gummibärchen	24.9	6	0.0	0.0
10448	40	Boston Crab Meat	14.7	20	0.0	0.0
10449	10	Ikura	24.8	14	0.0	0.0
10449	52	Filo Mix	5.6	20	0.0	0.0
10449	62	Tarte au sucre	39.4	35	0.0	0.0
10450	10	Ikura	24.8	20	0.2	99.2
10450	54	Tourtière	5.9	6	0.2	7.08
10451	55	Pâté chinois	19.2	120	0.1	230.4
10451	64	Wimmers gute Semmelknödel	26.6	35	0.1	93.1
10451	65	Louisiana Fiery Hot Pepper Sauce	16.8	28	0.1	47.04
10451	77	Original Frankfurter grüne Soße	10.4	55	0.1	57.2
10452	28	Rössle Sauerkraut	36.4	15	0.0	0.0
10452	44	Gula Malacca	15.5	100	0.05	77.5
10453	48	Chocolade	10.2	15	0.1	15.3
10453	70	Outback Lager	12.0	25	0.1	30.0
10454	16	Pavlova	13.9	20	0.2	55.6
10454	33	Geitost	2.0	20	0.2	8.0
10454	46	Spegesild	9.6	10	0.2	19.2
10455	39	Chartreuse verte	14.4	20	0.0	0.0
10455	53	Perth Pasties	26.2	50	0.0	0.0
10455	61	Sirop d'érable	22.8	25	0.0	0.0
10455	71	Fløtemysost	17.2	30	0.0	0.0
10456	21	Sir Rodney's Scones	8.0	40	0.15	48.0
10456	49	Maxilaku	16.0	21	0.15	50.4
10457	59	Raclette Courdavault	44.0	36	0.0	0.0
10458	26	Gumbär Gummibärchen	24.9	30	0.0	0.0
10458	28	Rössle Sauerkraut	36.4	30	0.0	0.0
10458	43	Ipoh Coffee	36.8	20	0.0	0.0
10458	56	Gnocchi di nonna Alice	30.4	15	0.0	0.0
10458	71	Fløtemysost	17.2	50	0.0	0.0
10459	7	Uncle Bob's Organic Dried Pears	24.0	16	0.05	19.2
10459	46	Spegesild	9.6	20	0.05	9.6
10459	72	Mozzarella di Giovanni	27.8	40	0.0	0.0
10460	68	Scottish Longbreads	10.0	21	0.25	52.5
10460	75	Rhönbräu Klosterbier	6.2	4	0.25	6.2
10461	21	Sir Rodney's Scones	8.0	40	0.25	80.0
10461	30	Nord-Ost Matjeshering	20.7	28	0.25	144.9
10461	55	Pâté chinois	19.2	60	0.25	288.0
10462	13	Konbu	4.8	1	0.0	0.0
10462	23	Tunnbröd	7.2	21	0.0	0.0
10463	19	Teatime Chocolate Biscuits	7.3	21	0.0	0.0
10463	42	Singaporean Hokkien Fried Mee	11.2	50	0.0	0.0
10464	4	Chef Anton's Cajun Seasoning	17.6	16	0.2	56.32
10464	43	Ipoh Coffee	36.8	3	0.0	0.0
10464	56	Gnocchi di nonna Alice	30.4	30	0.2	182.4
10464	60	Camembert Pierrot	27.2	20	0.0	0.0
10465	24	Guaraná Fantástica	3.6	25	0.0	0.0
10465	29	Thüringer Rostbratwurst	99.0	18	0.1	178.2
10465	40	Boston Crab Meat	14.7	20	0.0	0.0
10465	45	Røgede sild	7.6	30	0.1	22.8
10465	50	Valkoinen suklaa	13.0	25	0.0	0.0
10466	11	Queso Cabrales	16.8	10	0.0	0.0
10466	46	Spegesild	9.6	5	0.0	0.0
10467	24	Guaraná Fantástica	3.6	28	0.0	0.0
10467	25	NuNuCa Nuß-Nougat-Creme	11.2	12	0.0	0.0
10468	30	Nord-Ost Matjeshering	20.7	8	0.0	0.0
10468	43	Ipoh Coffee	36.8	15	0.0	0.0
10469	2	Chang	15.2	40	0.15	91.2
10469	16	Pavlova	13.9	35	0.15	72.97
10469	44	Gula Malacca	15.5	2	0.15	4.65
10470	18	Carnarvon Tigers	50.0	30	0.0	0.0
10470	23	Tunnbröd	7.2	15	0.0	0.0
10470	64	Wimmers gute Semmelknödel	26.6	8	0.0	0.0
10471	7	Uncle Bob's Organic Dried Pears	24.0	30	0.0	0.0
10471	56	Gnocchi di nonna Alice	30.4	20	0.0	0.0
10472	24	Guaraná Fantástica	3.6	80	0.05	14.4
10472	51	Manjimup Dried Apples	42.4	18	0.0	0.0
10473	33	Geitost	2.0	12	0.0	0.0
10473	71	Fløtemysost	17.2	12	0.0	0.0
10474	14	Tofu	18.6	12	0.0	0.0
10474	28	Rössle Sauerkraut	36.4	18	0.0	0.0
10474	40	Boston Crab Meat	14.7	21	0.0	0.0
10474	75	Rhönbräu Klosterbier	6.2	10	0.0	0.0
10475	31	Gorgonzola Telino	10.0	35	0.15	52.5
10475	66	Louisiana Hot Spiced Okra	13.6	60	0.15	122.4
10475	76	Lakkalikööri	14.4	42	0.15	90.72
10476	55	Pâté chinois	19.2	2	0.05	1.92
10476	70	Outback Lager	12.0	12	0.0	0.0
10477	1	Chai	14.4	15	0.0	0.0
10477	21	Sir Rodney's Scones	8.0	21	0.25	42.0
10477	39	Chartreuse verte	14.4	20	0.25	72.0
10478	10	Ikura	24.8	20	0.05	24.8
10479	38	Côte de Blaye	210.8	30	0.0	0.0
10479	53	Perth Pasties	26.2	28	0.0	0.0
10479	59	Raclette Courdavault	44.0	60	0.0	0.0
10479	64	Wimmers gute Semmelknödel	26.6	30	0.0	0.0
10480	47	Zaanse koeken	7.6	30	0.0	0.0
10480	59	Raclette Courdavault	44.0	12	0.0	0.0
10481	49	Maxilaku	16.0	24	0.0	0.0
10481	60	Camembert Pierrot	27.2	40	0.0	0.0
10482	40	Boston Crab Meat	14.7	10	0.0	0.0
10483	34	Sasquatch Ale	11.2	35	0.05	19.6
10483	77	Original Frankfurter grüne Soße	10.4	30	0.05	15.6
10484	21	Sir Rodney's Scones	8.0	14	0.0	0.0
10484	40	Boston Crab Meat	14.7	10	0.0	0.0
10484	51	Manjimup Dried Apples	42.4	3	0.0	0.0
10485	2	Chang	15.2	20	0.1	30.4
10485	3	Aniseed Syrup	8.0	20	0.1	16.0
10485	55	Pâté chinois	19.2	30	0.1	57.6
10485	70	Outback Lager	12.0	60	0.1	72.0
10486	11	Queso Cabrales	16.8	5	0.0	0.0
10486	51	Manjimup Dried Apples	42.4	25	0.0	0.0
10486	74	Longlife Tofu	8.0	16	0.0	0.0
10487	19	Teatime Chocolate Biscuits	7.3	5	0.0	0.0
10487	26	Gumbär Gummibärchen	24.9	30	0.0	0.0
10487	54	Tourtière	5.9	24	0.25	35.4
10488	59	Raclette Courdavault	44.0	30	0.0	0.0
10488	73	Röd Kaviar	12.0	20	0.2	48.0
10489	11	Queso Cabrales	16.8	15	0.25	63.0
10489	16	Pavlova	13.9	18	0.0	0.0
10490	59	Raclette Courdavault	44.0	60	0.0	0.0
10490	68	Scottish Longbreads	10.0	30	0.0	0.0
10490	75	Rhönbräu Klosterbier	6.2	36	0.0	0.0
10491	44	Gula Malacca	15.5	15	0.15	34.87
10491	77	Original Frankfurter grüne Soße	10.4	7	0.15	10.92
10492	25	NuNuCa Nuß-Nougat-Creme	11.2	60	0.05	33.6
10492	42	Singaporean Hokkien Fried Mee	11.2	20	0.05	11.2
10493	65	Louisiana Fiery Hot Pepper Sauce	16.8	15	0.1	25.2
10493	66	Louisiana Hot Spiced Okra	13.6	10	0.1	13.6
10493	69	Gudbrandsdalsost	28.8	10	0.1	28.8
10494	56	Gnocchi di nonna Alice	30.4	30	0.0	0.0
10495	23	Tunnbröd	7.2	10	0.0	0.0
10495	41	Jack's New England Clam Chowder	7.7	20	0.0	0.0
10495	77	Original Frankfurter grüne Soße	10.4	5	0.0	0.0
10496	31	Gorgonzola Telino	10.0	20	0.05	10.0
10497	56	Gnocchi di nonna Alice	30.4	14	0.0	0.0
10497	72	Mozzarella di Giovanni	27.8	25	0.0	0.0
10497	77	Original Frankfurter grüne Soße	10.4	25	0.0	0.0
10498	24	Guaraná Fantástica	4.5	14	0.0	0.0
10498	40	Boston Crab Meat	18.4	5	0.0	0.0
10498	42	Singaporean Hokkien Fried Mee	14.0	30	0.0	0.0
10499	28	Rössle Sauerkraut	45.6	20	0.0	0.0
10499	49	Maxilaku	20.0	25	0.0	0.0
10500	15	Genen Shouyu	15.5	12	0.05	9.3
10500	28	Rössle Sauerkraut	45.6	8	0.05	18.24
10501	54	Tourtière	7.45	20	0.0	0.0
10502	45	Røgede sild	9.5	21	0.0	0.0
10502	53	Perth Pasties	32.8	6	0.0	0.0
10502	67	Laughing Lumberjack Lager	14.0	30	0.0	0.0
10503	14	Tofu	23.25	70	0.0	0.0
10503	65	Louisiana Fiery Hot Pepper Sauce	21.05	20	0.0	0.0
10504	2	Chang	19.0	12	0.0	0.0
10504	21	Sir Rodney's Scones	10.0	12	0.0	0.0
10504	53	Perth Pasties	32.8	10	0.0	0.0
10504	61	Sirop d'érable	28.5	25	0.0	0.0
10505	62	Tarte au sucre	49.3	3	0.0	0.0
10506	25	NuNuCa Nuß-Nougat-Creme	14.0	18	0.1	25.2
10506	70	Outback Lager	15.0	14	0.1	21.0
10507	43	Ipoh Coffee	46.0	15	0.15	103.5
10507	48	Chocolade	12.75	15	0.15	28.68
10508	13	Konbu	6.0	10	0.0	0.0
10508	39	Chartreuse verte	18.0	10	0.0	0.0
10509	28	Rössle Sauerkraut	45.6	3	0.0	0.0
10510	29	Thüringer Rostbratwurst	123.79	36	0.0	0.0
10510	75	Rhönbräu Klosterbier	7.75	36	0.1	27.9
10511	4	Chef Anton's Cajun Seasoning	22.0	50	0.15	165.0
10511	7	Uncle Bob's Organic Dried Pears	30.0	50	0.15	225.0
10511	8	Northwoods Cranberry Sauce	40.0	10	0.15	60.0
10512	24	Guaraná Fantástica	4.5	10	0.15	6.75
10512	46	Spegesild	12.0	9	0.15	16.2
10512	47	Zaanse koeken	9.5	6	0.15	8.55
10512	60	Camembert Pierrot	34.0	12	0.15	61.2
10513	21	Sir Rodney's Scones	10.0	40	0.2	80.0
10513	32	Mascarpone Fabioli	32.0	50	0.2	320.0
10513	61	Sirop d'érable	28.5	15	0.2	85.5
10514	20	Sir Rodney's Marmalade	81.0	39	0.0	0.0
10514	28	Rössle Sauerkraut	45.6	35	0.0	0.0
10514	56	Gnocchi di nonna Alice	38.0	70	0.0	0.0
10514	65	Louisiana Fiery Hot Pepper Sauce	21.05	39	0.0	0.0
10514	75	Rhönbräu Klosterbier	7.75	50	0.0	0.0
10515	9	Mishi Kobe Niku	97.0	16	0.15	232.8
10515	16	Pavlova	17.45	50	0.0	0.0
10515	27	Schoggi Schokolade	43.9	120	0.0	0.0
10515	33	Geitost	2.5	16	0.15	6.0
10515	60	Camembert Pierrot	34.0	84	0.15	428.4
10516	18	Carnarvon Tigers	62.5	25	0.1	156.25
10516	41	Jack's New England Clam Chowder	9.65	80	0.1	77.2
10516	42	Singaporean Hokkien Fried Mee	14.0	20	0.0	0.0
10517	52	Filo Mix	7.0	6	0.0	0.0
10517	59	Raclette Courdavault	55.0	4	0.0	0.0
10517	70	Outback Lager	15.0	6	0.0	0.0
10518	24	Guaraná Fantástica	4.5	5	0.0	0.0
10518	38	Côte de Blaye	263.5	15	0.0	0.0
10518	44	Gula Malacca	19.45	9	0.0	0.0
10519	10	Ikura	31.0	16	0.05	24.8
10519	56	Gnocchi di nonna Alice	38.0	40	0.0	0.0
10519	60	Camembert Pierrot	34.0	10	0.05	17.0
10520	24	Guaraná Fantástica	4.5	8	0.0	0.0
10520	53	Perth Pasties	32.8	5	0.0	0.0
10521	35	Steeleye Stout	18.0	3	0.0	0.0
10521	41	Jack's New England Clam Chowder	9.65	10	0.0	0.0
10521	68	Scottish Longbreads	12.5	6	0.0	0.0
10522	1	Chai	18.0	40	0.2	144.0
10522	8	Northwoods Cranberry Sauce	40.0	24	0.0	0.0
10522	30	Nord-Ost Matjeshering	25.89	20	0.2	103.56
10522	40	Boston Crab Meat	18.4	25	0.2	92.0
10523	17	Alice Mutton	39.0	25	0.1	97.5
10523	20	Sir Rodney's Marmalade	81.0	15	0.1	121.5
10523	37	Gravad lax	26.0	18	0.1	46.8
10523	41	Jack's New England Clam Chowder	9.65	6	0.1	5.79
10524	10	Ikura	31.0	2	0.0	0.0
10524	30	Nord-Ost Matjeshering	25.89	10	0.0	0.0
10524	43	Ipoh Coffee	46.0	60	0.0	0.0
10524	54	Tourtière	7.45	15	0.0	0.0
10525	36	Inlagd Sill	19.0	30	0.0	0.0
10525	40	Boston Crab Meat	18.4	15	0.1	27.6
10526	1	Chai	18.0	8	0.15	21.6
10526	13	Konbu	6.0	10	0.0	0.0
10526	56	Gnocchi di nonna Alice	38.0	30	0.15	171.0
10527	4	Chef Anton's Cajun Seasoning	22.0	50	0.1	110.0
10527	36	Inlagd Sill	19.0	30	0.1	57.0
10528	11	Queso Cabrales	21.0	3	0.0	0.0
10528	33	Geitost	2.5	8	0.2	4.0
10528	72	Mozzarella di Giovanni	34.8	9	0.0	0.0
10529	55	Pâté chinois	24.0	14	0.0	0.0
10529	68	Scottish Longbreads	12.5	20	0.0	0.0
10529	69	Gudbrandsdalsost	36.0	10	0.0	0.0
10530	17	Alice Mutton	39.0	40	0.0	0.0
10530	43	Ipoh Coffee	46.0	25	0.0	0.0
10530	61	Sirop d'érable	28.5	20	0.0	0.0
10530	76	Lakkalikööri	18.0	50	0.0	0.0
10531	59	Raclette Courdavault	55.0	2	0.0	0.0
10532	30	Nord-Ost Matjeshering	25.89	15	0.0	0.0
10532	66	Louisiana Hot Spiced Okra	17.0	24	0.0	0.0
10533	4	Chef Anton's Cajun Seasoning	22.0	50	0.05	55.0
10533	72	Mozzarella di Giovanni	34.8	24	0.0	0.0
10533	73	Röd Kaviar	15.0	24	0.05	18.0
10534	30	Nord-Ost Matjeshering	25.89	10	0.0	0.0
10534	40	Boston Crab Meat	18.4	10	0.2	36.8
10534	54	Tourtière	7.45	10	0.2	14.9
10535	11	Queso Cabrales	21.0	50	0.1	105.0
10535	40	Boston Crab Meat	18.4	10	0.1	18.4
10535	57	Ravioli Angelo	19.5	5	0.1	9.75
10535	59	Raclette Courdavault	55.0	15	0.1	82.5
10536	12	Queso Manchego La Pastora	38.0	15	0.25	142.5
10536	31	Gorgonzola Telino	12.5	20	0.0	0.0
10536	33	Geitost	2.5	30	0.0	0.0
10536	60	Camembert Pierrot	34.0	35	0.25	297.5
10537	31	Gorgonzola Telino	12.5	30	0.0	0.0
10537	51	Manjimup Dried Apples	53.0	6	0.0	0.0
10537	58	Escargots de Bourgogne	13.25	20	0.0	0.0
10537	72	Mozzarella di Giovanni	34.8	21	0.0	0.0
10537	73	Röd Kaviar	15.0	9	0.0	0.0
10538	70	Outback Lager	15.0	7	0.0	0.0
10538	72	Mozzarella di Giovanni	34.8	1	0.0	0.0
10539	13	Konbu	6.0	8	0.0	0.0
10539	21	Sir Rodney's Scones	10.0	15	0.0	0.0
10539	33	Geitost	2.5	15	0.0	0.0
10539	49	Maxilaku	20.0	6	0.0	0.0
10540	3	Aniseed Syrup	10.0	60	0.0	0.0
10540	26	Gumbär Gummibärchen	31.23	40	0.0	0.0
10540	38	Côte de Blaye	263.5	30	0.0	0.0
10540	68	Scottish Longbreads	12.5	35	0.0	0.0
10541	24	Guaraná Fantástica	4.5	35	0.1	15.75
10541	38	Côte de Blaye	263.5	4	0.1	105.4
10541	65	Louisiana Fiery Hot Pepper Sauce	21.05	36	0.1	75.78
10541	71	Fløtemysost	21.5	9	0.1	19.35
10542	11	Queso Cabrales	21.0	15	0.05	15.75
10542	54	Tourtière	7.45	24	0.05	8.94
10543	12	Queso Manchego La Pastora	38.0	30	0.15	171.0
10543	23	Tunnbröd	9.0	70	0.15	94.5
10544	28	Rössle Sauerkraut	45.6	7	0.0	0.0
10544	67	Laughing Lumberjack Lager	14.0	7	0.0	0.0
10545	11	Queso Cabrales	21.0	10	0.0	0.0
10546	7	Uncle Bob's Organic Dried Pears	30.0	10	0.0	0.0
10546	35	Steeleye Stout	18.0	30	0.0	0.0
10546	62	Tarte au sucre	49.3	40	0.0	0.0
10547	32	Mascarpone Fabioli	32.0	24	0.15	115.2
10547	36	Inlagd Sill	19.0	60	0.0	0.0
10548	34	Sasquatch Ale	14.0	10	0.25	35.0
10548	41	Jack's New England Clam Chowder	9.65	14	0.0	0.0
10549	31	Gorgonzola Telino	12.5	55	0.15	103.12
10549	45	Røgede sild	9.5	100	0.15	142.5
10549	51	Manjimup Dried Apples	53.0	48	0.15	381.6
10550	17	Alice Mutton	39.0	8	0.1	31.2
10550	19	Teatime Chocolate Biscuits	9.2	10	0.0	0.0
10550	21	Sir Rodney's Scones	10.0	6	0.1	6.0
10550	61	Sirop d'érable	28.5	10	0.1	28.5
10551	16	Pavlova	17.45	40	0.15	104.7
10551	35	Steeleye Stout	18.0	20	0.15	54.0
10551	44	Gula Malacca	19.45	40	0.0	0.0
10552	69	Gudbrandsdalsost	36.0	18	0.0	0.0
10552	75	Rhönbräu Klosterbier	7.75	30	0.0	0.0
10553	11	Queso Cabrales	21.0	15	0.0	0.0
10553	16	Pavlova	17.45	14	0.0	0.0
10553	22	Gustaf's Knäckebröd	21.0	24	0.0	0.0
10553	31	Gorgonzola Telino	12.5	30	0.0	0.0
10553	35	Steeleye Stout	18.0	6	0.0	0.0
10554	16	Pavlova	17.45	30	0.05	26.17
10554	23	Tunnbröd	9.0	20	0.05	9.0
10554	62	Tarte au sucre	49.3	20	0.05	49.3
10554	77	Original Frankfurter grüne Soße	13.0	10	0.05	6.5
10555	14	Tofu	23.25	30	0.2	139.5
10555	19	Teatime Chocolate Biscuits	9.2	35	0.2	64.4
10555	24	Guaraná Fantástica	4.5	18	0.2	16.2
10555	51	Manjimup Dried Apples	53.0	20	0.2	212.0
10555	56	Gnocchi di nonna Alice	38.0	40	0.2	304.0
10556	72	Mozzarella di Giovanni	34.8	24	0.0	0.0
10557	64	Wimmers gute Semmelknödel	33.25	30	0.0	0.0
10557	75	Rhönbräu Klosterbier	7.75	20	0.0	0.0
10558	47	Zaanse koeken	9.5	25	0.0	0.0
10558	51	Manjimup Dried Apples	53.0	20	0.0	0.0
10558	52	Filo Mix	7.0	30	0.0	0.0
10558	53	Perth Pasties	32.8	18	0.0	0.0
10558	73	Röd Kaviar	15.0	3	0.0	0.0
10559	41	Jack's New England Clam Chowder	9.65	12	0.05	5.79
10559	55	Pâté chinois	24.0	18	0.05	21.6
10560	30	Nord-Ost Matjeshering	25.89	20	0.0	0.0
10560	62	Tarte au sucre	49.3	15	0.25	184.87
10561	44	Gula Malacca	19.45	10	0.0	0.0
10561	51	Manjimup Dried Apples	53.0	50	0.0	0.0
10562	33	Geitost	2.5	20	0.1	5.0
10562	62	Tarte au sucre	49.3	10	0.1	49.3
10563	36	Inlagd Sill	19.0	25	0.0	0.0
10563	52	Filo Mix	7.0	70	0.0	0.0
10564	17	Alice Mutton	39.0	16	0.05	31.2
10564	31	Gorgonzola Telino	12.5	6	0.05	3.75
10564	55	Pâté chinois	24.0	25	0.05	30.0
10565	24	Guaraná Fantástica	4.5	25	0.1	11.25
10565	64	Wimmers gute Semmelknödel	33.25	18	0.1	59.85
10566	11	Queso Cabrales	21.0	35	0.15	110.25
10566	18	Carnarvon Tigers	62.5	18	0.15	168.75
10566	76	Lakkalikööri	18.0	10	0.0	0.0
10567	31	Gorgonzola Telino	12.5	60	0.2	150.0
10567	51	Manjimup Dried Apples	53.0	3	0.0	0.0
10567	59	Raclette Courdavault	55.0	40	0.2	440.0
10568	10	Ikura	31.0	5	0.0	0.0
10569	31	Gorgonzola Telino	12.5	35	0.2	87.5
10569	76	Lakkalikööri	18.0	30	0.0	0.0
10570	11	Queso Cabrales	21.0	15	0.05	15.75
10570	56	Gnocchi di nonna Alice	38.0	60	0.05	114.0
10571	14	Tofu	23.25	11	0.15	38.36
10571	42	Singaporean Hokkien Fried Mee	14.0	28	0.15	58.8
10572	16	Pavlova	17.45	12	0.1	20.94
10572	32	Mascarpone Fabioli	32.0	10	0.1	32.0
10572	40	Boston Crab Meat	18.4	50	0.0	0.0
10572	75	Rhönbräu Klosterbier	7.75	15	0.1	11.62
10573	17	Alice Mutton	39.0	18	0.0	0.0
10573	34	Sasquatch Ale	14.0	40	0.0	0.0
10573	53	Perth Pasties	32.8	25	0.0	0.0
10574	33	Geitost	2.5	14	0.0	0.0
10574	40	Boston Crab Meat	18.4	2	0.0	0.0
10574	62	Tarte au sucre	49.3	10	0.0	0.0
10574	64	Wimmers gute Semmelknödel	33.25	6	0.0	0.0
10575	59	Raclette Courdavault	55.0	12	0.0	0.0
10575	63	Vegie-spread	43.9	6	0.0	0.0
10575	72	Mozzarella di Giovanni	34.8	30	0.0	0.0
10575	76	Lakkalikööri	18.0	10	0.0	0.0
10576	1	Chai	18.0	10	0.0	0.0
10576	31	Gorgonzola Telino	12.5	20	0.0	0.0
10576	44	Gula Malacca	19.45	21	0.0	0.0
10577	39	Chartreuse verte	18.0	10	0.0	0.0
10577	75	Rhönbräu Klosterbier	7.75	20	0.0	0.0
10577	77	Original Frankfurter grüne Soße	13.0	18	0.0	0.0
10578	35	Steeleye Stout	18.0	20	0.0	0.0
10578	57	Ravioli Angelo	19.5	6	0.0	0.0
10579	15	Genen Shouyu	15.5	10	0.0	0.0
10579	75	Rhönbräu Klosterbier	7.75	21	0.0	0.0
10580	14	Tofu	23.25	15	0.05	17.43
10580	41	Jack's New England Clam Chowder	9.65	9	0.05	4.34
10580	65	Louisiana Fiery Hot Pepper Sauce	21.05	30	0.05	31.57
10581	75	Rhönbräu Klosterbier	7.75	50	0.2	77.5
10582	57	Ravioli Angelo	19.5	4	0.0	0.0
10582	76	Lakkalikööri	18.0	14	0.0	0.0
10583	29	Thüringer Rostbratwurst	123.79	10	0.0	0.0
10583	60	Camembert Pierrot	34.0	24	0.15	122.4
10583	69	Gudbrandsdalsost	36.0	10	0.15	54.0
10584	31	Gorgonzola Telino	12.5	50	0.05	31.25
10585	47	Zaanse koeken	9.5	15	0.0	0.0
10586	52	Filo Mix	7.0	4	0.15	4.2
10587	26	Gumbär Gummibärchen	31.23	6	0.0	0.0
10587	35	Steeleye Stout	18.0	20	0.0	0.0
10587	77	Original Frankfurter grüne Soße	13.0	20	0.0	0.0
10588	18	Carnarvon Tigers	62.5	40	0.2	500.0
10588	42	Singaporean Hokkien Fried Mee	14.0	100	0.2	280.0
10589	35	Steeleye Stout	18.0	4	0.0	0.0
10590	1	Chai	18.0	20	0.0	0.0
10590	77	Original Frankfurter grüne Soße	13.0	60	0.05	39.0
10591	3	Aniseed Syrup	10.0	14	0.0	0.0
10591	7	Uncle Bob's Organic Dried Pears	30.0	10	0.0	0.0
10591	54	Tourtière	7.45	50	0.0	0.0
10592	15	Genen Shouyu	15.5	25	0.05	19.37
10592	26	Gumbär Gummibärchen	31.23	5	0.05	7.8
10593	20	Sir Rodney's Marmalade	81.0	21	0.2	340.2
10593	69	Gudbrandsdalsost	36.0	20	0.2	144.0
10593	76	Lakkalikööri	18.0	4	0.2	14.4
10594	52	Filo Mix	7.0	24	0.0	0.0
10594	58	Escargots de Bourgogne	13.25	30	0.0	0.0
10595	35	Steeleye Stout	18.0	30	0.25	135.0
10595	61	Sirop d'érable	28.5	120	0.25	855.0
10595	69	Gudbrandsdalsost	36.0	65	0.25	585.0
10596	56	Gnocchi di nonna Alice	38.0	5	0.2	38.0
10596	63	Vegie-spread	43.9	24	0.2	210.72
10596	75	Rhönbräu Klosterbier	7.75	30	0.2	46.5
10597	24	Guaraná Fantástica	4.5	35	0.2	31.5
10597	57	Ravioli Angelo	19.5	20	0.0	0.0
10597	65	Louisiana Fiery Hot Pepper Sauce	21.05	12	0.2	50.52
10598	27	Schoggi Schokolade	43.9	50	0.0	0.0
10598	71	Fløtemysost	21.5	9	0.0	0.0
10599	62	Tarte au sucre	49.3	10	0.0	0.0
10600	54	Tourtière	7.45	4	0.0	0.0
10600	73	Röd Kaviar	15.0	30	0.0	0.0
10601	13	Konbu	6.0	60	0.0	0.0
10601	59	Raclette Courdavault	55.0	35	0.0	0.0
10602	77	Original Frankfurter grüne Soße	13.0	5	0.25	16.25
10603	22	Gustaf's Knäckebröd	21.0	48	0.0	0.0
10603	49	Maxilaku	20.0	25	0.05	25.0
10604	48	Chocolade	12.75	6	0.1	7.65
10604	76	Lakkalikööri	18.0	10	0.1	18.0
10605	16	Pavlova	17.45	30	0.05	26.17
10605	59	Raclette Courdavault	55.0	20	0.05	55.0
10605	60	Camembert Pierrot	34.0	70	0.05	119.0
10605	71	Fløtemysost	21.5	15	0.05	16.12
10606	4	Chef Anton's Cajun Seasoning	22.0	20	0.2	88.0
10606	55	Pâté chinois	24.0	20	0.2	96.0
10606	62	Tarte au sucre	49.3	10	0.2	98.6
10607	7	Uncle Bob's Organic Dried Pears	30.0	45	0.0	0.0
10607	17	Alice Mutton	39.0	100	0.0	0.0
10607	33	Geitost	2.5	14	0.0	0.0
10607	40	Boston Crab Meat	18.4	42	0.0	0.0
10607	72	Mozzarella di Giovanni	34.8	12	0.0	0.0
10608	56	Gnocchi di nonna Alice	38.0	28	0.0	0.0
10609	1	Chai	18.0	3	0.0	0.0
10609	10	Ikura	31.0	10	0.0	0.0
10609	21	Sir Rodney's Scones	10.0	6	0.0	0.0
10610	36	Inlagd Sill	19.0	21	0.25	99.75
10611	1	Chai	18.0	6	0.0	0.0
10611	2	Chang	19.0	10	0.0	0.0
10611	60	Camembert Pierrot	34.0	15	0.0	0.0
10612	10	Ikura	31.0	70	0.0	0.0
10612	36	Inlagd Sill	19.0	55	0.0	0.0
10612	49	Maxilaku	20.0	18	0.0	0.0
10612	60	Camembert Pierrot	34.0	40	0.0	0.0
10612	76	Lakkalikööri	18.0	80	0.0	0.0
10613	13	Konbu	6.0	8	0.1	4.8
10613	75	Rhönbräu Klosterbier	7.75	40	0.0	0.0
10614	11	Queso Cabrales	21.0	14	0.0	0.0
10614	21	Sir Rodney's Scones	10.0	8	0.0	0.0
10614	39	Chartreuse verte	18.0	5	0.0	0.0
10615	55	Pâté chinois	24.0	5	0.0	0.0
10616	38	Côte de Blaye	263.5	15	0.05	197.62
10616	56	Gnocchi di nonna Alice	38.0	14	0.0	0.0
10616	70	Outback Lager	15.0	15	0.05	11.25
10616	71	Fløtemysost	21.5	15	0.05	16.12
10617	59	Raclette Courdavault	55.0	30	0.15	247.5
10618	6	Grandma's Boysenberry Spread	25.0	70	0.0	0.0
10618	56	Gnocchi di nonna Alice	38.0	20	0.0	0.0
10618	68	Scottish Longbreads	12.5	15	0.0	0.0
10619	21	Sir Rodney's Scones	10.0	42	0.0	0.0
10619	22	Gustaf's Knäckebröd	21.0	40	0.0	0.0
10620	24	Guaraná Fantástica	4.5	5	0.0	0.0
10620	52	Filo Mix	7.0	5	0.0	0.0
10621	19	Teatime Chocolate Biscuits	9.2	5	0.0	0.0
10621	23	Tunnbröd	9.0	10	0.0	0.0
10621	70	Outback Lager	15.0	20	0.0	0.0
10621	71	Fløtemysost	21.5	15	0.0	0.0
10622	2	Chang	19.0	20	0.0	0.0
10622	68	Scottish Longbreads	12.5	18	0.2	45.0
10623	14	Tofu	23.25	21	0.0	0.0
10623	19	Teatime Chocolate Biscuits	9.2	15	0.1	13.8
10623	21	Sir Rodney's Scones	10.0	25	0.1	25.0
10623	24	Guaraná Fantástica	4.5	3	0.0	0.0
10623	35	Steeleye Stout	18.0	30	0.1	54.0
10624	28	Rössle Sauerkraut	45.6	10	0.0	0.0
10624	29	Thüringer Rostbratwurst	123.79	6	0.0	0.0
10624	44	Gula Malacca	19.45	10	0.0	0.0
10625	14	Tofu	23.25	3	0.0	0.0
10625	42	Singaporean Hokkien Fried Mee	14.0	5	0.0	0.0
10625	60	Camembert Pierrot	34.0	10	0.0	0.0
10626	53	Perth Pasties	32.8	12	0.0	0.0
10626	60	Camembert Pierrot	34.0	20	0.0	0.0
10626	71	Fløtemysost	21.5	20	0.0	0.0
10627	62	Tarte au sucre	49.3	15	0.0	0.0
10627	73	Röd Kaviar	15.0	35	0.15	78.75
10628	1	Chai	18.0	25	0.0	0.0
10629	29	Thüringer Rostbratwurst	123.79	20	0.0	0.0
10629	64	Wimmers gute Semmelknödel	33.25	9	0.0	0.0
10630	55	Pâté chinois	24.0	12	0.05	14.4
10630	76	Lakkalikööri	18.0	35	0.0	0.0
10631	75	Rhönbräu Klosterbier	7.75	8	0.1	6.2
10632	2	Chang	19.0	30	0.05	28.5
10632	33	Geitost	2.5	20	0.05	2.5
10633	12	Queso Manchego La Pastora	38.0	36	0.15	205.2
10633	13	Konbu	6.0	13	0.15	11.7
10633	26	Gumbär Gummibärchen	31.23	35	0.15	163.95
10633	62	Tarte au sucre	49.3	80	0.15	591.6
10634	7	Uncle Bob's Organic Dried Pears	30.0	35	0.0	0.0
10634	18	Carnarvon Tigers	62.5	50	0.0	0.0
10634	51	Manjimup Dried Apples	53.0	15	0.0	0.0
10634	75	Rhönbräu Klosterbier	7.75	2	0.0	0.0
10635	4	Chef Anton's Cajun Seasoning	22.0	10	0.1	22.0
10635	5	Chef Anton's Gumbo Mix	21.35	15	0.1	32.02
10635	22	Gustaf's Knäckebröd	21.0	40	0.0	0.0
10636	4	Chef Anton's Cajun Seasoning	22.0	25	0.0	0.0
10636	58	Escargots de Bourgogne	13.25	6	0.0	0.0
10637	11	Queso Cabrales	21.0	10	0.0	0.0
10637	50	Valkoinen suklaa	16.25	25	0.05	20.31
10637	56	Gnocchi di nonna Alice	38.0	60	0.05	114.0
10638	45	Røgede sild	9.5	20	0.0	0.0
10638	65	Louisiana Fiery Hot Pepper Sauce	21.05	21	0.0	0.0
10638	72	Mozzarella di Giovanni	34.8	60	0.0	0.0
10639	18	Carnarvon Tigers	62.5	8	0.0	0.0
10640	69	Gudbrandsdalsost	36.0	20	0.25	180.0
10640	70	Outback Lager	15.0	15	0.25	56.25
10641	2	Chang	19.0	50	0.0	0.0
10641	40	Boston Crab Meat	18.4	60	0.0	0.0
10642	21	Sir Rodney's Scones	10.0	30	0.2	60.0
10642	61	Sirop d'érable	28.5	20	0.2	114.0
10643	28	Rössle Sauerkraut	45.6	15	0.25	171.0
10643	39	Chartreuse verte	18.0	21	0.25	94.5
10643	46	Spegesild	12.0	2	0.25	6.0
10644	18	Carnarvon Tigers	62.5	4	0.1	25.0
10644	43	Ipoh Coffee	46.0	20	0.0	0.0
10644	46	Spegesild	12.0	21	0.1	25.2
10645	18	Carnarvon Tigers	62.5	20	0.0	0.0
10645	36	Inlagd Sill	19.0	15	0.0	0.0
10646	1	Chai	18.0	15	0.25	67.5
10646	10	Ikura	31.0	18	0.25	139.5
10646	71	Fløtemysost	21.5	30	0.25	161.25
10646	77	Original Frankfurter grüne Soße	13.0	35	0.25	113.75
10647	19	Teatime Chocolate Biscuits	9.2	30	0.0	0.0
10647	39	Chartreuse verte	18.0	20	0.0	0.0
10648	22	Gustaf's Knäckebröd	21.0	15	0.0	0.0
10648	24	Guaraná Fantástica	4.5	15	0.15	10.12
10649	28	Rössle Sauerkraut	45.6	20	0.0	0.0
10649	72	Mozzarella di Giovanni	34.8	15	0.0	0.0
10650	30	Nord-Ost Matjeshering	25.89	30	0.0	0.0
10650	53	Perth Pasties	32.8	25	0.05	41.0
10650	54	Tourtière	7.45	30	0.0	0.0
10651	19	Teatime Chocolate Biscuits	9.2	12	0.25	27.6
10651	22	Gustaf's Knäckebröd	21.0	20	0.25	105.0
10652	30	Nord-Ost Matjeshering	25.89	2	0.25	12.94
10652	42	Singaporean Hokkien Fried Mee	14.0	20	0.0	0.0
10653	16	Pavlova	17.45	30	0.1	52.35
10653	60	Camembert Pierrot	34.0	20	0.1	68.0
10654	4	Chef Anton's Cajun Seasoning	22.0	12	0.1	26.4
10654	39	Chartreuse verte	18.0	20	0.1	36.0
10654	54	Tourtière	7.45	6	0.1	4.47
10655	41	Jack's New England Clam Chowder	9.65	20	0.2	38.6
10656	14	Tofu	23.25	3	0.1	6.97
10656	44	Gula Malacca	19.45	28	0.1	54.46
10656	47	Zaanse koeken	9.5	6	0.1	5.7
10657	15	Genen Shouyu	15.5	50	0.0	0.0
10657	41	Jack's New England Clam Chowder	9.65	24	0.0	0.0
10657	46	Spegesild	12.0	45	0.0	0.0
10657	47	Zaanse koeken	9.5	10	0.0	0.0
10657	56	Gnocchi di nonna Alice	38.0	45	0.0	0.0
10657	60	Camembert Pierrot	34.0	30	0.0	0.0
10658	21	Sir Rodney's Scones	10.0	60	0.0	0.0
10658	40	Boston Crab Meat	18.4	70	0.05	64.4
10658	60	Camembert Pierrot	34.0	55	0.05	93.5
10658	77	Original Frankfurter grüne Soße	13.0	70	0.05	45.5
10659	31	Gorgonzola Telino	12.5	20	0.05	12.5
10659	40	Boston Crab Meat	18.4	24	0.05	22.08
10659	70	Outback Lager	15.0	40	0.05	30.0
10660	20	Sir Rodney's Marmalade	81.0	21	0.0	0.0
10661	39	Chartreuse verte	18.0	3	0.2	10.8
10661	58	Escargots de Bourgogne	13.25	49	0.2	129.85
10662	68	Scottish Longbreads	12.5	10	0.0	0.0
10663	40	Boston Crab Meat	18.4	30	0.05	27.6
10663	42	Singaporean Hokkien Fried Mee	14.0	30	0.05	21.0
10663	51	Manjimup Dried Apples	53.0	20	0.05	53.0
10664	10	Ikura	31.0	24	0.15	111.6
10664	56	Gnocchi di nonna Alice	38.0	12	0.15	68.4
10664	65	Louisiana Fiery Hot Pepper Sauce	21.05	15	0.15	47.36
10665	51	Manjimup Dried Apples	53.0	20	0.0	0.0
10665	59	Raclette Courdavault	55.0	1	0.0	0.0
10665	76	Lakkalikööri	18.0	10	0.0	0.0
10666	29	Thüringer Rostbratwurst	123.79	36	0.0	0.0
10666	65	Louisiana Fiery Hot Pepper Sauce	21.05	10	0.0	0.0
10667	69	Gudbrandsdalsost	36.0	45	0.2	324.0
10667	71	Fløtemysost	21.5	14	0.2	60.2
10668	31	Gorgonzola Telino	12.5	8	0.1	10.0
10668	55	Pâté chinois	24.0	4	0.1	9.6
10668	64	Wimmers gute Semmelknödel	33.25	15	0.1	49.87
10669	36	Inlagd Sill	19.0	30	0.0	0.0
10670	23	Tunnbröd	9.0	32	0.0	0.0
10670	46	Spegesild	12.0	60	0.0	0.0
10670	67	Laughing Lumberjack Lager	14.0	25	0.0	0.0
10670	73	Röd Kaviar	15.0	50	0.0	0.0
10670	75	Rhönbräu Klosterbier	7.75	25	0.0	0.0
10671	16	Pavlova	17.45	10	0.0	0.0
10671	62	Tarte au sucre	49.3	10	0.0	0.0
10671	65	Louisiana Fiery Hot Pepper Sauce	21.05	12	0.0	0.0
10672	38	Côte de Blaye	263.5	15	0.1	395.25
10672	71	Fløtemysost	21.5	12	0.0	0.0
10673	16	Pavlova	17.45	3	0.0	0.0
10673	42	Singaporean Hokkien Fried Mee	14.0	6	0.0	0.0
10673	43	Ipoh Coffee	46.0	6	0.0	0.0
10674	23	Tunnbröd	9.0	5	0.0	0.0
10675	14	Tofu	23.25	30	0.0	0.0
10675	53	Perth Pasties	32.8	10	0.0	0.0
10675	58	Escargots de Bourgogne	13.25	30	0.0	0.0
10676	10	Ikura	31.0	2	0.0	0.0
10676	19	Teatime Chocolate Biscuits	9.2	7	0.0	0.0
10676	44	Gula Malacca	19.45	21	0.0	0.0
10677	26	Gumbär Gummibärchen	31.23	30	0.15	140.53
10677	33	Geitost	2.5	8	0.15	3.0
10678	12	Queso Manchego La Pastora	38.0	100	0.0	0.0
10678	33	Geitost	2.5	30	0.0	0.0
10678	41	Jack's New England Clam Chowder	9.65	120	0.0	0.0
10678	54	Tourtière	7.45	30	0.0	0.0
10679	59	Raclette Courdavault	55.0	12	0.0	0.0
10680	16	Pavlova	17.45	50	0.25	218.12
10680	31	Gorgonzola Telino	12.5	20	0.25	62.5
10680	42	Singaporean Hokkien Fried Mee	14.0	40	0.25	140.0
10681	19	Teatime Chocolate Biscuits	9.2	30	0.1	27.6
10681	21	Sir Rodney's Scones	10.0	12	0.1	12.0
10681	64	Wimmers gute Semmelknödel	33.25	28	0.0	0.0
10682	33	Geitost	2.5	30	0.0	0.0
10682	66	Louisiana Hot Spiced Okra	17.0	4	0.0	0.0
10682	75	Rhönbräu Klosterbier	7.75	30	0.0	0.0
10683	52	Filo Mix	7.0	9	0.0	0.0
10684	40	Boston Crab Meat	18.4	20	0.0	0.0
10684	47	Zaanse koeken	9.5	40	0.0	0.0
10684	60	Camembert Pierrot	34.0	30	0.0	0.0
10685	10	Ikura	31.0	20	0.0	0.0
10685	41	Jack's New England Clam Chowder	9.65	4	0.0	0.0
10685	47	Zaanse koeken	9.5	15	0.0	0.0
10686	17	Alice Mutton	39.0	30	0.2	234.0
10686	26	Gumbär Gummibärchen	31.23	15	0.0	0.0
10687	9	Mishi Kobe Niku	97.0	50	0.25	1212.5
10687	29	Thüringer Rostbratwurst	123.79	10	0.0	0.0
10687	36	Inlagd Sill	19.0	6	0.25	28.5
10688	10	Ikura	31.0	18	0.1	55.8
10688	28	Rössle Sauerkraut	45.6	60	0.1	273.6
10688	34	Sasquatch Ale	14.0	14	0.0	0.0
10689	1	Chai	18.0	35	0.25	157.5
10690	56	Gnocchi di nonna Alice	38.0	20	0.25	190.0
10690	77	Original Frankfurter grüne Soße	13.0	30	0.25	97.5
10691	1	Chai	18.0	30	0.0	0.0
10691	29	Thüringer Rostbratwurst	123.79	40	0.0	0.0
10691	43	Ipoh Coffee	46.0	40	0.0	0.0
10691	44	Gula Malacca	19.45	24	0.0	0.0
10691	62	Tarte au sucre	49.3	48	0.0	0.0
10692	63	Vegie-spread	43.9	20	0.0	0.0
10693	9	Mishi Kobe Niku	97.0	6	0.0	0.0
10693	54	Tourtière	7.45	60	0.15	67.05
10693	69	Gudbrandsdalsost	36.0	30	0.15	162.0
10693	73	Röd Kaviar	15.0	15	0.15	33.75
10694	7	Uncle Bob's Organic Dried Pears	30.0	90	0.0	0.0
10694	59	Raclette Courdavault	55.0	25	0.0	0.0
10694	70	Outback Lager	15.0	50	0.0	0.0
10695	8	Northwoods Cranberry Sauce	40.0	10	0.0	0.0
10695	12	Queso Manchego La Pastora	38.0	4	0.0	0.0
10695	24	Guaraná Fantástica	4.5	20	0.0	0.0
10696	17	Alice Mutton	39.0	20	0.0	0.0
10696	46	Spegesild	12.0	18	0.0	0.0
10697	19	Teatime Chocolate Biscuits	9.2	7	0.25	16.1
10697	35	Steeleye Stout	18.0	9	0.25	40.5
10697	58	Escargots de Bourgogne	13.25	30	0.25	99.37
10697	70	Outback Lager	15.0	30	0.25	112.5
10698	11	Queso Cabrales	21.0	15	0.0	0.0
10698	17	Alice Mutton	39.0	8	0.05	15.6
10698	29	Thüringer Rostbratwurst	123.79	12	0.05	74.27
10698	65	Louisiana Fiery Hot Pepper Sauce	21.05	65	0.05	68.41
10698	70	Outback Lager	15.0	8	0.05	6.0
10699	47	Zaanse koeken	9.5	12	0.0	0.0
10700	1	Chai	18.0	5	0.2	18.0
10700	34	Sasquatch Ale	14.0	12	0.2	33.6
10700	68	Scottish Longbreads	12.5	40	0.2	100.0
10700	71	Fløtemysost	21.5	60	0.2	258.0
10701	59	Raclette Courdavault	55.0	42	0.15	346.5
10701	71	Fløtemysost	21.5	20	0.15	64.5
10701	76	Lakkalikööri	18.0	35	0.15	94.5
10702	3	Aniseed Syrup	10.0	6	0.0	0.0
10702	76	Lakkalikööri	18.0	15	0.0	0.0
10703	2	Chang	19.0	5	0.0	0.0
10703	59	Raclette Courdavault	55.0	35	0.0	0.0
10703	73	Röd Kaviar	15.0	35	0.0	0.0
10704	4	Chef Anton's Cajun Seasoning	22.0	6	0.0	0.0
10704	24	Guaraná Fantástica	4.5	35	0.0	0.0
10704	48	Chocolade	12.75	24	0.0	0.0
10705	31	Gorgonzola Telino	12.5	20	0.0	0.0
10705	32	Mascarpone Fabioli	32.0	4	0.0	0.0
10706	16	Pavlova	17.45	20	0.0	0.0
10706	43	Ipoh Coffee	46.0	24	0.0	0.0
10706	59	Raclette Courdavault	55.0	8	0.0	0.0
10707	55	Pâté chinois	24.0	21	0.0	0.0
10707	57	Ravioli Angelo	19.5	40	0.0	0.0
10707	70	Outback Lager	15.0	28	0.15	63.0
10708	5	Chef Anton's Gumbo Mix	21.35	4	0.0	0.0
10708	36	Inlagd Sill	19.0	5	0.0	0.0
10709	8	Northwoods Cranberry Sauce	40.0	40	0.0	0.0
10709	51	Manjimup Dried Apples	53.0	28	0.0	0.0
10709	60	Camembert Pierrot	34.0	10	0.0	0.0
10710	19	Teatime Chocolate Biscuits	9.2	5	0.0	0.0
10710	47	Zaanse koeken	9.5	5	0.0	0.0
10711	19	Teatime Chocolate Biscuits	9.2	12	0.0	0.0
10711	41	Jack's New England Clam Chowder	9.65	42	0.0	0.0
10711	53	Perth Pasties	32.8	120	0.0	0.0
10712	53	Perth Pasties	32.8	3	0.05	4.92
10712	56	Gnocchi di nonna Alice	38.0	30	0.0	0.0
10713	10	Ikura	31.0	18	0.0	0.0
10713	26	Gumbär Gummibärchen	31.23	30	0.0	0.0
10713	45	Røgede sild	9.5	110	0.0	0.0
10713	46	Spegesild	12.0	24	0.0	0.0
10714	2	Chang	19.0	30	0.25	142.5
10714	17	Alice Mutton	39.0	27	0.25	263.25
10714	47	Zaanse koeken	9.5	50	0.25	118.75
10714	56	Gnocchi di nonna Alice	38.0	18	0.25	171.0
10714	58	Escargots de Bourgogne	13.25	12	0.25	39.75
10715	10	Ikura	31.0	21	0.0	0.0
10715	71	Fløtemysost	21.5	30	0.0	0.0
10716	21	Sir Rodney's Scones	10.0	5	0.0	0.0
10716	51	Manjimup Dried Apples	53.0	7	0.0	0.0
10716	61	Sirop d'érable	28.5	10	0.0	0.0
10717	21	Sir Rodney's Scones	10.0	32	0.05	16.0
10717	54	Tourtière	7.45	15	0.0	0.0
10717	69	Gudbrandsdalsost	36.0	25	0.05	45.0
10718	12	Queso Manchego La Pastora	38.0	36	0.0	0.0
10718	16	Pavlova	17.45	20	0.0	0.0
10718	36	Inlagd Sill	19.0	40	0.0	0.0
10718	62	Tarte au sucre	49.3	20	0.0	0.0
10719	18	Carnarvon Tigers	62.5	12	0.25	187.5
10719	30	Nord-Ost Matjeshering	25.89	3	0.25	19.41
10719	54	Tourtière	7.45	40	0.25	74.5
10720	35	Steeleye Stout	18.0	21	0.0	0.0
10720	71	Fløtemysost	21.5	8	0.0	0.0
10721	44	Gula Malacca	19.45	50	0.05	48.62
10722	2	Chang	19.0	3	0.0	0.0
10722	31	Gorgonzola Telino	12.5	50	0.0	0.0
10722	68	Scottish Longbreads	12.5	45	0.0	0.0
10722	75	Rhönbräu Klosterbier	7.75	42	0.0	0.0
10723	26	Gumbär Gummibärchen	31.23	15	0.0	0.0
10724	10	Ikura	31.0	16	0.0	0.0
10724	61	Sirop d'érable	28.5	5	0.0	0.0
10725	41	Jack's New England Clam Chowder	9.65	12	0.0	0.0
10725	52	Filo Mix	7.0	4	0.0	0.0
10725	55	Pâté chinois	24.0	6	0.0	0.0
10726	4	Chef Anton's Cajun Seasoning	22.0	25	0.0	0.0
10726	11	Queso Cabrales	21.0	5	0.0	0.0
10727	17	Alice Mutton	39.0	20	0.05	39.0
10727	56	Gnocchi di nonna Alice	38.0	10	0.05	19.0
10727	59	Raclette Courdavault	55.0	10	0.05	27.5
10728	30	Nord-Ost Matjeshering	25.89	15	0.0	0.0
10769	52	Filo Mix	7.0	15	0.05	5.25
10728	40	Boston Crab Meat	18.4	6	0.0	0.0
10728	55	Pâté chinois	24.0	12	0.0	0.0
10728	60	Camembert Pierrot	34.0	15	0.0	0.0
10729	1	Chai	18.0	50	0.0	0.0
10729	21	Sir Rodney's Scones	10.0	30	0.0	0.0
10729	50	Valkoinen suklaa	16.25	40	0.0	0.0
10730	16	Pavlova	17.45	15	0.05	13.08
10730	31	Gorgonzola Telino	12.5	3	0.05	1.87
10730	65	Louisiana Fiery Hot Pepper Sauce	21.05	10	0.05	10.52
10731	21	Sir Rodney's Scones	10.0	40	0.05	20.0
10731	51	Manjimup Dried Apples	53.0	30	0.05	79.5
10732	76	Lakkalikööri	18.0	20	0.0	0.0
10733	14	Tofu	23.25	16	0.0	0.0
10733	28	Rössle Sauerkraut	45.6	20	0.0	0.0
10733	52	Filo Mix	7.0	25	0.0	0.0
10734	6	Grandma's Boysenberry Spread	25.0	30	0.0	0.0
10734	30	Nord-Ost Matjeshering	25.89	15	0.0	0.0
10734	76	Lakkalikööri	18.0	20	0.0	0.0
10735	61	Sirop d'érable	28.5	20	0.1	57.0
10735	77	Original Frankfurter grüne Soße	13.0	2	0.1	2.6
10736	65	Louisiana Fiery Hot Pepper Sauce	21.05	40	0.0	0.0
10736	75	Rhönbräu Klosterbier	7.75	20	0.0	0.0
10737	13	Konbu	6.0	4	0.0	0.0
10737	41	Jack's New England Clam Chowder	9.65	12	0.0	0.0
10738	16	Pavlova	17.45	3	0.0	0.0
10739	36	Inlagd Sill	19.0	6	0.0	0.0
10739	52	Filo Mix	7.0	18	0.0	0.0
10740	28	Rössle Sauerkraut	45.6	5	0.2	45.6
10740	35	Steeleye Stout	18.0	35	0.2	126.0
10740	45	Røgede sild	9.5	40	0.2	76.0
10740	56	Gnocchi di nonna Alice	38.0	14	0.2	106.4
10741	2	Chang	19.0	15	0.2	57.0
10742	3	Aniseed Syrup	10.0	20	0.0	0.0
10742	60	Camembert Pierrot	34.0	50	0.0	0.0
10742	72	Mozzarella di Giovanni	34.8	35	0.0	0.0
10743	46	Spegesild	12.0	28	0.05	16.8
10744	40	Boston Crab Meat	18.4	50	0.2	184.0
10745	18	Carnarvon Tigers	62.5	24	0.0	0.0
10745	44	Gula Malacca	19.45	16	0.0	0.0
10745	59	Raclette Courdavault	55.0	45	0.0	0.0
10745	72	Mozzarella di Giovanni	34.8	7	0.0	0.0
10746	13	Konbu	6.0	6	0.0	0.0
10746	42	Singaporean Hokkien Fried Mee	14.0	28	0.0	0.0
10746	62	Tarte au sucre	49.3	9	0.0	0.0
10746	69	Gudbrandsdalsost	36.0	40	0.0	0.0
10747	31	Gorgonzola Telino	12.5	8	0.0	0.0
10747	41	Jack's New England Clam Chowder	9.65	35	0.0	0.0
10747	63	Vegie-spread	43.9	9	0.0	0.0
10747	69	Gudbrandsdalsost	36.0	30	0.0	0.0
10748	23	Tunnbröd	9.0	44	0.0	0.0
10748	40	Boston Crab Meat	18.4	40	0.0	0.0
10748	56	Gnocchi di nonna Alice	38.0	28	0.0	0.0
10749	56	Gnocchi di nonna Alice	38.0	15	0.0	0.0
10749	59	Raclette Courdavault	55.0	6	0.0	0.0
10749	76	Lakkalikööri	18.0	10	0.0	0.0
10750	14	Tofu	23.25	5	0.15	17.43
10750	45	Røgede sild	9.5	40	0.15	57.0
10750	59	Raclette Courdavault	55.0	25	0.15	206.25
10751	26	Gumbär Gummibärchen	31.23	12	0.1	37.47
10751	30	Nord-Ost Matjeshering	25.89	30	0.0	0.0
10751	50	Valkoinen suklaa	16.25	20	0.1	32.5
10751	73	Röd Kaviar	15.0	15	0.0	0.0
10752	1	Chai	18.0	8	0.0	0.0
10752	69	Gudbrandsdalsost	36.0	3	0.0	0.0
10753	45	Røgede sild	9.5	4	0.0	0.0
10753	74	Longlife Tofu	10.0	5	0.0	0.0
10754	40	Boston Crab Meat	18.4	3	0.0	0.0
10755	47	Zaanse koeken	9.5	30	0.25	71.25
10755	56	Gnocchi di nonna Alice	38.0	30	0.25	285.0
10755	57	Ravioli Angelo	19.5	14	0.25	68.25
10755	69	Gudbrandsdalsost	36.0	25	0.25	225.0
10756	18	Carnarvon Tigers	62.5	21	0.2	262.5
10756	36	Inlagd Sill	19.0	20	0.2	76.0
10756	68	Scottish Longbreads	12.5	6	0.2	15.0
10756	69	Gudbrandsdalsost	36.0	20	0.2	144.0
10757	34	Sasquatch Ale	14.0	30	0.0	0.0
10757	59	Raclette Courdavault	55.0	7	0.0	0.0
10757	62	Tarte au sucre	49.3	30	0.0	0.0
10757	64	Wimmers gute Semmelknödel	33.25	24	0.0	0.0
10758	26	Gumbär Gummibärchen	31.23	20	0.0	0.0
10758	52	Filo Mix	7.0	60	0.0	0.0
10758	70	Outback Lager	15.0	40	0.0	0.0
10759	32	Mascarpone Fabioli	32.0	10	0.0	0.0
10760	25	NuNuCa Nuß-Nougat-Creme	14.0	12	0.25	42.0
10760	27	Schoggi Schokolade	43.9	40	0.0	0.0
10760	43	Ipoh Coffee	46.0	30	0.25	345.0
10761	25	NuNuCa Nuß-Nougat-Creme	14.0	35	0.25	122.5
10761	75	Rhönbräu Klosterbier	7.75	18	0.0	0.0
10762	39	Chartreuse verte	18.0	16	0.0	0.0
10762	47	Zaanse koeken	9.5	30	0.0	0.0
10762	51	Manjimup Dried Apples	53.0	28	0.0	0.0
10762	56	Gnocchi di nonna Alice	38.0	60	0.0	0.0
10763	21	Sir Rodney's Scones	10.0	40	0.0	0.0
10763	22	Gustaf's Knäckebröd	21.0	6	0.0	0.0
10763	24	Guaraná Fantástica	4.5	20	0.0	0.0
10764	3	Aniseed Syrup	10.0	20	0.1	20.0
10764	39	Chartreuse verte	18.0	130	0.1	234.0
10765	65	Louisiana Fiery Hot Pepper Sauce	21.05	80	0.1	168.4
10766	2	Chang	19.0	40	0.0	0.0
10766	7	Uncle Bob's Organic Dried Pears	30.0	35	0.0	0.0
10766	68	Scottish Longbreads	12.5	40	0.0	0.0
10767	42	Singaporean Hokkien Fried Mee	14.0	2	0.0	0.0
10768	22	Gustaf's Knäckebröd	21.0	4	0.0	0.0
10768	31	Gorgonzola Telino	12.5	50	0.0	0.0
10768	60	Camembert Pierrot	34.0	15	0.0	0.0
10768	71	Fløtemysost	21.5	12	0.0	0.0
10769	41	Jack's New England Clam Chowder	9.65	30	0.05	14.47
10769	61	Sirop d'érable	28.5	20	0.0	0.0
10769	62	Tarte au sucre	49.3	15	0.0	0.0
10770	11	Queso Cabrales	21.0	15	0.25	78.75
10771	71	Fløtemysost	21.5	16	0.0	0.0
10772	29	Thüringer Rostbratwurst	123.79	18	0.0	0.0
10772	59	Raclette Courdavault	55.0	25	0.0	0.0
10773	17	Alice Mutton	39.0	33	0.0	0.0
10773	31	Gorgonzola Telino	12.5	70	0.2	175.0
10773	75	Rhönbräu Klosterbier	7.75	7	0.2	10.85
10774	31	Gorgonzola Telino	12.5	2	0.25	6.25
10774	66	Louisiana Hot Spiced Okra	17.0	50	0.0	0.0
10775	10	Ikura	31.0	6	0.0	0.0
10775	67	Laughing Lumberjack Lager	14.0	3	0.0	0.0
10776	31	Gorgonzola Telino	12.5	16	0.05	10.0
10776	42	Singaporean Hokkien Fried Mee	14.0	12	0.05	8.4
10776	45	Røgede sild	9.5	27	0.05	12.82
10776	51	Manjimup Dried Apples	53.0	120	0.05	318.0
10777	42	Singaporean Hokkien Fried Mee	14.0	20	0.2	56.0
10778	41	Jack's New England Clam Chowder	9.65	10	0.0	0.0
10779	16	Pavlova	17.45	20	0.0	0.0
10779	62	Tarte au sucre	49.3	20	0.0	0.0
10780	70	Outback Lager	15.0	35	0.0	0.0
10780	77	Original Frankfurter grüne Soße	13.0	15	0.0	0.0
10781	54	Tourtière	7.45	3	0.2	4.47
10781	56	Gnocchi di nonna Alice	38.0	20	0.2	152.0
10781	74	Longlife Tofu	10.0	35	0.0	0.0
10782	31	Gorgonzola Telino	12.5	1	0.0	0.0
10783	31	Gorgonzola Telino	12.5	10	0.0	0.0
10783	38	Côte de Blaye	263.5	5	0.0	0.0
10784	36	Inlagd Sill	19.0	30	0.0	0.0
10784	39	Chartreuse verte	18.0	2	0.15	5.4
10784	72	Mozzarella di Giovanni	34.8	30	0.15	156.6
10785	10	Ikura	31.0	10	0.0	0.0
10785	75	Rhönbräu Klosterbier	7.75	10	0.0	0.0
10786	8	Northwoods Cranberry Sauce	40.0	30	0.2	240.0
10786	30	Nord-Ost Matjeshering	25.89	15	0.2	77.67
10786	75	Rhönbräu Klosterbier	7.75	42	0.2	65.1
10787	2	Chang	19.0	15	0.05	14.25
10787	29	Thüringer Rostbratwurst	123.79	20	0.05	123.79
10788	19	Teatime Chocolate Biscuits	9.2	50	0.05	23.0
10788	75	Rhönbräu Klosterbier	7.75	40	0.05	15.5
10789	18	Carnarvon Tigers	62.5	30	0.0	0.0
10789	35	Steeleye Stout	18.0	15	0.0	0.0
10789	63	Vegie-spread	43.9	30	0.0	0.0
10789	68	Scottish Longbreads	12.5	18	0.0	0.0
10790	7	Uncle Bob's Organic Dried Pears	30.0	3	0.15	13.5
10790	56	Gnocchi di nonna Alice	38.0	20	0.15	114.0
10791	29	Thüringer Rostbratwurst	123.79	14	0.05	86.65
10791	41	Jack's New England Clam Chowder	9.65	20	0.05	9.65
10792	2	Chang	19.0	10	0.0	0.0
10792	54	Tourtière	7.45	3	0.0	0.0
10792	68	Scottish Longbreads	12.5	15	0.0	0.0
10793	41	Jack's New England Clam Chowder	9.65	14	0.0	0.0
10793	52	Filo Mix	7.0	8	0.0	0.0
10794	14	Tofu	23.25	15	0.2	69.75
10794	54	Tourtière	7.45	6	0.2	8.94
10795	16	Pavlova	17.45	65	0.0	0.0
10795	17	Alice Mutton	39.0	35	0.25	341.25
10796	26	Gumbär Gummibärchen	31.23	21	0.2	131.16
10796	44	Gula Malacca	19.45	10	0.0	0.0
10796	64	Wimmers gute Semmelknödel	33.25	35	0.2	232.75
10796	69	Gudbrandsdalsost	36.0	24	0.2	172.8
10797	11	Queso Cabrales	21.0	20	0.0	0.0
10798	62	Tarte au sucre	49.3	2	0.0	0.0
10798	72	Mozzarella di Giovanni	34.8	10	0.0	0.0
10799	13	Konbu	6.0	20	0.15	18.0
10799	24	Guaraná Fantástica	4.5	20	0.15	13.5
10799	59	Raclette Courdavault	55.0	25	0.0	0.0
10800	11	Queso Cabrales	21.0	50	0.1	105.0
10800	51	Manjimup Dried Apples	53.0	10	0.1	53.0
10800	54	Tourtière	7.45	7	0.1	5.21
10801	17	Alice Mutton	39.0	40	0.25	390.0
10801	29	Thüringer Rostbratwurst	123.79	20	0.25	618.95
10802	30	Nord-Ost Matjeshering	25.89	25	0.25	161.81
10802	51	Manjimup Dried Apples	53.0	30	0.25	397.5
10802	55	Pâté chinois	24.0	60	0.25	360.0
10802	62	Tarte au sucre	49.3	5	0.25	61.62
10803	19	Teatime Chocolate Biscuits	9.2	24	0.05	11.04
10803	25	NuNuCa Nuß-Nougat-Creme	14.0	15	0.05	10.5
10803	59	Raclette Courdavault	55.0	15	0.05	41.25
10804	10	Ikura	31.0	36	0.0	0.0
10804	28	Rössle Sauerkraut	45.6	24	0.0	0.0
10804	49	Maxilaku	20.0	4	0.15	12.0
10805	34	Sasquatch Ale	14.0	10	0.0	0.0
10805	38	Côte de Blaye	263.5	10	0.0	0.0
10806	2	Chang	19.0	20	0.25	95.0
10806	65	Louisiana Fiery Hot Pepper Sauce	21.05	2	0.0	0.0
10806	74	Longlife Tofu	10.0	15	0.25	37.5
10807	40	Boston Crab Meat	18.4	1	0.0	0.0
10808	56	Gnocchi di nonna Alice	38.0	20	0.15	114.0
10808	76	Lakkalikööri	18.0	50	0.15	135.0
10809	52	Filo Mix	7.0	20	0.0	0.0
10810	13	Konbu	6.0	7	0.0	0.0
10810	25	NuNuCa Nuß-Nougat-Creme	14.0	5	0.0	0.0
10810	70	Outback Lager	15.0	5	0.0	0.0
10811	19	Teatime Chocolate Biscuits	9.2	15	0.0	0.0
10811	23	Tunnbröd	9.0	18	0.0	0.0
10811	40	Boston Crab Meat	18.4	30	0.0	0.0
10812	31	Gorgonzola Telino	12.5	16	0.1	20.0
10812	72	Mozzarella di Giovanni	34.8	40	0.1	139.2
10812	77	Original Frankfurter grüne Soße	13.0	20	0.0	0.0
10813	2	Chang	19.0	12	0.2	45.6
10813	46	Spegesild	12.0	35	0.0	0.0
10814	41	Jack's New England Clam Chowder	9.65	20	0.0	0.0
10814	43	Ipoh Coffee	46.0	20	0.15	138.0
10814	48	Chocolade	12.75	8	0.15	15.3
10814	61	Sirop d'érable	28.5	30	0.15	128.25
10815	33	Geitost	2.5	16	0.0	0.0
10816	38	Côte de Blaye	263.5	30	0.05	395.25
10816	62	Tarte au sucre	49.3	20	0.05	49.3
10817	26	Gumbär Gummibärchen	31.23	40	0.15	187.38
10817	38	Côte de Blaye	263.5	30	0.0	0.0
10817	40	Boston Crab Meat	18.4	60	0.15	165.6
10817	62	Tarte au sucre	49.3	25	0.15	184.87
10818	32	Mascarpone Fabioli	32.0	20	0.0	0.0
10818	41	Jack's New England Clam Chowder	9.65	20	0.0	0.0
10819	43	Ipoh Coffee	46.0	7	0.0	0.0
10819	75	Rhönbräu Klosterbier	7.75	20	0.0	0.0
10820	56	Gnocchi di nonna Alice	38.0	30	0.0	0.0
10821	35	Steeleye Stout	18.0	20	0.0	0.0
10821	51	Manjimup Dried Apples	53.0	6	0.0	0.0
10822	62	Tarte au sucre	49.3	3	0.0	0.0
10822	70	Outback Lager	15.0	6	0.0	0.0
10823	11	Queso Cabrales	21.0	20	0.1	42.0
10823	57	Ravioli Angelo	19.5	15	0.0	0.0
10823	59	Raclette Courdavault	55.0	40	0.1	220.0
10823	77	Original Frankfurter grüne Soße	13.0	15	0.1	19.5
10824	41	Jack's New England Clam Chowder	9.65	12	0.0	0.0
10824	70	Outback Lager	15.0	9	0.0	0.0
10825	26	Gumbär Gummibärchen	31.23	12	0.0	0.0
10825	53	Perth Pasties	32.8	20	0.0	0.0
10826	31	Gorgonzola Telino	12.5	35	0.0	0.0
10826	57	Ravioli Angelo	19.5	15	0.0	0.0
10827	10	Ikura	31.0	15	0.0	0.0
10827	39	Chartreuse verte	18.0	21	0.0	0.0
10828	20	Sir Rodney's Marmalade	81.0	5	0.0	0.0
10828	38	Côte de Blaye	263.5	2	0.0	0.0
10829	2	Chang	19.0	10	0.0	0.0
10829	8	Northwoods Cranberry Sauce	40.0	20	0.0	0.0
10829	13	Konbu	6.0	10	0.0	0.0
10829	60	Camembert Pierrot	34.0	21	0.0	0.0
10830	6	Grandma's Boysenberry Spread	25.0	6	0.0	0.0
10830	39	Chartreuse verte	18.0	28	0.0	0.0
10830	60	Camembert Pierrot	34.0	30	0.0	0.0
10830	68	Scottish Longbreads	12.5	24	0.0	0.0
10831	19	Teatime Chocolate Biscuits	9.2	2	0.0	0.0
10831	35	Steeleye Stout	18.0	8	0.0	0.0
10831	38	Côte de Blaye	263.5	8	0.0	0.0
10831	43	Ipoh Coffee	46.0	9	0.0	0.0
10832	13	Konbu	6.0	3	0.2	3.6
10832	25	NuNuCa Nuß-Nougat-Creme	14.0	10	0.2	28.0
10832	44	Gula Malacca	19.45	16	0.2	62.24
10832	64	Wimmers gute Semmelknödel	33.25	3	0.0	0.0
10833	7	Uncle Bob's Organic Dried Pears	30.0	20	0.1	60.0
10833	31	Gorgonzola Telino	12.5	9	0.1	11.25
10833	53	Perth Pasties	32.8	9	0.1	29.52
10834	29	Thüringer Rostbratwurst	123.79	8	0.05	49.51
10834	30	Nord-Ost Matjeshering	25.89	20	0.05	25.89
10835	59	Raclette Courdavault	55.0	15	0.0	0.0
10835	77	Original Frankfurter grüne Soße	13.0	2	0.2	5.2
10836	22	Gustaf's Knäckebröd	21.0	52	0.0	0.0
10836	35	Steeleye Stout	18.0	6	0.0	0.0
10836	57	Ravioli Angelo	19.5	24	0.0	0.0
10836	60	Camembert Pierrot	34.0	60	0.0	0.0
10836	64	Wimmers gute Semmelknödel	33.25	30	0.0	0.0
10837	13	Konbu	6.0	6	0.0	0.0
10837	40	Boston Crab Meat	18.4	25	0.0	0.0
10837	47	Zaanse koeken	9.5	40	0.25	95.0
10837	76	Lakkalikööri	18.0	21	0.25	94.5
10838	1	Chai	18.0	4	0.25	18.0
10838	18	Carnarvon Tigers	62.5	25	0.25	390.62
10838	36	Inlagd Sill	19.0	50	0.25	237.5
10839	58	Escargots de Bourgogne	13.25	30	0.1	39.75
10839	72	Mozzarella di Giovanni	34.8	15	0.1	52.2
10840	25	NuNuCa Nuß-Nougat-Creme	14.0	6	0.2	16.8
10840	39	Chartreuse verte	18.0	10	0.2	36.0
10841	10	Ikura	31.0	16	0.0	0.0
10841	56	Gnocchi di nonna Alice	38.0	30	0.0	0.0
10841	59	Raclette Courdavault	55.0	50	0.0	0.0
10841	77	Original Frankfurter grüne Soße	13.0	15	0.0	0.0
10842	11	Queso Cabrales	21.0	15	0.0	0.0
10842	43	Ipoh Coffee	46.0	5	0.0	0.0
10842	68	Scottish Longbreads	12.5	20	0.0	0.0
10842	70	Outback Lager	15.0	12	0.0	0.0
10843	51	Manjimup Dried Apples	53.0	4	0.25	53.0
10844	22	Gustaf's Knäckebröd	21.0	35	0.0	0.0
10845	23	Tunnbröd	9.0	70	0.1	63.0
10845	35	Steeleye Stout	18.0	25	0.1	45.0
10845	42	Singaporean Hokkien Fried Mee	14.0	42	0.1	58.8
10845	58	Escargots de Bourgogne	13.25	60	0.1	79.5
10845	64	Wimmers gute Semmelknödel	33.25	48	0.0	0.0
10846	4	Chef Anton's Cajun Seasoning	22.0	21	0.0	0.0
10846	70	Outback Lager	15.0	30	0.0	0.0
10846	74	Longlife Tofu	10.0	20	0.0	0.0
10847	1	Chai	18.0	80	0.2	288.0
10847	19	Teatime Chocolate Biscuits	9.2	12	0.2	22.08
10847	37	Gravad lax	26.0	60	0.2	312.0
10847	45	Røgede sild	9.5	36	0.2	68.4
10847	60	Camembert Pierrot	34.0	45	0.2	306.0
10847	71	Fløtemysost	21.5	55	0.2	236.5
10848	5	Chef Anton's Gumbo Mix	21.35	30	0.0	0.0
10848	9	Mishi Kobe Niku	97.0	3	0.0	0.0
10849	3	Aniseed Syrup	10.0	49	0.0	0.0
10849	26	Gumbär Gummibärchen	31.23	18	0.15	84.32
10850	25	NuNuCa Nuß-Nougat-Creme	14.0	20	0.15	42.0
10850	33	Geitost	2.5	4	0.15	1.5
10850	70	Outback Lager	15.0	30	0.15	67.5
10851	2	Chang	19.0	5	0.05	4.75
10851	25	NuNuCa Nuß-Nougat-Creme	14.0	10	0.05	7.0
10851	57	Ravioli Angelo	19.5	10	0.05	9.75
10851	59	Raclette Courdavault	55.0	42	0.05	115.5
10852	2	Chang	19.0	15	0.0	0.0
10852	17	Alice Mutton	39.0	6	0.0	0.0
10852	62	Tarte au sucre	49.3	50	0.0	0.0
10853	18	Carnarvon Tigers	62.5	10	0.0	0.0
10854	10	Ikura	31.0	100	0.15	465.0
10854	13	Konbu	6.0	65	0.15	58.5
10855	16	Pavlova	17.45	50	0.0	0.0
10855	31	Gorgonzola Telino	12.5	14	0.0	0.0
10855	56	Gnocchi di nonna Alice	38.0	24	0.0	0.0
10855	65	Louisiana Fiery Hot Pepper Sauce	21.05	15	0.15	47.36
10856	2	Chang	19.0	20	0.0	0.0
10856	42	Singaporean Hokkien Fried Mee	14.0	20	0.0	0.0
10857	3	Aniseed Syrup	10.0	30	0.0	0.0
10857	26	Gumbär Gummibärchen	31.23	35	0.25	273.26
10857	29	Thüringer Rostbratwurst	123.79	10	0.25	309.47
10858	7	Uncle Bob's Organic Dried Pears	30.0	5	0.0	0.0
10858	27	Schoggi Schokolade	43.9	10	0.0	0.0
10858	70	Outback Lager	15.0	4	0.0	0.0
10859	24	Guaraná Fantástica	4.5	40	0.25	45.0
10859	54	Tourtière	7.45	35	0.25	65.18
10859	64	Wimmers gute Semmelknödel	33.25	30	0.25	249.37
10860	51	Manjimup Dried Apples	53.0	3	0.0	0.0
10860	76	Lakkalikööri	18.0	20	0.0	0.0
10861	17	Alice Mutton	39.0	42	0.0	0.0
10861	18	Carnarvon Tigers	62.5	20	0.0	0.0
10861	21	Sir Rodney's Scones	10.0	40	0.0	0.0
10861	33	Geitost	2.5	35	0.0	0.0
10861	62	Tarte au sucre	49.3	3	0.0	0.0
10862	11	Queso Cabrales	21.0	25	0.0	0.0
10862	52	Filo Mix	7.0	8	0.0	0.0
10863	1	Chai	18.0	20	0.15	54.0
10863	58	Escargots de Bourgogne	13.25	12	0.15	23.85
10864	35	Steeleye Stout	18.0	4	0.0	0.0
10864	67	Laughing Lumberjack Lager	14.0	15	0.0	0.0
10865	38	Côte de Blaye	263.5	60	0.05	790.5
10865	39	Chartreuse verte	18.0	80	0.05	72.0
10866	2	Chang	19.0	21	0.25	99.75
10866	24	Guaraná Fantástica	4.5	6	0.25	6.75
10866	30	Nord-Ost Matjeshering	25.89	40	0.25	258.9
10867	53	Perth Pasties	32.8	3	0.0	0.0
10868	26	Gumbär Gummibärchen	31.23	20	0.0	0.0
10868	35	Steeleye Stout	18.0	30	0.0	0.0
10868	49	Maxilaku	20.0	42	0.1	84.0
10869	1	Chai	18.0	40	0.0	0.0
10869	11	Queso Cabrales	21.0	10	0.0	0.0
10869	23	Tunnbröd	9.0	50	0.0	0.0
10869	68	Scottish Longbreads	12.5	20	0.0	0.0
10870	35	Steeleye Stout	18.0	3	0.0	0.0
10870	51	Manjimup Dried Apples	53.0	2	0.0	0.0
10871	6	Grandma's Boysenberry Spread	25.0	50	0.05	62.5
10871	16	Pavlova	17.45	12	0.05	10.47
10871	17	Alice Mutton	39.0	16	0.05	31.2
10872	55	Pâté chinois	24.0	10	0.05	12.0
10872	62	Tarte au sucre	49.3	20	0.05	49.3
10872	64	Wimmers gute Semmelknödel	33.25	15	0.05	24.93
10872	65	Louisiana Fiery Hot Pepper Sauce	21.05	21	0.05	22.1
10873	21	Sir Rodney's Scones	10.0	20	0.0	0.0
10873	28	Rössle Sauerkraut	45.6	3	0.0	0.0
10874	10	Ikura	31.0	10	0.0	0.0
10875	19	Teatime Chocolate Biscuits	9.2	25	0.0	0.0
10875	47	Zaanse koeken	9.5	21	0.1	19.95
10875	49	Maxilaku	20.0	15	0.0	0.0
10876	46	Spegesild	12.0	21	0.0	0.0
10876	64	Wimmers gute Semmelknödel	33.25	20	0.0	0.0
10877	16	Pavlova	17.45	30	0.25	130.87
10877	18	Carnarvon Tigers	62.5	25	0.0	0.0
10878	20	Sir Rodney's Marmalade	81.0	20	0.05	81.0
10879	40	Boston Crab Meat	18.4	12	0.0	0.0
10879	65	Louisiana Fiery Hot Pepper Sauce	21.05	10	0.0	0.0
10879	76	Lakkalikööri	18.0	10	0.0	0.0
10880	23	Tunnbröd	9.0	30	0.2	54.0
10880	61	Sirop d'érable	28.5	30	0.2	171.0
10880	70	Outback Lager	15.0	50	0.2	150.0
10881	73	Röd Kaviar	15.0	10	0.0	0.0
10882	42	Singaporean Hokkien Fried Mee	14.0	25	0.0	0.0
10882	49	Maxilaku	20.0	20	0.15	60.0
10882	54	Tourtière	7.45	32	0.15	35.76
10883	24	Guaraná Fantástica	4.5	8	0.0	0.0
10884	21	Sir Rodney's Scones	10.0	40	0.05	20.0
10884	56	Gnocchi di nonna Alice	38.0	21	0.05	39.9
10884	65	Louisiana Fiery Hot Pepper Sauce	21.05	12	0.05	12.63
10885	2	Chang	19.0	20	0.0	0.0
10885	24	Guaraná Fantástica	4.5	12	0.0	0.0
10885	70	Outback Lager	15.0	30	0.0	0.0
10885	77	Original Frankfurter grüne Soße	13.0	25	0.0	0.0
10886	10	Ikura	31.0	70	0.0	0.0
10886	31	Gorgonzola Telino	12.5	35	0.0	0.0
10886	77	Original Frankfurter grüne Soße	13.0	40	0.0	0.0
10887	25	NuNuCa Nuß-Nougat-Creme	14.0	5	0.0	0.0
10888	2	Chang	19.0	20	0.0	0.0
10888	68	Scottish Longbreads	12.5	18	0.0	0.0
10889	11	Queso Cabrales	21.0	40	0.0	0.0
10889	38	Côte de Blaye	263.5	40	0.0	0.0
10890	17	Alice Mutton	39.0	15	0.0	0.0
10890	34	Sasquatch Ale	14.0	10	0.0	0.0
10890	41	Jack's New England Clam Chowder	9.65	14	0.0	0.0
10891	30	Nord-Ost Matjeshering	25.89	15	0.05	19.41
10892	59	Raclette Courdavault	55.0	40	0.05	110.0
10893	8	Northwoods Cranberry Sauce	40.0	30	0.0	0.0
10893	24	Guaraná Fantástica	4.5	10	0.0	0.0
10893	29	Thüringer Rostbratwurst	123.79	24	0.0	0.0
10893	30	Nord-Ost Matjeshering	25.89	35	0.0	0.0
10893	36	Inlagd Sill	19.0	20	0.0	0.0
10894	13	Konbu	6.0	28	0.05	8.4
10894	69	Gudbrandsdalsost	36.0	50	0.05	90.0
10894	75	Rhönbräu Klosterbier	7.75	120	0.05	46.5
10895	24	Guaraná Fantástica	4.5	110	0.0	0.0
10895	39	Chartreuse verte	18.0	45	0.0	0.0
10895	40	Boston Crab Meat	18.4	91	0.0	0.0
10895	60	Camembert Pierrot	34.0	100	0.0	0.0
10896	45	Røgede sild	9.5	15	0.0	0.0
10896	56	Gnocchi di nonna Alice	38.0	16	0.0	0.0
10897	29	Thüringer Rostbratwurst	123.79	80	0.0	0.0
10897	30	Nord-Ost Matjeshering	25.89	36	0.0	0.0
10898	13	Konbu	6.0	5	0.0	0.0
10899	39	Chartreuse verte	18.0	8	0.15	21.6
10900	70	Outback Lager	15.0	3	0.25	11.25
10901	41	Jack's New England Clam Chowder	9.65	30	0.0	0.0
10901	71	Fløtemysost	21.5	30	0.0	0.0
10902	55	Pâté chinois	24.0	30	0.15	108.0
10902	62	Tarte au sucre	49.3	6	0.15	44.37
10903	13	Konbu	6.0	40	0.0	0.0
10903	65	Louisiana Fiery Hot Pepper Sauce	21.05	21	0.0	0.0
10903	68	Scottish Longbreads	12.5	20	0.0	0.0
10904	58	Escargots de Bourgogne	13.25	15	0.0	0.0
10904	62	Tarte au sucre	49.3	35	0.0	0.0
10905	1	Chai	18.0	20	0.05	18.0
10906	61	Sirop d'érable	28.5	15	0.0	0.0
10907	75	Rhönbräu Klosterbier	7.75	14	0.0	0.0
10908	7	Uncle Bob's Organic Dried Pears	30.0	20	0.05	30.0
10908	52	Filo Mix	7.0	14	0.05	4.9
10909	7	Uncle Bob's Organic Dried Pears	30.0	12	0.0	0.0
10909	16	Pavlova	17.45	15	0.0	0.0
10909	41	Jack's New England Clam Chowder	9.65	5	0.0	0.0
10910	19	Teatime Chocolate Biscuits	9.2	12	0.0	0.0
10910	49	Maxilaku	20.0	10	0.0	0.0
10910	61	Sirop d'érable	28.5	5	0.0	0.0
10911	1	Chai	18.0	10	0.0	0.0
10911	17	Alice Mutton	39.0	12	0.0	0.0
10911	67	Laughing Lumberjack Lager	14.0	15	0.0	0.0
10912	11	Queso Cabrales	21.0	40	0.25	210.0
10912	29	Thüringer Rostbratwurst	123.79	60	0.25	1856.85
10913	4	Chef Anton's Cajun Seasoning	22.0	30	0.25	165.0
10913	33	Geitost	2.5	40	0.25	25.0
10913	58	Escargots de Bourgogne	13.25	15	0.0	0.0
10914	71	Fløtemysost	21.5	25	0.0	0.0
10915	17	Alice Mutton	39.0	10	0.0	0.0
10915	33	Geitost	2.5	30	0.0	0.0
10915	54	Tourtière	7.45	10	0.0	0.0
10916	16	Pavlova	17.45	6	0.0	0.0
10916	32	Mascarpone Fabioli	32.0	6	0.0	0.0
10916	57	Ravioli Angelo	19.5	20	0.0	0.0
10917	30	Nord-Ost Matjeshering	25.89	1	0.0	0.0
10917	60	Camembert Pierrot	34.0	10	0.0	0.0
10918	1	Chai	18.0	60	0.25	270.0
10918	60	Camembert Pierrot	34.0	25	0.25	212.5
10919	16	Pavlova	17.45	24	0.0	0.0
10919	25	NuNuCa Nuß-Nougat-Creme	14.0	24	0.0	0.0
10919	40	Boston Crab Meat	18.4	20	0.0	0.0
10920	50	Valkoinen suklaa	16.25	24	0.0	0.0
10921	35	Steeleye Stout	18.0	10	0.0	0.0
10921	63	Vegie-spread	43.9	40	0.0	0.0
10922	17	Alice Mutton	39.0	15	0.0	0.0
10922	24	Guaraná Fantástica	4.5	35	0.0	0.0
10923	42	Singaporean Hokkien Fried Mee	14.0	10	0.2	28.0
10923	43	Ipoh Coffee	46.0	10	0.2	92.0
10923	67	Laughing Lumberjack Lager	14.0	24	0.2	67.2
10924	10	Ikura	31.0	20	0.1	62.0
10924	28	Rössle Sauerkraut	45.6	30	0.1	136.8
10924	75	Rhönbräu Klosterbier	7.75	6	0.0	0.0
10925	36	Inlagd Sill	19.0	25	0.15	71.25
10925	52	Filo Mix	7.0	12	0.15	12.6
10926	11	Queso Cabrales	21.0	2	0.0	0.0
10926	13	Konbu	6.0	10	0.0	0.0
10926	19	Teatime Chocolate Biscuits	9.2	7	0.0	0.0
10926	72	Mozzarella di Giovanni	34.8	10	0.0	0.0
10927	20	Sir Rodney's Marmalade	81.0	5	0.0	0.0
10927	52	Filo Mix	7.0	5	0.0	0.0
10927	76	Lakkalikööri	18.0	20	0.0	0.0
10928	47	Zaanse koeken	9.5	5	0.0	0.0
10928	76	Lakkalikööri	18.0	5	0.0	0.0
10929	21	Sir Rodney's Scones	10.0	60	0.0	0.0
10929	75	Rhönbräu Klosterbier	7.75	49	0.0	0.0
10929	77	Original Frankfurter grüne Soße	13.0	15	0.0	0.0
10930	21	Sir Rodney's Scones	10.0	36	0.0	0.0
10930	27	Schoggi Schokolade	43.9	25	0.0	0.0
10930	55	Pâté chinois	24.0	25	0.2	120.0
10930	58	Escargots de Bourgogne	13.25	30	0.2	79.5
10931	13	Konbu	6.0	42	0.15	37.8
10931	57	Ravioli Angelo	19.5	30	0.0	0.0
10932	16	Pavlova	17.45	30	0.1	52.35
10932	62	Tarte au sucre	49.3	14	0.1	69.02
10932	72	Mozzarella di Giovanni	34.8	16	0.0	0.0
10932	75	Rhönbräu Klosterbier	7.75	20	0.1	15.5
10933	53	Perth Pasties	32.8	2	0.0	0.0
10933	61	Sirop d'érable	28.5	30	0.0	0.0
10934	6	Grandma's Boysenberry Spread	25.0	20	0.0	0.0
10935	1	Chai	18.0	21	0.0	0.0
10935	18	Carnarvon Tigers	62.5	4	0.25	62.5
10935	23	Tunnbröd	9.0	8	0.25	18.0
10936	36	Inlagd Sill	19.0	30	0.2	114.0
10937	28	Rössle Sauerkraut	45.6	8	0.0	0.0
10937	34	Sasquatch Ale	14.0	20	0.0	0.0
10938	13	Konbu	6.0	20	0.25	30.0
10938	43	Ipoh Coffee	46.0	24	0.25	276.0
10938	60	Camembert Pierrot	34.0	49	0.25	416.5
10938	71	Fløtemysost	21.5	35	0.25	188.12
10939	2	Chang	19.0	10	0.15	28.5
10939	67	Laughing Lumberjack Lager	14.0	40	0.15	84.0
10940	7	Uncle Bob's Organic Dried Pears	30.0	8	0.0	0.0
10940	13	Konbu	6.0	20	0.0	0.0
10941	31	Gorgonzola Telino	12.5	44	0.25	137.5
10941	62	Tarte au sucre	49.3	30	0.25	369.75
10941	68	Scottish Longbreads	12.5	80	0.25	250.0
10941	72	Mozzarella di Giovanni	34.8	50	0.0	0.0
10942	49	Maxilaku	20.0	28	0.0	0.0
10943	13	Konbu	6.0	15	0.0	0.0
10943	22	Gustaf's Knäckebröd	21.0	21	0.0	0.0
10943	46	Spegesild	12.0	15	0.0	0.0
10944	11	Queso Cabrales	21.0	5	0.25	26.25
10944	44	Gula Malacca	19.45	18	0.25	87.52
10944	56	Gnocchi di nonna Alice	38.0	18	0.0	0.0
10945	13	Konbu	6.0	20	0.0	0.0
10945	31	Gorgonzola Telino	12.5	10	0.0	0.0
10946	10	Ikura	31.0	25	0.0	0.0
10946	24	Guaraná Fantástica	4.5	25	0.0	0.0
10946	77	Original Frankfurter grüne Soße	13.0	40	0.0	0.0
10947	59	Raclette Courdavault	55.0	4	0.0	0.0
10948	50	Valkoinen suklaa	16.25	9	0.0	0.0
10948	51	Manjimup Dried Apples	53.0	40	0.0	0.0
10948	55	Pâté chinois	24.0	4	0.0	0.0
10949	6	Grandma's Boysenberry Spread	25.0	12	0.0	0.0
10949	10	Ikura	31.0	30	0.0	0.0
10949	17	Alice Mutton	39.0	6	0.0	0.0
10949	62	Tarte au sucre	49.3	60	0.0	0.0
10950	4	Chef Anton's Cajun Seasoning	22.0	5	0.0	0.0
10951	33	Geitost	2.5	15	0.05	1.87
10951	41	Jack's New England Clam Chowder	9.65	6	0.05	2.89
10951	75	Rhönbräu Klosterbier	7.75	50	0.05	19.37
10952	6	Grandma's Boysenberry Spread	25.0	16	0.05	20.0
10952	28	Rössle Sauerkraut	45.6	2	0.0	0.0
10953	20	Sir Rodney's Marmalade	81.0	50	0.05	202.5
10953	31	Gorgonzola Telino	12.5	50	0.05	31.25
10954	16	Pavlova	17.45	28	0.15	73.29
10954	31	Gorgonzola Telino	12.5	25	0.15	46.87
10954	45	Røgede sild	9.5	30	0.0	0.0
10954	60	Camembert Pierrot	34.0	24	0.15	122.4
10955	75	Rhönbräu Klosterbier	7.75	12	0.2	18.6
10956	21	Sir Rodney's Scones	10.0	12	0.0	0.0
10956	47	Zaanse koeken	9.5	14	0.0	0.0
10956	51	Manjimup Dried Apples	53.0	8	0.0	0.0
10957	30	Nord-Ost Matjeshering	25.89	30	0.0	0.0
10957	35	Steeleye Stout	18.0	40	0.0	0.0
10957	64	Wimmers gute Semmelknödel	33.25	8	0.0	0.0
10958	5	Chef Anton's Gumbo Mix	21.35	20	0.0	0.0
10958	7	Uncle Bob's Organic Dried Pears	30.0	6	0.0	0.0
10958	72	Mozzarella di Giovanni	34.8	5	0.0	0.0
10959	75	Rhönbräu Klosterbier	7.75	20	0.15	23.25
10960	24	Guaraná Fantástica	4.5	10	0.25	11.25
10960	41	Jack's New England Clam Chowder	9.65	24	0.0	0.0
10961	52	Filo Mix	7.0	6	0.05	2.1
10961	76	Lakkalikööri	18.0	60	0.0	0.0
10962	7	Uncle Bob's Organic Dried Pears	30.0	45	0.0	0.0
10962	13	Konbu	6.0	77	0.0	0.0
10962	53	Perth Pasties	32.8	20	0.0	0.0
10962	69	Gudbrandsdalsost	36.0	9	0.0	0.0
10962	76	Lakkalikööri	18.0	44	0.0	0.0
10963	60	Camembert Pierrot	34.0	2	0.15	10.2
10964	18	Carnarvon Tigers	62.5	6	0.0	0.0
10964	38	Côte de Blaye	263.5	5	0.0	0.0
10964	69	Gudbrandsdalsost	36.0	10	0.0	0.0
10965	51	Manjimup Dried Apples	53.0	16	0.0	0.0
10966	37	Gravad lax	26.0	8	0.0	0.0
10966	56	Gnocchi di nonna Alice	38.0	12	0.15	68.4
10966	62	Tarte au sucre	49.3	12	0.15	88.74
10967	19	Teatime Chocolate Biscuits	9.2	12	0.0	0.0
10967	49	Maxilaku	20.0	40	0.0	0.0
10968	12	Queso Manchego La Pastora	38.0	30	0.0	0.0
10968	24	Guaraná Fantástica	4.5	30	0.0	0.0
10968	64	Wimmers gute Semmelknödel	33.25	4	0.0	0.0
10969	46	Spegesild	12.0	9	0.0	0.0
10970	52	Filo Mix	7.0	40	0.2	56.0
10971	29	Thüringer Rostbratwurst	123.79	14	0.0	0.0
10972	17	Alice Mutton	39.0	6	0.0	0.0
10972	33	Geitost	2.5	7	0.0	0.0
10973	26	Gumbär Gummibärchen	31.23	5	0.0	0.0
10973	41	Jack's New England Clam Chowder	9.65	6	0.0	0.0
10973	75	Rhönbräu Klosterbier	7.75	10	0.0	0.0
10974	63	Vegie-spread	43.9	10	0.0	0.0
10975	8	Northwoods Cranberry Sauce	40.0	16	0.0	0.0
10975	75	Rhönbräu Klosterbier	7.75	10	0.0	0.0
10976	28	Rössle Sauerkraut	45.6	20	0.0	0.0
10977	39	Chartreuse verte	18.0	30	0.0	0.0
10977	47	Zaanse koeken	9.5	30	0.0	0.0
10977	51	Manjimup Dried Apples	53.0	10	0.0	0.0
10977	63	Vegie-spread	43.9	20	0.0	0.0
10978	8	Northwoods Cranberry Sauce	40.0	20	0.15	120.0
10978	21	Sir Rodney's Scones	10.0	40	0.15	60.0
10978	40	Boston Crab Meat	18.4	10	0.0	0.0
10978	44	Gula Malacca	19.45	6	0.15	17.5
10979	7	Uncle Bob's Organic Dried Pears	30.0	18	0.0	0.0
10979	12	Queso Manchego La Pastora	38.0	20	0.0	0.0
10979	24	Guaraná Fantástica	4.5	80	0.0	0.0
10979	27	Schoggi Schokolade	43.9	30	0.0	0.0
10979	31	Gorgonzola Telino	12.5	24	0.0	0.0
10979	63	Vegie-spread	43.9	35	0.0	0.0
10980	75	Rhönbräu Klosterbier	7.75	40	0.2	62.0
10981	38	Côte de Blaye	263.5	60	0.0	0.0
10982	7	Uncle Bob's Organic Dried Pears	30.0	20	0.0	0.0
10982	43	Ipoh Coffee	46.0	9	0.0	0.0
10983	13	Konbu	6.0	84	0.15	75.6
10983	57	Ravioli Angelo	19.5	15	0.0	0.0
10984	16	Pavlova	17.45	55	0.0	0.0
10984	24	Guaraná Fantástica	4.5	20	0.0	0.0
10984	36	Inlagd Sill	19.0	40	0.0	0.0
10985	16	Pavlova	17.45	36	0.1	62.82
10985	18	Carnarvon Tigers	62.5	8	0.1	50.0
10985	32	Mascarpone Fabioli	32.0	35	0.1	112.0
10986	11	Queso Cabrales	21.0	30	0.0	0.0
10986	20	Sir Rodney's Marmalade	81.0	15	0.0	0.0
10986	76	Lakkalikööri	18.0	10	0.0	0.0
10986	77	Original Frankfurter grüne Soße	13.0	15	0.0	0.0
10987	7	Uncle Bob's Organic Dried Pears	30.0	60	0.0	0.0
10987	43	Ipoh Coffee	46.0	6	0.0	0.0
10987	72	Mozzarella di Giovanni	34.8	20	0.0	0.0
10988	7	Uncle Bob's Organic Dried Pears	30.0	60	0.0	0.0
10988	62	Tarte au sucre	49.3	40	0.1	197.2
10989	6	Grandma's Boysenberry Spread	25.0	40	0.0	0.0
10989	11	Queso Cabrales	21.0	15	0.0	0.0
10989	41	Jack's New England Clam Chowder	9.65	4	0.0	0.0
10990	21	Sir Rodney's Scones	10.0	65	0.0	0.0
10990	34	Sasquatch Ale	14.0	60	0.15	126.0
10990	55	Pâté chinois	24.0	65	0.15	234.0
10990	61	Sirop d'érable	28.5	66	0.15	282.15
10991	2	Chang	19.0	50	0.2	190.0
10991	70	Outback Lager	15.0	20	0.2	60.0
10991	76	Lakkalikööri	18.0	90	0.2	324.0
10992	72	Mozzarella di Giovanni	34.8	2	0.0	0.0
10993	29	Thüringer Rostbratwurst	123.79	50	0.25	1547.37
10993	41	Jack's New England Clam Chowder	9.65	35	0.25	84.43
10994	59	Raclette Courdavault	55.0	18	0.05	49.5
10995	51	Manjimup Dried Apples	53.0	20	0.0	0.0
10995	60	Camembert Pierrot	34.0	4	0.0	0.0
10996	42	Singaporean Hokkien Fried Mee	14.0	40	0.0	0.0
10997	32	Mascarpone Fabioli	32.0	50	0.0	0.0
10997	46	Spegesild	12.0	20	0.25	60.0
10997	52	Filo Mix	7.0	20	0.25	35.0
10998	24	Guaraná Fantástica	4.5	12	0.0	0.0
10998	61	Sirop d'érable	28.5	7	0.0	0.0
10998	74	Longlife Tofu	10.0	20	0.0	0.0
10998	75	Rhönbräu Klosterbier	7.75	30	0.0	0.0
10999	41	Jack's New England Clam Chowder	9.65	20	0.05	9.65
10999	51	Manjimup Dried Apples	53.0	15	0.05	39.75
10999	77	Original Frankfurter grüne Soße	13.0	21	0.05	13.65
11000	4	Chef Anton's Cajun Seasoning	22.0	25	0.25	137.5
11000	24	Guaraná Fantástica	4.5	30	0.25	33.75
11000	77	Original Frankfurter grüne Soße	13.0	30	0.0	0.0
11001	7	Uncle Bob's Organic Dried Pears	30.0	60	0.0	0.0
11001	22	Gustaf's Knäckebröd	21.0	25	0.0	0.0
11001	46	Spegesild	12.0	25	0.0	0.0
11001	55	Pâté chinois	24.0	6	0.0	0.0
11002	13	Konbu	6.0	56	0.0	0.0
11002	35	Steeleye Stout	18.0	15	0.15	40.5
11002	42	Singaporean Hokkien Fried Mee	14.0	24	0.15	50.4
11002	55	Pâté chinois	24.0	40	0.0	0.0
11003	1	Chai	18.0	4	0.0	0.0
11003	40	Boston Crab Meat	18.4	10	0.0	0.0
11003	52	Filo Mix	7.0	10	0.0	0.0
11004	26	Gumbär Gummibärchen	31.23	6	0.0	0.0
11004	76	Lakkalikööri	18.0	6	0.0	0.0
11005	1	Chai	18.0	2	0.0	0.0
11005	59	Raclette Courdavault	55.0	10	0.0	0.0
11006	1	Chai	18.0	8	0.0	0.0
11006	29	Thüringer Rostbratwurst	123.79	2	0.25	61.89
11007	8	Northwoods Cranberry Sauce	40.0	30	0.0	0.0
11007	29	Thüringer Rostbratwurst	123.79	10	0.0	0.0
11007	42	Singaporean Hokkien Fried Mee	14.0	14	0.0	0.0
11008	28	Rössle Sauerkraut	45.6	70	0.05	159.6
11008	34	Sasquatch Ale	14.0	90	0.05	63.0
11008	71	Fløtemysost	21.5	21	0.0	0.0
11009	24	Guaraná Fantástica	4.5	12	0.0	0.0
11009	36	Inlagd Sill	19.0	18	0.25	85.5
11009	60	Camembert Pierrot	34.0	9	0.0	0.0
11010	7	Uncle Bob's Organic Dried Pears	30.0	20	0.0	0.0
11010	24	Guaraná Fantástica	4.5	10	0.0	0.0
11011	58	Escargots de Bourgogne	13.25	40	0.05	26.5
11011	71	Fløtemysost	21.5	20	0.0	0.0
11012	19	Teatime Chocolate Biscuits	9.2	50	0.05	23.0
11012	60	Camembert Pierrot	34.0	36	0.05	61.2
11012	71	Fløtemysost	21.5	60	0.05	64.5
11013	23	Tunnbröd	9.0	10	0.0	0.0
11013	42	Singaporean Hokkien Fried Mee	14.0	4	0.0	0.0
11013	45	Røgede sild	9.5	20	0.0	0.0
11013	68	Scottish Longbreads	12.5	2	0.0	0.0
11014	41	Jack's New England Clam Chowder	9.65	28	0.1	27.02
11015	30	Nord-Ost Matjeshering	25.89	15	0.0	0.0
11015	77	Original Frankfurter grüne Soße	13.0	18	0.0	0.0
11016	31	Gorgonzola Telino	12.5	15	0.0	0.0
11016	36	Inlagd Sill	19.0	16	0.0	0.0
11017	3	Aniseed Syrup	10.0	25	0.0	0.0
11017	59	Raclette Courdavault	55.0	110	0.0	0.0
11017	70	Outback Lager	15.0	30	0.0	0.0
11018	12	Queso Manchego La Pastora	38.0	20	0.0	0.0
11018	18	Carnarvon Tigers	62.5	10	0.0	0.0
11018	56	Gnocchi di nonna Alice	38.0	5	0.0	0.0
11019	46	Spegesild	12.0	3	0.0	0.0
11019	49	Maxilaku	20.0	2	0.0	0.0
11020	10	Ikura	31.0	24	0.15	111.6
11021	2	Chang	19.0	11	0.25	52.25
11021	20	Sir Rodney's Marmalade	81.0	15	0.0	0.0
11021	26	Gumbär Gummibärchen	31.23	63	0.0	0.0
11021	51	Manjimup Dried Apples	53.0	44	0.25	583.0
11021	72	Mozzarella di Giovanni	34.8	35	0.0	0.0
11022	19	Teatime Chocolate Biscuits	9.2	35	0.0	0.0
11022	69	Gudbrandsdalsost	36.0	30	0.0	0.0
11023	7	Uncle Bob's Organic Dried Pears	30.0	4	0.0	0.0
11023	43	Ipoh Coffee	46.0	30	0.0	0.0
11024	26	Gumbär Gummibärchen	31.23	12	0.0	0.0
11024	33	Geitost	2.5	30	0.0	0.0
11024	65	Louisiana Fiery Hot Pepper Sauce	21.05	21	0.0	0.0
11024	71	Fløtemysost	21.5	50	0.0	0.0
11025	1	Chai	18.0	10	0.1	18.0
11025	13	Konbu	6.0	20	0.1	12.0
11026	18	Carnarvon Tigers	62.5	8	0.0	0.0
11026	51	Manjimup Dried Apples	53.0	10	0.0	0.0
11027	24	Guaraná Fantástica	4.5	30	0.25	33.75
11027	62	Tarte au sucre	49.3	21	0.25	258.82
11028	55	Pâté chinois	24.0	35	0.0	0.0
11028	59	Raclette Courdavault	55.0	24	0.0	0.0
11029	56	Gnocchi di nonna Alice	38.0	20	0.0	0.0
11029	63	Vegie-spread	43.9	12	0.0	0.0
11030	2	Chang	19.0	100	0.25	475.0
11030	5	Chef Anton's Gumbo Mix	21.35	70	0.0	0.0
11030	29	Thüringer Rostbratwurst	123.79	60	0.25	1856.85
11030	59	Raclette Courdavault	55.0	100	0.25	1375.0
11031	1	Chai	18.0	45	0.0	0.0
11031	13	Konbu	6.0	80	0.0	0.0
11031	24	Guaraná Fantástica	4.5	21	0.0	0.0
11031	64	Wimmers gute Semmelknödel	33.25	20	0.0	0.0
11031	71	Fløtemysost	21.5	16	0.0	0.0
11032	36	Inlagd Sill	19.0	35	0.0	0.0
11032	38	Côte de Blaye	263.5	25	0.0	0.0
11032	59	Raclette Courdavault	55.0	30	0.0	0.0
11033	53	Perth Pasties	32.8	70	0.1	229.6
11033	69	Gudbrandsdalsost	36.0	36	0.1	129.6
11034	21	Sir Rodney's Scones	10.0	15	0.1	15.0
11034	44	Gula Malacca	19.45	12	0.0	0.0
11034	61	Sirop d'érable	28.5	6	0.0	0.0
11035	1	Chai	18.0	10	0.0	0.0
11035	35	Steeleye Stout	18.0	60	0.0	0.0
11035	42	Singaporean Hokkien Fried Mee	14.0	30	0.0	0.0
11035	54	Tourtière	7.45	10	0.0	0.0
11036	13	Konbu	6.0	7	0.0	0.0
11036	59	Raclette Courdavault	55.0	30	0.0	0.0
11037	70	Outback Lager	15.0	4	0.0	0.0
11038	40	Boston Crab Meat	18.4	5	0.2	18.4
11038	52	Filo Mix	7.0	2	0.0	0.0
11038	71	Fløtemysost	21.5	30	0.0	0.0
11039	28	Rössle Sauerkraut	45.6	20	0.0	0.0
11039	35	Steeleye Stout	18.0	24	0.0	0.0
11039	49	Maxilaku	20.0	60	0.0	0.0
11039	57	Ravioli Angelo	19.5	28	0.0	0.0
11040	21	Sir Rodney's Scones	10.0	20	0.0	0.0
11041	2	Chang	19.0	30	0.2	114.0
11041	63	Vegie-spread	43.9	30	0.0	0.0
11042	44	Gula Malacca	19.45	15	0.0	0.0
11042	61	Sirop d'érable	28.5	4	0.0	0.0
11043	11	Queso Cabrales	21.0	10	0.0	0.0
11044	62	Tarte au sucre	49.3	12	0.0	0.0
11045	33	Geitost	2.5	15	0.0	0.0
11045	51	Manjimup Dried Apples	53.0	24	0.0	0.0
11046	12	Queso Manchego La Pastora	38.0	20	0.05	38.0
11046	32	Mascarpone Fabioli	32.0	15	0.05	24.0
11046	35	Steeleye Stout	18.0	18	0.05	16.2
11047	1	Chai	18.0	25	0.25	112.5
11047	5	Chef Anton's Gumbo Mix	21.35	30	0.25	160.12
11048	68	Scottish Longbreads	12.5	42	0.0	0.0
11049	2	Chang	19.0	10	0.2	38.0
11049	12	Queso Manchego La Pastora	38.0	4	0.2	30.4
11050	76	Lakkalikööri	18.0	50	0.1	90.0
11051	24	Guaraná Fantástica	4.5	10	0.2	9.0
11052	43	Ipoh Coffee	46.0	30	0.2	276.0
11052	61	Sirop d'érable	28.5	10	0.2	57.0
11053	18	Carnarvon Tigers	62.5	35	0.2	437.5
11053	32	Mascarpone Fabioli	32.0	20	0.0	0.0
11053	64	Wimmers gute Semmelknödel	33.25	25	0.2	166.25
11054	33	Geitost	2.5	10	0.0	0.0
11054	67	Laughing Lumberjack Lager	14.0	20	0.0	0.0
11055	24	Guaraná Fantástica	4.5	15	0.0	0.0
11055	25	NuNuCa Nuß-Nougat-Creme	14.0	15	0.0	0.0
11055	51	Manjimup Dried Apples	53.0	20	0.0	0.0
11055	57	Ravioli Angelo	19.5	20	0.0	0.0
11056	7	Uncle Bob's Organic Dried Pears	30.0	40	0.0	0.0
11056	55	Pâté chinois	24.0	35	0.0	0.0
11056	60	Camembert Pierrot	34.0	50	0.0	0.0
11057	70	Outback Lager	15.0	3	0.0	0.0
11058	21	Sir Rodney's Scones	10.0	3	0.0	0.0
11058	60	Camembert Pierrot	34.0	21	0.0	0.0
11058	61	Sirop d'érable	28.5	4	0.0	0.0
11059	13	Konbu	6.0	30	0.0	0.0
11059	17	Alice Mutton	39.0	12	0.0	0.0
11059	60	Camembert Pierrot	34.0	35	0.0	0.0
11060	60	Camembert Pierrot	34.0	4	0.0	0.0
11060	77	Original Frankfurter grüne Soße	13.0	10	0.0	0.0
11061	60	Camembert Pierrot	34.0	15	0.0	0.0
11062	53	Perth Pasties	32.8	10	0.2	65.6
11062	70	Outback Lager	15.0	12	0.2	36.0
11063	34	Sasquatch Ale	14.0	30	0.0	0.0
11063	40	Boston Crab Meat	18.4	40	0.1	73.6
11063	41	Jack's New England Clam Chowder	9.65	30	0.1	28.95
11064	17	Alice Mutton	39.0	77	0.1	300.3
11064	41	Jack's New England Clam Chowder	9.65	12	0.0	0.0
11064	53	Perth Pasties	32.8	25	0.1	82.0
11064	55	Pâté chinois	24.0	4	0.1	9.6
11064	68	Scottish Longbreads	12.5	55	0.0	0.0
11065	30	Nord-Ost Matjeshering	25.89	4	0.25	25.89
11065	54	Tourtière	7.45	20	0.25	37.25
11066	16	Pavlova	17.45	3	0.0	0.0
11066	19	Teatime Chocolate Biscuits	9.2	42	0.0	0.0
11066	34	Sasquatch Ale	14.0	35	0.0	0.0
11067	41	Jack's New England Clam Chowder	9.65	9	0.0	0.0
11068	28	Rössle Sauerkraut	45.6	8	0.15	54.72
11068	43	Ipoh Coffee	46.0	36	0.15	248.4
11068	77	Original Frankfurter grüne Soße	13.0	28	0.15	54.6
11069	39	Chartreuse verte	18.0	20	0.0	0.0
11070	1	Chai	18.0	40	0.15	108.0
11070	2	Chang	19.0	20	0.15	57.0
11070	16	Pavlova	17.45	30	0.15	78.52
11070	31	Gorgonzola Telino	12.5	20	0.0	0.0
11071	7	Uncle Bob's Organic Dried Pears	30.0	15	0.05	22.5
11071	13	Konbu	6.0	10	0.05	3.0
11072	2	Chang	19.0	8	0.0	0.0
11072	41	Jack's New England Clam Chowder	9.65	40	0.0	0.0
11072	50	Valkoinen suklaa	16.25	22	0.0	0.0
11072	64	Wimmers gute Semmelknödel	33.25	130	0.0	0.0
11073	11	Queso Cabrales	21.0	10	0.0	0.0
11073	24	Guaraná Fantástica	4.5	20	0.0	0.0
11074	16	Pavlova	17.45	14	0.05	12.21
11075	2	Chang	19.0	10	0.15	28.5
11075	46	Spegesild	12.0	30	0.15	54.0
11075	76	Lakkalikööri	18.0	2	0.15	5.4
11076	6	Grandma's Boysenberry Spread	25.0	20	0.25	125.0
11076	14	Tofu	23.25	20	0.25	116.25
11076	19	Teatime Chocolate Biscuits	9.2	10	0.25	23.0
11077	2	Chang	19.0	24	0.2	91.2
11077	3	Aniseed Syrup	10.0	4	0.0	0.0
11077	4	Chef Anton's Cajun Seasoning	22.0	1	0.0	0.0
11077	6	Grandma's Boysenberry Spread	25.0	1	0.02	0.5
11077	7	Uncle Bob's Organic Dried Pears	30.0	1	0.05	1.5
11077	8	Northwoods Cranberry Sauce	40.0	2	0.1	8.0
11077	10	Ikura	31.0	1	0.0	0.0
11077	12	Queso Manchego La Pastora	38.0	2	0.05	3.8
11077	13	Konbu	6.0	4	0.0	0.0
11077	14	Tofu	23.25	1	0.03	0.69
11077	16	Pavlova	17.45	2	0.03	1.04
11077	20	Sir Rodney's Marmalade	81.0	1	0.04	3.24
11077	23	Tunnbröd	9.0	2	0.0	0.0
11077	32	Mascarpone Fabioli	32.0	1	0.0	0.0
11077	39	Chartreuse verte	18.0	2	0.05	1.8
11077	41	Jack's New England Clam Chowder	9.65	3	0.0	0.0
11077	46	Spegesild	12.0	3	0.02	0.72
11077	52	Filo Mix	7.0	2	0.0	0.0
11077	55	Pâté chinois	24.0	2	0.0	0.0
11077	60	Camembert Pierrot	34.0	2	0.06	4.08
11077	64	Wimmers gute Semmelknödel	33.25	2	0.03	1.99
11077	66	Louisiana Hot Spiced Okra	17.0	1	0.0	0.0
11077	73	Röd Kaviar	15.0	2	0.01	0.3
11077	75	Rhönbräu Klosterbier	7.75	4	0.0	0.0
11077	77	Original Frankfurter grüne Soße	13.0	2	0.0	0.0
11079	1	Chai	18.0	5	0.0	0.0
11079	40	Boston Crab Meat	18.4	2	0.0	0.0
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (orderid, customerid, employeeid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry) FROM stdin;
10248	VINET	5	1994-08-04	1994-09-01	1994-08-16	3	32.38	Vins et alcools Chevalier	59 rue de l'Abbaye	Reims	\N	51100	France
10249	TOMSP	6	1994-08-05	1994-09-16	1994-08-10	1	11.61	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany
10250	HANAR	4	1994-08-08	1994-09-05	1994-08-12	2	65.83	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10251	VICTE	3	1994-08-08	1994-09-05	1994-08-15	1	41.34	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10252	SUPRD	4	1994-08-09	1994-09-06	1994-08-11	2	51.3	Suprêmes délices	2 rue du Commerce	Charleroi	\N	B-6000	Belgium
10253	HANAR	3	1994-08-10	1994-08-24	1994-08-16	2	58.17	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10254	CHOPS	5	1994-08-11	1994-09-08	1994-08-23	2	22.98	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland
10255	RICSU	9	1994-08-12	1994-09-09	1994-08-15	3	148.33	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
10256	WELLI	3	1994-08-15	1994-09-12	1994-08-17	2	13.97	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10257	HILAA	4	1994-08-16	1994-09-13	1994-08-22	3	81.91	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10258	ERNSH	1	1994-08-17	1994-09-14	1994-08-23	1	140.51	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10259	CENTC	4	1994-08-18	1994-09-15	1994-08-25	3	3.25	Centro comercial Moctezuma	Sierras de Granada 9993	México D.F.	\N	5022	Mexico
10260	OTTIK	4	1994-08-19	1994-09-16	1994-08-29	1	55.09	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
10261	QUEDE	4	1994-08-19	1994-09-16	1994-08-30	2	3.05	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10262	RATTC	8	1994-08-22	1994-09-19	1994-08-25	3	48.29	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10263	ERNSH	9	1994-08-23	1994-09-20	1994-08-31	3	146.06	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10264	FOLKO	6	1994-08-24	1994-09-21	1994-09-23	3	3.67	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10265	BLONP	2	1994-08-25	1994-09-22	1994-09-12	1	55.28	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10266	WARTH	3	1994-08-26	1994-10-07	1994-08-31	3	25.73	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10267	FRANK	4	1994-08-29	1994-09-26	1994-09-06	1	208.58	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10268	GROSR	8	1994-08-30	1994-09-27	1994-09-02	3	66.29	GROSELLA-Restaurante	5ª Ave. Los Palos Grandes	Caracas	DF	1081	Venezuela
10269	WHITC	5	1994-08-31	1994-09-14	1994-09-09	1	4.56	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10270	WARTH	1	1994-09-01	1994-09-29	1994-09-02	1	136.54	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10271	SPLIR	6	1994-09-01	1994-09-29	1994-09-30	2	4.54	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10272	RATTC	6	1994-09-02	1994-09-30	1994-09-06	2	98.03	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10273	QUICK	3	1994-09-05	1994-10-03	1994-09-12	3	76.07	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10274	VINET	6	1994-09-06	1994-10-04	1994-09-16	1	6.01	Vins et alcools Chevalier	59 rue de l'Abbaye	Reims	\N	51100	France
10275	MAGAA	1	1994-09-07	1994-10-05	1994-09-09	1	26.93	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10276	TORTU	8	1994-09-08	1994-09-22	1994-09-14	3	13.84	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10277	MORGK	2	1994-09-09	1994-10-07	1994-09-13	3	125.77	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany
10278	BERGS	8	1994-09-12	1994-10-10	1994-09-16	2	92.69	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10279	LEHMS	8	1994-09-13	1994-10-11	1994-09-16	2	25.83	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10280	BERGS	2	1994-09-14	1994-10-12	1994-10-13	1	8.98	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10281	ROMEY	4	1994-09-14	1994-09-28	1994-09-21	1	2.94	Romero y tomillo	Gran Vía 1	Madrid	\N	28001	Spain
10282	ROMEY	4	1994-09-15	1994-10-13	1994-09-21	1	12.69	Romero y tomillo	Gran Vía 1	Madrid	\N	28001	Spain
10283	LILAS	3	1994-09-16	1994-10-14	1994-09-23	3	84.81	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10284	LEHMS	4	1994-09-19	1994-10-17	1994-09-27	1	76.56	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10285	QUICK	1	1994-09-20	1994-10-18	1994-09-26	2	76.83	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10286	QUICK	8	1994-09-21	1994-10-19	1994-09-30	3	229.24	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10287	RICAR	8	1994-09-22	1994-10-20	1994-09-28	3	12.76	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10288	REGGC	4	1994-09-23	1994-10-21	1994-10-04	1	7.45	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10289	BSBEV	7	1994-09-26	1994-10-24	1994-09-28	3	22.77	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10290	COMMI	8	1994-09-27	1994-10-25	1994-10-04	1	79.7	Comércio Mineiro	Av. dos Lusíadas 23	São Paulo	SP	05432-043	Brazil
10291	QUEDE	6	1994-09-27	1994-10-25	1994-10-05	2	6.4	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10292	TRADH	1	1994-09-28	1994-10-26	1994-10-03	2	1.35	Tradição Hipermercados	Av. Inês de Castro 414	São Paulo	SP	05634-030	Brazil
10293	TORTU	1	1994-09-29	1994-10-27	1994-10-12	3	21.18	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10294	RATTC	4	1994-09-30	1994-10-28	1994-10-06	2	147.26	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10295	VINET	2	1994-10-03	1994-10-31	1994-10-11	2	1.15	Vins et alcools Chevalier	59 rue de l'Abbaye	Reims	\N	51100	France
10296	LILAS	6	1994-10-04	1994-11-01	1994-10-12	1	0.12	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10297	BLONP	5	1994-10-05	1994-11-16	1994-10-11	2	5.74	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10298	HUNGO	6	1994-10-06	1994-11-03	1994-10-12	2	168.22	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10299	RICAR	4	1994-10-07	1994-11-04	1994-10-14	2	29.76	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10300	MAGAA	2	1994-10-10	1994-11-07	1994-10-19	2	17.68	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10301	MAGAA	8	1994-10-10	1994-11-07	1994-10-18	2	17.68	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10302	SUPRD	4	1994-10-11	1994-11-08	1994-11-09	2	6.27	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10303	GODOS	7	1994-10-12	1994-11-09	1994-10-19	2	107.83	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
10304	TORTU	1	1994-10-13	1994-11-10	1994-10-18	2	63.79	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10305	OLDWO	8	1994-10-14	1994-11-11	1994-11-09	3	257.62	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10306	ROMEY	1	1994-10-17	1994-11-14	1994-10-24	3	7.56	Romero y tomillo	Gran Vía 1	Madrid	\N	28001	Spain
10307	LONEP	2	1994-10-18	1994-11-15	1994-10-26	2	0.56	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA
10308	ANATR	7	1994-10-19	1994-11-16	1994-10-25	3	1.61	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	México D.F.	\N	5021	Mexico
10309	HUNGO	3	1994-10-20	1994-11-17	1994-11-23	1	47.3	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10310	THEBI	8	1994-10-21	1994-11-18	1994-10-28	2	17.52	The Big Cheese	89 Jefferson WaySuite 2	Portland	OR	97201	USA
10311	DUMON	1	1994-10-21	1994-11-04	1994-10-27	3	24.69	Du monde entier	67 rue des Cinquante Otages	Nantes	\N	44000	France
10312	WANDK	2	1994-10-24	1994-11-21	1994-11-03	2	40.26	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10313	QUICK	2	1994-10-25	1994-11-22	1994-11-04	2	1.96	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10314	RATTC	1	1994-10-26	1994-11-23	1994-11-04	2	74.16	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10315	ISLAT	4	1994-10-27	1994-11-24	1994-11-03	2	41.76	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10316	RATTC	1	1994-10-28	1994-11-25	1994-11-08	3	150.15	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10317	LONEP	6	1994-10-31	1994-11-28	1994-11-10	1	12.69	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA
10318	ISLAT	8	1994-11-01	1994-11-29	1994-11-04	2	4.73	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10319	TORTU	7	1994-11-02	1994-11-30	1994-11-11	3	64.5	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10320	WARTH	5	1994-11-03	1994-11-17	1994-11-18	3	34.57	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10321	ISLAT	3	1994-11-03	1994-12-01	1994-11-11	2	3.43	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10322	PERIC	7	1994-11-04	1994-12-02	1994-11-23	3	0.4	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico
10323	KOENE	4	1994-11-07	1994-12-05	1994-11-14	1	4.88	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10324	SAVEA	9	1994-11-08	1994-12-06	1994-11-10	1	214.27	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10325	KOENE	1	1994-11-09	1994-11-23	1994-11-14	3	64.86	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10326	BOLID	4	1994-11-10	1994-12-08	1994-11-14	2	77.92	Bólido Comidas preparadas	C/ Araquil 67	Madrid	\N	28023	Spain
10327	FOLKO	2	1994-11-11	1994-12-09	1994-11-14	1	63.36	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10328	FURIB	4	1994-11-14	1994-12-12	1994-11-17	3	87.03	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal
10329	SPLIR	4	1994-11-15	1994-12-27	1994-11-23	2	191.67	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10330	LILAS	3	1994-11-16	1994-12-14	1994-11-28	1	12.75	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10331	BONAP	9	1994-11-16	1994-12-28	1994-11-21	1	10.19	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10332	MEREP	3	1994-11-17	1994-12-29	1994-11-21	2	52.84	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10333	WARTH	5	1994-11-18	1994-12-16	1994-11-25	3	0.59	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10334	VICTE	8	1994-11-21	1994-12-19	1994-11-28	2	8.56	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10335	HUNGO	7	1994-11-22	1994-12-20	1994-11-24	2	42.11	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10336	PRINI	7	1994-11-23	1994-12-21	1994-11-25	2	15.51	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal
10337	FRANK	4	1994-11-24	1994-12-22	1994-11-29	3	108.26	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10338	OLDWO	4	1994-11-25	1994-12-23	1994-11-29	3	84.21	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10339	MEREP	2	1994-11-28	1994-12-26	1994-12-05	2	15.66	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10340	BONAP	1	1994-11-29	1994-12-27	1994-12-09	3	166.31	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10341	SIMOB	7	1994-11-29	1994-12-27	1994-12-06	3	26.78	Simons bistro	Vinbæltet 34	København	\N	1734	Denmark
10342	FRANK	4	1994-11-30	1994-12-14	1994-12-05	2	54.83	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10343	LEHMS	4	1994-12-01	1994-12-29	1994-12-07	1	110.37	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10344	WHITC	4	1994-12-02	1994-12-30	1994-12-06	2	23.29	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10345	QUICK	2	1994-12-05	1995-01-02	1994-12-12	2	249.06	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10346	RATTC	3	1994-12-06	1995-01-17	1994-12-09	3	142.08	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10347	FAMIA	4	1994-12-07	1995-01-04	1994-12-09	3	3.1	Familia Arquibaldo	Rua Orós 92	São Paulo	SP	05442-030	Brazil
10348	WANDK	4	1994-12-08	1995-01-05	1994-12-16	2	0.78	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10349	SPLIR	7	1994-12-09	1995-01-06	1994-12-16	1	8.63	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10350	LAMAI	6	1994-12-12	1995-01-09	1995-01-03	2	64.19	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10351	ERNSH	1	1994-12-12	1995-01-09	1994-12-21	1	162.33	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10352	FURIB	3	1994-12-13	1994-12-27	1994-12-19	3	1.3	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal
10353	PICCO	7	1994-12-14	1995-01-11	1994-12-26	3	360.63	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10354	PERIC	8	1994-12-15	1995-01-12	1994-12-21	3	53.8	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico
10355	AROUT	6	1994-12-16	1995-01-13	1994-12-21	1	41.95	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10356	WANDK	6	1994-12-19	1995-01-16	1994-12-28	2	36.71	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10357	LILAS	1	1994-12-20	1995-01-17	1995-01-02	3	34.88	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10358	LAMAI	5	1994-12-21	1995-01-18	1994-12-28	1	19.64	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10359	SEVES	5	1994-12-22	1995-01-19	1994-12-27	3	288.43	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10360	BLONP	4	1994-12-23	1995-01-20	1995-01-02	3	131.7	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10361	QUICK	1	1994-12-23	1995-01-20	1995-01-03	2	183.17	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10362	BONAP	3	1994-12-26	1995-01-23	1994-12-29	1	96.04	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10363	DRACD	4	1994-12-27	1995-01-24	1995-01-04	3	30.54	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany
10364	EASTC	1	1994-12-27	1995-02-07	1995-01-04	1	71.97	Eastern Connection	35 King George	London	\N	WX3 6FW	UK
10365	ANTON	3	1994-12-28	1995-01-25	1995-01-02	2	22.0	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico
10366	GALED	8	1994-12-29	1995-02-09	1995-01-30	2	10.14	Galería del gastronómo	Rambla de Cataluña 23	Barcelona	\N	8022	Spain
10367	VAFFE	7	1994-12-29	1995-01-26	1995-01-02	3	13.55	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10368	ERNSH	2	1994-12-30	1995-01-27	1995-01-02	2	101.95	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10369	SPLIR	8	1995-01-02	1995-01-30	1995-01-09	2	195.68	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10370	CHOPS	6	1995-01-03	1995-01-31	1995-01-27	2	1.17	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland
10371	LAMAI	1	1995-01-03	1995-01-31	1995-01-24	1	0.45	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10372	QUEEN	5	1995-01-04	1995-02-01	1995-01-09	2	890.78	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10373	HUNGO	4	1995-01-05	1995-02-02	1995-01-11	3	124.12	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10374	WOLZA	1	1995-01-05	1995-02-02	1995-01-09	3	3.94	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland
10375	HUNGC	3	1995-01-06	1995-02-03	1995-01-09	2	20.12	Hungry Coyote Import Store	City Center Plaza516 Main St.	Elgin	OR	97827	USA
10376	MEREP	1	1995-01-09	1995-02-06	1995-01-13	2	20.39	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10377	SEVES	1	1995-01-09	1995-02-06	1995-01-13	3	22.21	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10378	FOLKO	5	1995-01-10	1995-02-07	1995-01-19	3	5.44	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10379	QUEDE	2	1995-01-11	1995-02-08	1995-01-13	1	45.03	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10380	HUNGO	8	1995-01-12	1995-02-09	1995-02-16	3	35.03	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10381	LILAS	3	1995-01-12	1995-02-09	1995-01-13	3	7.99	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10382	ERNSH	4	1995-01-13	1995-02-10	1995-01-16	1	94.77	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10383	AROUT	8	1995-01-16	1995-02-13	1995-01-18	3	34.24	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10384	BERGS	3	1995-01-16	1995-02-13	1995-01-20	3	168.64	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10385	SPLIR	1	1995-01-17	1995-02-14	1995-01-23	2	30.96	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10386	FAMIA	9	1995-01-18	1995-02-01	1995-01-25	3	13.99	Familia Arquibaldo	Rua Orós 92	São Paulo	SP	05442-030	Brazil
10387	SANTG	1	1995-01-18	1995-02-15	1995-01-20	2	93.63	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway
10388	SEVES	2	1995-01-19	1995-02-16	1995-01-20	1	34.86	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10389	BOTTM	4	1995-01-20	1995-02-17	1995-01-24	2	47.42	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10390	ERNSH	6	1995-01-23	1995-02-20	1995-01-26	1	126.38	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10391	DRACD	3	1995-01-23	1995-02-20	1995-01-31	3	5.45	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany
10392	PICCO	2	1995-01-24	1995-02-21	1995-02-01	3	122.46	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10393	SAVEA	1	1995-01-25	1995-02-22	1995-02-03	3	126.56	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10394	HUNGC	1	1995-01-25	1995-02-22	1995-02-03	3	30.34	Hungry Coyote Import Store	City Center Plaza516 Main St.	Elgin	OR	97827	USA
10395	HILAA	6	1995-01-26	1995-02-23	1995-02-03	1	184.41	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10396	FRANK	1	1995-01-27	1995-02-10	1995-02-06	3	135.35	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10397	PRINI	5	1995-01-27	1995-02-24	1995-02-02	1	60.26	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal
10398	SAVEA	2	1995-01-30	1995-02-27	1995-02-09	3	89.16	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10399	VAFFE	8	1995-01-31	1995-02-14	1995-02-08	3	27.36	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10400	EASTC	1	1995-02-01	1995-03-01	1995-02-16	3	83.93	Eastern Connection	35 King George	London	\N	WX3 6FW	UK
10401	RATTC	1	1995-02-01	1995-03-01	1995-02-10	1	12.51	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10402	ERNSH	8	1995-02-02	1995-03-16	1995-02-10	2	67.88	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10403	ERNSH	4	1995-02-03	1995-03-03	1995-02-09	3	73.79	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10404	MAGAA	2	1995-02-03	1995-03-03	1995-02-08	1	155.97	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10405	LINOD	1	1995-02-06	1995-03-06	1995-02-22	1	34.82	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10406	QUEEN	7	1995-02-07	1995-03-21	1995-02-13	1	108.04	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10407	OTTIK	2	1995-02-07	1995-03-07	1995-03-02	2	91.48	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
10408	FOLIG	8	1995-02-08	1995-03-08	1995-02-14	1	11.26	Folies gourmandes	184 chaussée de Tournai	Lille	\N	59000	France
10409	OCEAN	3	1995-02-09	1995-03-09	1995-02-14	1	29.83	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585Piso 20-A	Buenos Aires	\N	1010	Argentina
10410	BOTTM	3	1995-02-10	1995-03-10	1995-02-15	3	2.4	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10411	BOTTM	9	1995-02-10	1995-03-10	1995-02-21	3	23.65	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10412	WARTH	8	1995-02-13	1995-03-13	1995-02-15	2	3.77	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10413	LAMAI	3	1995-02-14	1995-03-14	1995-02-16	2	95.66	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10414	FAMIA	2	1995-02-14	1995-03-14	1995-02-17	3	21.48	Familia Arquibaldo	Rua Orós 92	São Paulo	SP	05442-030	Brazil
10415	HUNGC	3	1995-02-15	1995-03-15	1995-02-24	1	0.2	Hungry Coyote Import Store	City Center Plaza516 Main St.	Elgin	OR	97827	USA
10416	WARTH	8	1995-02-16	1995-03-16	1995-02-27	3	22.72	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10417	SIMOB	4	1995-02-16	1995-03-16	1995-02-28	3	70.29	Simons bistro	Vinbæltet 34	København	\N	1734	Denmark
10418	QUICK	4	1995-02-17	1995-03-17	1995-02-24	1	17.55	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10419	RICSU	4	1995-02-20	1995-03-20	1995-03-02	2	137.35	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
10420	WELLI	3	1995-02-21	1995-03-21	1995-02-27	1	44.12	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10421	QUEDE	8	1995-02-21	1995-04-04	1995-02-27	1	99.23	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10422	FRANS	2	1995-02-22	1995-03-22	1995-03-03	1	3.02	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy
10423	GOURL	6	1995-02-23	1995-03-09	1995-03-27	3	24.5	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
10424	MEREP	7	1995-02-23	1995-03-23	1995-02-27	2	370.61	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10425	LAMAI	6	1995-02-24	1995-03-24	1995-03-17	2	7.93	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10426	GALED	4	1995-02-27	1995-03-27	1995-03-09	1	18.69	Galería del gastronómo	Rambla de Cataluña 23	Barcelona	\N	8022	Spain
10427	PICCO	4	1995-02-27	1995-03-27	1995-04-03	2	31.29	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10428	REGGC	7	1995-02-28	1995-03-28	1995-03-07	1	11.09	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10429	HUNGO	3	1995-03-01	1995-04-12	1995-03-10	2	56.63	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10430	ERNSH	4	1995-03-02	1995-03-16	1995-03-06	1	458.78	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10431	BOTTM	4	1995-03-02	1995-03-16	1995-03-10	2	44.17	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10432	SPLIR	3	1995-03-03	1995-03-17	1995-03-10	2	4.34	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10433	PRINI	3	1995-03-06	1995-04-03	1995-04-04	3	73.83	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal
10434	FOLKO	3	1995-03-06	1995-04-03	1995-03-16	2	17.92	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10435	CONSH	8	1995-03-07	1995-04-18	1995-03-10	2	9.21	Consolidated Holdings	Berkeley Gardens12  Brewery	London	\N	WX1 6LT	UK
10436	BLONP	3	1995-03-08	1995-04-05	1995-03-14	2	156.66	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10437	WARTH	8	1995-03-08	1995-04-05	1995-03-15	1	19.97	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10438	TOMSP	3	1995-03-09	1995-04-06	1995-03-17	2	8.24	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany
10439	MEREP	6	1995-03-10	1995-04-07	1995-03-13	3	4.07	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10440	SAVEA	4	1995-03-13	1995-04-10	1995-03-31	2	86.53	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10441	OLDWO	3	1995-03-13	1995-04-24	1995-04-14	2	73.02	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10442	ERNSH	3	1995-03-14	1995-04-11	1995-03-21	2	47.94	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10443	REGGC	8	1995-03-15	1995-04-12	1995-03-17	1	13.95	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10444	BERGS	3	1995-03-15	1995-04-12	1995-03-24	3	3.5	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10445	BERGS	3	1995-03-16	1995-04-13	1995-03-23	1	9.3	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10446	TOMSP	6	1995-03-17	1995-04-14	1995-03-22	1	14.68	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany
10447	RICAR	4	1995-03-17	1995-04-14	1995-04-07	2	68.66	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10448	RANCH	4	1995-03-20	1995-04-17	1995-03-27	2	38.82	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina
10449	BLONP	3	1995-03-21	1995-04-18	1995-03-30	2	53.3	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10450	VICTE	8	1995-03-22	1995-04-19	1995-04-11	2	7.23	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10451	QUICK	4	1995-03-22	1995-04-05	1995-04-12	3	189.09	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10452	SAVEA	8	1995-03-23	1995-04-20	1995-03-29	1	140.26	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10453	AROUT	1	1995-03-24	1995-04-21	1995-03-29	2	25.36	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10454	LAMAI	4	1995-03-24	1995-04-21	1995-03-28	3	2.74	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10455	WARTH	8	1995-03-27	1995-05-08	1995-04-03	2	180.45	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10456	KOENE	8	1995-03-28	1995-05-09	1995-03-31	2	8.12	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10457	KOENE	2	1995-03-28	1995-04-25	1995-04-03	1	11.57	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10458	SUPRD	7	1995-03-29	1995-04-26	1995-04-04	3	147.06	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10459	VICTE	4	1995-03-30	1995-04-27	1995-03-31	2	25.09	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10460	FOLKO	8	1995-03-31	1995-04-28	1995-04-03	1	16.27	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10461	LILAS	1	1995-03-31	1995-04-28	1995-04-05	3	148.61	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10462	CONSH	2	1995-04-03	1995-05-01	1995-04-18	1	6.17	Consolidated Holdings	Berkeley Gardens12  Brewery	London	\N	WX1 6LT	UK
10463	SUPRD	5	1995-04-04	1995-05-02	1995-04-06	3	14.78	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10464	FURIB	4	1995-04-04	1995-05-02	1995-04-14	2	89.0	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal
10465	VAFFE	1	1995-04-05	1995-05-03	1995-04-14	3	145.04	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10466	COMMI	4	1995-04-06	1995-05-04	1995-04-13	1	11.93	Comércio Mineiro	Av. dos Lusíadas 23	São Paulo	SP	05432-043	Brazil
10467	MAGAA	8	1995-04-06	1995-05-04	1995-04-11	2	4.93	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10468	KOENE	3	1995-04-07	1995-05-05	1995-04-12	3	44.12	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10469	WHITC	1	1995-04-10	1995-05-08	1995-04-14	1	60.18	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10470	BONAP	4	1995-04-11	1995-05-09	1995-04-14	2	64.56	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10471	BSBEV	2	1995-04-11	1995-05-09	1995-04-18	3	45.59	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10472	SEVES	8	1995-04-12	1995-05-10	1995-04-19	1	4.2	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10473	ISLAT	1	1995-04-13	1995-04-27	1995-04-21	3	16.37	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10474	PERIC	5	1995-04-13	1995-05-11	1995-04-21	2	83.49	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico
10475	SUPRD	9	1995-04-14	1995-05-12	1995-05-05	1	68.52	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10476	HILAA	8	1995-04-17	1995-05-15	1995-04-24	3	4.41	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10477	PRINI	5	1995-04-17	1995-05-15	1995-04-25	2	13.02	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal
10478	VICTE	2	1995-04-18	1995-05-02	1995-04-26	3	4.81	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10479	RATTC	3	1995-04-19	1995-05-17	1995-04-21	3	708.95	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10480	FOLIG	6	1995-04-20	1995-05-18	1995-04-24	2	1.35	Folies gourmandes	184 chaussée de Tournai	Lille	\N	59000	France
10481	RICAR	8	1995-04-20	1995-05-18	1995-04-25	2	64.33	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10482	LAZYK	1	1995-04-21	1995-05-19	1995-05-11	3	7.48	Lazy K Kountry Store	12 Orchestra Terrace	Walla Walla	WA	99362	USA
10483	WHITC	7	1995-04-24	1995-05-22	1995-05-26	2	15.28	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10484	BSBEV	3	1995-04-24	1995-05-22	1995-05-02	3	6.88	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10485	LINOD	4	1995-04-25	1995-05-09	1995-05-01	2	64.45	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10486	HILAA	1	1995-04-26	1995-05-24	1995-05-03	2	30.53	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10487	QUEEN	2	1995-04-26	1995-05-24	1995-04-28	2	71.07	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10488	FRANK	8	1995-04-27	1995-05-25	1995-05-03	2	4.93	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10489	PICCO	6	1995-04-28	1995-05-26	1995-05-10	2	5.29	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10490	HILAA	7	1995-05-01	1995-05-29	1995-05-04	2	210.19	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10491	FURIB	8	1995-05-01	1995-05-29	1995-05-09	3	16.96	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal
10492	BOTTM	3	1995-05-02	1995-05-30	1995-05-12	1	62.89	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10493	LAMAI	4	1995-05-03	1995-05-31	1995-05-11	3	10.64	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10494	COMMI	4	1995-05-03	1995-05-31	1995-05-10	2	65.99	Comércio Mineiro	Av. dos Lusíadas 23	São Paulo	SP	05432-043	Brazil
10495	LAUGB	3	1995-05-04	1995-06-01	1995-05-12	3	4.65	Laughing Bacchus Wine Cellars	2319 Elm St.	Vancouver	BC	V3F 2K1	Canada
10496	TRADH	7	1995-05-05	1995-06-02	1995-05-08	2	46.77	Tradição Hipermercados	Av. Inês de Castro 414	São Paulo	SP	05634-030	Brazil
10497	LEHMS	7	1995-05-05	1995-06-02	1995-05-08	1	36.21	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10498	HILAA	8	1995-05-08	1995-06-05	1995-05-12	2	29.75	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10499	LILAS	4	1995-05-09	1995-06-06	1995-05-17	2	102.02	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10500	LAMAI	6	1995-05-10	1995-06-07	1995-05-18	1	42.68	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10501	BLAUS	9	1995-05-10	1995-06-07	1995-05-17	3	8.85	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany
10502	PERIC	2	1995-05-11	1995-06-08	1995-05-30	1	69.32	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico
10503	HUNGO	6	1995-05-12	1995-06-09	1995-05-17	2	16.74	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10504	WHITC	4	1995-05-12	1995-06-09	1995-05-19	3	59.13	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10505	MEREP	3	1995-05-15	1995-06-12	1995-05-22	3	7.13	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10506	KOENE	9	1995-05-16	1995-06-13	1995-06-02	2	21.19	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10507	ANTON	7	1995-05-16	1995-06-13	1995-05-23	1	47.45	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico
10508	OTTIK	1	1995-05-17	1995-06-14	1995-06-13	2	4.99	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
10509	BLAUS	4	1995-05-18	1995-06-15	1995-05-30	1	0.15	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany
10510	SAVEA	6	1995-05-19	1995-06-16	1995-05-29	3	367.63	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10511	BONAP	4	1995-05-19	1995-06-16	1995-05-22	3	350.64	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10512	FAMIA	7	1995-05-22	1995-06-19	1995-05-25	2	3.53	Familia Arquibaldo	Rua Orós 92	São Paulo	SP	05442-030	Brazil
10513	WANDK	7	1995-05-23	1995-07-04	1995-05-29	1	105.65	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10514	ERNSH	3	1995-05-23	1995-06-20	1995-06-16	2	789.95	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10515	QUICK	2	1995-05-24	1995-06-07	1995-06-23	1	204.47	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10516	HUNGO	2	1995-05-25	1995-06-22	1995-06-01	3	62.78	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10517	NORTS	3	1995-05-25	1995-06-22	1995-05-30	3	32.07	North/South	South House300 Queensbridge	London	\N	SW7 1RZ	UK
10518	TORTU	4	1995-05-26	1995-06-09	1995-06-05	2	218.15	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10519	CHOPS	6	1995-05-29	1995-06-26	1995-06-01	3	91.76	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland
10520	SANTG	7	1995-05-30	1995-06-27	1995-06-01	1	13.37	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway
10521	CACTU	8	1995-05-30	1995-06-27	1995-06-02	2	17.22	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina
10522	LEHMS	4	1995-05-31	1995-06-28	1995-06-06	1	45.33	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10523	SEVES	7	1995-06-01	1995-06-29	1995-06-30	2	77.63	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10524	BERGS	1	1995-06-01	1995-06-29	1995-06-07	2	244.79	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10525	BONAP	1	1995-06-02	1995-06-30	1995-06-23	2	11.06	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10526	WARTH	4	1995-06-05	1995-07-03	1995-06-15	2	58.59	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10527	QUICK	7	1995-06-05	1995-07-03	1995-06-07	1	41.9	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10528	GREAL	6	1995-06-06	1995-06-20	1995-06-09	2	3.35	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
10529	MAISD	5	1995-06-07	1995-07-05	1995-06-09	2	66.69	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium
10530	PICCO	3	1995-06-08	1995-07-06	1995-06-12	2	339.22	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10531	OCEAN	7	1995-06-08	1995-07-06	1995-06-19	1	8.12	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585Piso 20-A	Buenos Aires	\N	1010	Argentina
10532	EASTC	7	1995-06-09	1995-07-07	1995-06-12	3	74.46	Eastern Connection	35 King George	London	\N	WX3 6FW	UK
10533	FOLKO	8	1995-06-12	1995-07-10	1995-06-22	1	188.04	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10534	LEHMS	8	1995-06-12	1995-07-10	1995-06-14	2	27.94	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10535	ANTON	4	1995-06-13	1995-07-11	1995-06-21	1	15.64	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico
10536	LEHMS	3	1995-06-14	1995-07-12	1995-07-07	2	58.88	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10537	RICSU	1	1995-06-14	1995-06-28	1995-06-19	1	78.85	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
10538	BSBEV	9	1995-06-15	1995-07-13	1995-06-16	3	4.87	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10539	BSBEV	6	1995-06-16	1995-07-14	1995-06-23	3	12.36	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10540	QUICK	3	1995-06-19	1995-07-17	1995-07-14	3	1007.64	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10541	HANAR	2	1995-06-19	1995-07-17	1995-06-29	1	68.65	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10542	KOENE	1	1995-06-20	1995-07-18	1995-06-26	3	10.95	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10543	LILAS	8	1995-06-21	1995-07-19	1995-06-23	2	48.17	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10544	LONEP	4	1995-06-21	1995-07-19	1995-06-30	1	24.91	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA
10545	LAZYK	8	1995-06-22	1995-07-20	1995-07-27	2	11.92	Lazy K Kountry Store	12 Orchestra Terrace	Walla Walla	WA	99362	USA
10546	VICTE	1	1995-06-23	1995-07-21	1995-06-27	3	194.72	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10547	SEVES	3	1995-06-23	1995-07-21	1995-07-03	2	178.43	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10548	TOMSP	3	1995-06-26	1995-07-24	1995-07-03	2	1.43	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany
10549	QUICK	5	1995-06-27	1995-07-11	1995-06-30	1	171.24	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10550	GODOS	7	1995-06-28	1995-07-26	1995-07-07	3	4.32	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
10551	FURIB	4	1995-06-28	1995-08-09	1995-07-07	3	72.95	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal
10552	HILAA	2	1995-06-29	1995-07-27	1995-07-06	1	83.22	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10553	WARTH	2	1995-06-30	1995-07-28	1995-07-04	2	149.49	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10554	OTTIK	4	1995-06-30	1995-07-28	1995-07-06	3	120.97	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
10555	SAVEA	6	1995-07-03	1995-07-31	1995-07-05	3	252.49	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10556	SIMOB	2	1995-07-04	1995-08-15	1995-07-14	1	9.8	Simons bistro	Vinbæltet 34	København	\N	1734	Denmark
10557	LEHMS	9	1995-07-04	1995-07-18	1995-07-07	2	96.72	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10558	AROUT	1	1995-07-05	1995-08-02	1995-07-11	2	72.97	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10559	BLONP	6	1995-07-06	1995-08-03	1995-07-14	1	8.05	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10560	FRANK	8	1995-07-07	1995-08-04	1995-07-10	1	36.65	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10561	FOLKO	2	1995-07-07	1995-08-04	1995-07-10	2	242.21	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10562	REGGC	1	1995-07-10	1995-08-07	1995-07-13	1	22.95	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10563	RICAR	2	1995-07-11	1995-08-22	1995-07-25	2	60.43	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10564	RATTC	4	1995-07-11	1995-08-08	1995-07-17	3	13.75	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10565	MEREP	8	1995-07-12	1995-08-09	1995-07-19	2	7.15	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10566	BLONP	9	1995-07-13	1995-08-10	1995-07-19	1	88.4	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10567	HUNGO	1	1995-07-13	1995-08-10	1995-07-18	1	33.97	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10568	GALED	3	1995-07-14	1995-08-11	1995-08-09	3	6.54	Galería del gastronómo	Rambla de Cataluña 23	Barcelona	\N	8022	Spain
10569	RATTC	5	1995-07-17	1995-08-14	1995-08-11	1	58.98	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10570	MEREP	3	1995-07-18	1995-08-15	1995-07-20	3	188.99	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10571	ERNSH	8	1995-07-18	1995-08-29	1995-08-04	3	26.06	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10572	BERGS	3	1995-07-19	1995-08-16	1995-07-26	2	116.43	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10573	ANTON	7	1995-07-20	1995-08-17	1995-07-21	3	84.84	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico
10574	TRAIH	4	1995-07-20	1995-08-17	1995-07-31	2	37.6	Trail's Head Gourmet Provisioners	722 DaVinci Blvd.	Kirkland	WA	98034	USA
10575	MORGK	5	1995-07-21	1995-08-04	1995-07-31	1	127.34	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany
10576	TORTU	3	1995-07-24	1995-08-07	1995-07-31	3	18.56	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10577	TRAIH	9	1995-07-24	1995-09-04	1995-07-31	2	25.41	Trail's Head Gourmet Provisioners	722 DaVinci Blvd.	Kirkland	WA	98034	USA
10578	BSBEV	4	1995-07-25	1995-08-22	1995-08-25	3	29.6	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10579	LETSS	1	1995-07-26	1995-08-23	1995-08-04	2	13.73	Let's Stop N Shop	87 Polk St.Suite 5	San Francisco	CA	94117	USA
10580	OTTIK	4	1995-07-27	1995-08-24	1995-08-01	3	75.89	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
10581	FAMIA	3	1995-07-27	1995-08-24	1995-08-02	1	3.01	Familia Arquibaldo	Rua Orós 92	São Paulo	SP	05442-030	Brazil
10582	BLAUS	3	1995-07-28	1995-08-25	1995-08-14	2	27.71	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany
10583	WARTH	2	1995-07-31	1995-08-28	1995-08-04	2	7.28	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10584	BLONP	4	1995-07-31	1995-08-28	1995-08-04	1	59.14	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10585	WELLI	7	1995-08-01	1995-08-29	1995-08-10	1	13.41	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10586	REGGC	9	1995-08-02	1995-08-30	1995-08-09	1	0.48	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10587	QUEDE	1	1995-08-02	1995-08-30	1995-08-09	1	62.52	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10588	QUICK	2	1995-08-03	1995-08-31	1995-08-10	3	194.67	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10589	GREAL	8	1995-08-04	1995-09-01	1995-08-14	2	4.42	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
10590	MEREP	4	1995-08-07	1995-09-04	1995-08-14	3	44.77	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10591	VAFFE	1	1995-08-07	1995-08-21	1995-08-16	1	55.92	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10592	LEHMS	3	1995-08-08	1995-09-05	1995-08-16	1	32.1	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10593	LEHMS	7	1995-08-09	1995-09-06	1995-09-13	2	174.2	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10594	OLDWO	3	1995-08-09	1995-09-06	1995-08-16	2	5.24	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10595	ERNSH	2	1995-08-10	1995-09-07	1995-08-14	1	96.78	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10596	WHITC	8	1995-08-11	1995-09-08	1995-09-12	1	16.34	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10597	PICCO	7	1995-08-11	1995-09-08	1995-08-18	3	35.12	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10598	RATTC	1	1995-08-14	1995-09-11	1995-08-18	3	44.42	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10599	BSBEV	6	1995-08-15	1995-09-26	1995-08-21	3	29.98	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10600	HUNGC	4	1995-08-16	1995-09-13	1995-08-21	1	45.13	Hungry Coyote Import Store	City Center Plaza516 Main St.	Elgin	OR	97827	USA
10601	HILAA	7	1995-08-16	1995-09-27	1995-08-22	1	58.3	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10602	VAFFE	8	1995-08-17	1995-09-14	1995-08-22	2	2.92	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10603	SAVEA	8	1995-08-18	1995-09-15	1995-09-08	2	48.77	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10604	FURIB	1	1995-08-18	1995-09-15	1995-08-29	1	7.46	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal
10605	MEREP	1	1995-08-21	1995-09-18	1995-08-29	2	379.13	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10606	TRADH	4	1995-08-22	1995-09-19	1995-08-31	3	79.4	Tradição Hipermercados	Av. Inês de Castro 414	São Paulo	SP	05634-030	Brazil
10607	SAVEA	5	1995-08-22	1995-09-19	1995-08-25	1	200.24	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10608	TOMSP	4	1995-08-23	1995-09-20	1995-09-01	2	27.79	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany
10609	DUMON	7	1995-08-24	1995-09-21	1995-08-30	2	1.85	Du monde entier	67 rue des Cinquante Otages	Nantes	\N	44000	France
10610	LAMAI	8	1995-08-25	1995-09-22	1995-09-06	1	26.78	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10611	WOLZA	6	1995-08-25	1995-09-22	1995-09-01	2	80.65	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland
10612	SAVEA	1	1995-08-28	1995-09-25	1995-09-01	2	544.08	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10613	HILAA	4	1995-08-29	1995-09-26	1995-09-01	2	8.11	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10614	BLAUS	8	1995-08-29	1995-09-26	1995-09-01	3	1.93	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany
10615	WILMK	2	1995-08-30	1995-09-27	1995-09-06	3	0.75	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland
10616	GREAL	1	1995-08-31	1995-09-28	1995-09-05	2	116.53	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
10617	GREAL	4	1995-08-31	1995-09-28	1995-09-04	2	18.53	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
10618	MEREP	1	1995-09-01	1995-10-13	1995-09-08	1	154.68	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10619	MEREP	3	1995-09-04	1995-10-02	1995-09-07	3	91.05	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10620	LAUGB	2	1995-09-05	1995-10-03	1995-09-14	3	0.94	Laughing Bacchus Wine Cellars	2319 Elm St.	Vancouver	BC	V3F 2K1	Canada
10621	ISLAT	4	1995-09-05	1995-10-03	1995-09-11	2	23.73	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10622	RICAR	4	1995-09-06	1995-10-04	1995-09-11	3	50.97	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10623	FRANK	8	1995-09-07	1995-10-05	1995-09-12	2	97.18	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10624	THECR	4	1995-09-07	1995-10-05	1995-09-19	2	94.8	The Cracker Box	55 Grizzly Peak Rd.	Butte	MT	59801	USA
10625	ANATR	3	1995-09-08	1995-10-06	1995-09-14	1	43.9	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	México D.F.	\N	5021	Mexico
10626	BERGS	1	1995-09-11	1995-10-09	1995-09-20	2	138.69	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10627	SAVEA	8	1995-09-11	1995-10-23	1995-09-21	3	107.46	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10628	BLONP	4	1995-09-12	1995-10-10	1995-09-20	3	30.36	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10629	GODOS	4	1995-09-12	1995-10-10	1995-09-20	3	85.46	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
10630	KOENE	1	1995-09-13	1995-10-11	1995-09-19	2	32.35	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10631	LAMAI	8	1995-09-14	1995-10-12	1995-09-15	1	0.87	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10632	WANDK	8	1995-09-14	1995-10-12	1995-09-19	1	41.38	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10633	ERNSH	7	1995-09-15	1995-10-13	1995-09-18	3	477.9	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10634	FOLIG	4	1995-09-15	1995-10-13	1995-09-21	3	487.38	Folies gourmandes	184 chaussée de Tournai	Lille	\N	59000	France
10635	MAGAA	8	1995-09-18	1995-10-16	1995-09-21	3	47.46	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10636	WARTH	4	1995-09-19	1995-10-17	1995-09-26	1	1.15	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10637	QUEEN	6	1995-09-19	1995-10-17	1995-09-26	1	201.29	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10638	LINOD	3	1995-09-20	1995-10-18	1995-10-02	1	158.44	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10639	SANTG	7	1995-09-20	1995-10-18	1995-09-27	3	38.64	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway
10640	WANDK	4	1995-09-21	1995-10-19	1995-09-28	1	23.55	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10641	HILAA	4	1995-09-22	1995-10-20	1995-09-26	2	179.61	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10642	SIMOB	7	1995-09-22	1995-10-20	1995-10-06	3	41.89	Simons bistro	Vinbæltet 34	København	\N	1734	Denmark
10643	ALFKI	6	1995-09-25	1995-10-23	1995-10-03	1	29.46	Alfreds Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany
10644	WELLI	3	1995-09-25	1995-10-23	1995-10-02	2	0.14	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10645	HANAR	4	1995-09-26	1995-10-24	1995-10-03	1	12.41	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10646	HUNGO	9	1995-09-27	1995-11-08	1995-10-04	3	142.33	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10647	QUEDE	4	1995-09-27	1995-10-11	1995-10-04	2	45.54	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10648	RICAR	5	1995-09-28	1995-11-09	1995-10-10	2	14.25	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10649	MAISD	5	1995-09-28	1995-10-26	1995-09-29	3	6.2	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium
10650	FAMIA	5	1995-09-29	1995-10-27	1995-10-04	3	176.81	Familia Arquibaldo	Rua Orós 92	São Paulo	SP	05442-030	Brazil
10651	WANDK	8	1995-10-02	1995-10-30	1995-10-12	2	20.6	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10652	GOURL	4	1995-10-02	1995-10-30	1995-10-09	2	7.14	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
10653	FRANK	1	1995-10-03	1995-10-31	1995-10-20	1	93.25	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10654	BERGS	5	1995-10-03	1995-10-31	1995-10-12	1	55.26	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10655	REGGC	1	1995-10-04	1995-11-01	1995-10-12	2	4.41	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10656	GREAL	6	1995-10-05	1995-11-02	1995-10-11	1	57.15	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
10657	SAVEA	2	1995-10-05	1995-11-02	1995-10-16	2	352.69	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10658	QUICK	4	1995-10-06	1995-11-03	1995-10-09	1	364.15	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10659	QUEEN	7	1995-10-06	1995-11-03	1995-10-11	2	105.81	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10660	HUNGC	8	1995-10-09	1995-11-06	1995-11-15	1	111.29	Hungry Coyote Import Store	City Center Plaza516 Main St.	Elgin	OR	97827	USA
10661	HUNGO	7	1995-10-10	1995-11-07	1995-10-16	3	17.55	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10662	LONEP	3	1995-10-10	1995-11-07	1995-10-19	2	1.28	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA
10663	BONAP	2	1995-10-11	1995-10-25	1995-11-03	2	113.15	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10664	FURIB	1	1995-10-11	1995-11-08	1995-10-20	3	1.27	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal
10665	LONEP	1	1995-10-12	1995-11-09	1995-10-18	2	26.31	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA
10666	RICSU	7	1995-10-13	1995-11-10	1995-10-23	2	232.42	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
10667	ERNSH	7	1995-10-13	1995-11-10	1995-10-20	1	78.09	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10668	WANDK	1	1995-10-16	1995-11-13	1995-10-24	2	47.22	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
10669	SIMOB	2	1995-10-16	1995-11-13	1995-10-23	1	24.39	Simons bistro	Vinbæltet 34	København	\N	1734	Denmark
10670	FRANK	4	1995-10-17	1995-11-14	1995-10-19	1	203.48	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10671	FRANR	1	1995-10-18	1995-11-15	1995-10-25	1	30.34	France restauration	54 rue Royale	Nantes	\N	44000	France
10672	BERGS	9	1995-10-18	1995-11-01	1995-10-27	2	95.75	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10673	WILMK	2	1995-10-19	1995-11-16	1995-10-20	1	22.76	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland
10674	ISLAT	4	1995-10-19	1995-11-16	1995-10-31	2	0.9	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10675	FRANK	5	1995-10-20	1995-11-17	1995-10-24	2	31.85	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10676	TORTU	2	1995-10-23	1995-11-20	1995-10-30	2	2.01	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10677	ANTON	1	1995-10-23	1995-11-20	1995-10-27	3	4.03	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico
10678	SAVEA	7	1995-10-24	1995-11-21	1995-11-16	3	388.98	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10679	BLONP	8	1995-10-24	1995-11-21	1995-10-31	3	27.94	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10680	OLDWO	1	1995-10-25	1995-11-22	1995-10-27	1	26.61	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10681	GREAL	3	1995-10-26	1995-11-23	1995-10-31	3	76.13	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
10682	ANTON	3	1995-10-26	1995-11-23	1995-11-01	2	36.13	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico
10683	DUMON	2	1995-10-27	1995-11-24	1995-11-01	1	4.4	Du monde entier	67 rue des Cinquante Otages	Nantes	\N	44000	France
10684	OTTIK	3	1995-10-27	1995-11-24	1995-10-31	1	145.63	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
10685	GOURL	4	1995-10-30	1995-11-13	1995-11-03	2	33.75	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
10686	PICCO	2	1995-10-31	1995-11-28	1995-11-08	1	96.5	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10687	HUNGO	9	1995-10-31	1995-11-28	1995-11-30	2	296.43	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10688	VAFFE	4	1995-11-01	1995-11-15	1995-11-07	2	299.09	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10689	BERGS	1	1995-11-01	1995-11-29	1995-11-07	2	13.42	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10690	HANAR	1	1995-11-02	1995-11-30	1995-11-03	1	15.8	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10691	QUICK	2	1995-11-03	1995-12-15	1995-11-22	2	810.05	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10692	ALFKI	4	1995-11-03	1995-12-01	1995-11-13	2	61.02	Alfred's Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany
10693	WHITC	3	1995-11-06	1995-11-20	1995-11-10	3	139.34	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10694	QUICK	8	1995-11-06	1995-12-04	1995-11-09	3	398.36	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10695	WILMK	7	1995-11-07	1995-12-19	1995-11-14	1	16.72	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland
10696	WHITC	8	1995-11-08	1995-12-20	1995-11-14	3	102.55	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10748	SAVEA	3	1995-12-21	1996-01-18	1995-12-29	1	232.55	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10697	LINOD	3	1995-11-08	1995-12-06	1995-11-14	1	45.52	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10698	ERNSH	4	1995-11-09	1995-12-07	1995-11-17	1	272.47	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10699	MORGK	3	1995-11-09	1995-12-07	1995-11-13	3	0.58	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany
10700	SAVEA	3	1995-11-10	1995-12-08	1995-11-16	1	65.1	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10701	HUNGO	6	1995-11-13	1995-11-27	1995-11-15	3	220.31	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10702	ALFKI	4	1995-11-13	1995-12-25	1995-11-21	1	23.94	Alfred's Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany
10703	FOLKO	6	1995-11-14	1995-12-12	1995-11-20	2	152.3	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10704	QUEEN	6	1995-11-14	1995-12-12	1995-12-08	1	4.78	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10705	HILAA	9	1995-11-15	1995-12-13	1995-12-19	2	3.52	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10706	OLDWO	8	1995-11-16	1995-12-14	1995-11-21	3	135.63	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10707	AROUT	4	1995-11-16	1995-11-30	1995-11-23	3	21.74	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10708	THEBI	6	1995-11-17	1995-12-29	1995-12-06	2	2.96	The Big Cheese	89 Jefferson WaySuite 2	Portland	OR	97201	USA
10709	GOURL	1	1995-11-17	1995-12-15	1995-12-21	3	210.8	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
10710	FRANS	1	1995-11-20	1995-12-18	1995-11-23	1	4.98	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy
10711	SAVEA	5	1995-11-21	1996-01-02	1995-11-29	2	52.41	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10712	HUNGO	3	1995-11-21	1995-12-19	1995-12-01	1	89.93	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10713	SAVEA	1	1995-11-22	1995-12-20	1995-11-24	1	167.05	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10714	SAVEA	5	1995-11-22	1995-12-20	1995-11-27	3	24.49	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10715	BONAP	3	1995-11-23	1995-12-07	1995-11-29	1	63.2	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10716	RANCH	4	1995-11-24	1995-12-22	1995-11-27	2	22.57	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina
10717	FRANK	1	1995-11-24	1995-12-22	1995-11-29	2	59.25	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10718	KOENE	1	1995-11-27	1995-12-25	1995-11-29	3	170.88	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10719	LETSS	8	1995-11-27	1995-12-25	1995-12-06	2	51.44	Let's Stop N Shop	87 Polk St.Suite 5	San Francisco	CA	94117	USA
10720	QUEDE	8	1995-11-28	1995-12-12	1995-12-06	2	9.53	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10721	QUICK	5	1995-11-29	1995-12-27	1995-12-01	3	48.92	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10722	SAVEA	8	1995-11-29	1996-01-10	1995-12-05	1	74.58	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10723	WHITC	3	1995-11-30	1995-12-28	1995-12-26	1	21.72	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10724	MEREP	8	1995-11-30	1996-01-11	1995-12-06	2	57.75	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada
10725	FAMIA	4	1995-12-01	1995-12-29	1995-12-06	3	10.83	Familia Arquibaldo	Rua Orós 92	São Paulo	SP	05442-030	Brazil
10726	EASTC	4	1995-12-04	1995-12-18	1996-01-05	1	16.56	Eastern Connection	35 King George	London	\N	WX3 6FW	UK
10727	REGGC	2	1995-12-04	1996-01-01	1996-01-05	1	89.9	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10728	QUEEN	4	1995-12-05	1996-01-02	1995-12-12	2	58.33	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10729	LINOD	8	1995-12-05	1996-01-16	1995-12-15	3	141.06	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10730	BONAP	5	1995-12-06	1996-01-03	1995-12-15	1	20.12	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10731	CHOPS	7	1995-12-07	1996-01-04	1995-12-15	1	96.65	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland
10732	BONAP	3	1995-12-07	1996-01-04	1995-12-08	1	16.97	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10733	BERGS	1	1995-12-08	1996-01-05	1995-12-11	3	110.11	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10734	GOURL	2	1995-12-08	1996-01-05	1995-12-13	3	1.63	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
10735	LETSS	6	1995-12-11	1996-01-08	1995-12-22	2	45.97	Let's Stop N Shop	87 Polk St.Suite 5	San Francisco	CA	94117	USA
10736	HUNGO	9	1995-12-12	1996-01-09	1995-12-22	2	44.1	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10737	VINET	2	1995-12-12	1996-01-09	1995-12-19	2	7.79	Vins et alcools Chevalier	59 rue de l'Abbaye	Reims	\N	51100	France
10738	SPECD	2	1995-12-13	1996-01-10	1995-12-19	1	2.91	Spécialités du monde	25 rue Lauriston	Paris	\N	75016	France
10739	VINET	3	1995-12-13	1996-01-10	1995-12-18	3	11.08	Vins et alcools Chevalier	59 rue de l'Abbaye	Reims	\N	51100	France
10740	WHITC	4	1995-12-14	1996-01-11	1995-12-26	2	81.88	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10741	AROUT	4	1995-12-15	1995-12-29	1995-12-19	3	10.96	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10742	BOTTM	3	1995-12-15	1996-01-12	1995-12-19	3	243.73	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10743	AROUT	1	1995-12-18	1996-01-15	1995-12-22	2	23.72	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10744	VAFFE	6	1995-12-18	1996-01-15	1995-12-25	1	69.19	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10745	QUICK	9	1995-12-19	1996-01-16	1995-12-28	1	3.52	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10746	CHOPS	1	1995-12-20	1996-01-17	1995-12-22	3	31.43	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland
10747	PICCO	6	1995-12-20	1996-01-17	1995-12-27	1	117.33	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10749	ISLAT	4	1995-12-21	1996-01-18	1996-01-19	2	61.53	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10750	WARTH	9	1995-12-22	1996-01-19	1995-12-25	1	79.3	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10751	RICSU	3	1995-12-25	1996-01-22	1996-01-03	3	130.79	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
10752	NORTS	2	1995-12-25	1996-01-22	1995-12-29	3	1.39	North/South	South House300 Queensbridge	London	\N	SW7 1RZ	UK
10753	FRANS	3	1995-12-26	1996-01-23	1995-12-28	1	7.7	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy
10754	MAGAA	6	1995-12-26	1996-01-23	1995-12-28	3	2.38	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10755	BONAP	4	1995-12-27	1996-01-24	1995-12-29	2	16.71	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10756	SPLIR	8	1995-12-28	1996-01-25	1996-01-02	2	73.21	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10757	SAVEA	6	1995-12-28	1996-01-25	1996-01-15	1	8.19	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10758	RICSU	3	1995-12-29	1996-01-26	1996-01-04	3	138.17	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
10759	ANATR	3	1995-12-29	1996-01-26	1996-01-12	3	11.99	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	México D.F.	\N	5021	Mexico
10760	MAISD	4	1996-01-01	1996-01-29	1996-01-10	1	155.64	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium
10761	RATTC	5	1996-01-02	1996-01-30	1996-01-08	2	18.66	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10762	FOLKO	3	1996-01-02	1996-01-30	1996-01-09	1	328.74	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10763	FOLIG	3	1996-01-03	1996-01-31	1996-01-08	3	37.35	Folies gourmandes	184 chaussée de Tournai	Lille	\N	59000	France
10764	ERNSH	6	1996-01-03	1996-01-31	1996-01-08	3	145.45	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10765	QUICK	3	1996-01-04	1996-02-01	1996-01-09	3	42.74	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10766	OTTIK	4	1996-01-05	1996-02-02	1996-01-09	1	157.55	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
10767	SUPRD	4	1996-01-05	1996-02-02	1996-01-15	3	1.59	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10768	AROUT	3	1996-01-08	1996-02-05	1996-01-15	2	146.32	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10769	VAFFE	3	1996-01-08	1996-02-05	1996-01-12	1	65.06	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10770	HANAR	8	1996-01-09	1996-02-06	1996-01-17	3	5.32	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10771	ERNSH	9	1996-01-10	1996-02-07	1996-02-02	2	11.19	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10772	LEHMS	3	1996-01-10	1996-02-07	1996-01-19	2	91.28	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10773	ERNSH	1	1996-01-11	1996-02-08	1996-01-16	3	96.43	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10774	FOLKO	4	1996-01-11	1996-01-25	1996-01-12	1	48.2	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10775	THECR	7	1996-01-12	1996-02-09	1996-01-26	1	20.25	The Cracker Box	55 Grizzly Peak Rd.	Butte	MT	59801	USA
10776	ERNSH	1	1996-01-15	1996-02-12	1996-01-18	3	351.53	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10777	GOURL	7	1996-01-15	1996-01-29	1996-02-21	2	3.01	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
10778	BERGS	3	1996-01-16	1996-02-13	1996-01-24	1	6.79	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10779	MORGK	3	1996-01-16	1996-02-13	1996-02-14	2	58.13	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany
10780	LILAS	2	1996-01-16	1996-01-30	1996-01-25	1	42.13	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10781	WARTH	2	1996-01-17	1996-02-14	1996-01-19	3	73.16	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
10782	CACTU	9	1996-01-17	1996-02-14	1996-01-22	3	1.1	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina
10783	HANAR	4	1996-01-18	1996-02-15	1996-01-19	2	124.98	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10784	MAGAA	4	1996-01-18	1996-02-15	1996-01-22	3	70.09	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10785	GROSR	1	1996-01-18	1996-02-15	1996-01-24	3	1.51	GROSELLA-Restaurante	5ª Ave. Los Palos Grandes	Caracas	DF	1081	Venezuela
10786	QUEEN	8	1996-01-19	1996-02-16	1996-01-23	1	110.87	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10787	LAMAI	2	1996-01-19	1996-02-02	1996-01-26	1	249.93	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10788	QUICK	1	1996-01-22	1996-02-19	1996-02-19	2	42.7	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10789	FOLIG	1	1996-01-22	1996-02-19	1996-01-31	2	100.6	Folies gourmandes	184 chaussée de Tournai	Lille	\N	59000	France
10790	GOURL	6	1996-01-22	1996-02-19	1996-01-26	1	28.23	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
10791	FRANK	6	1996-01-23	1996-02-20	1996-02-01	2	16.85	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10792	WOLZA	1	1996-01-23	1996-02-20	1996-01-31	3	23.79	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland
10793	AROUT	3	1996-01-24	1996-02-21	1996-02-08	3	4.52	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10794	QUEDE	6	1996-01-24	1996-02-21	1996-02-02	1	21.49	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10795	ERNSH	8	1996-01-24	1996-02-21	1996-02-20	2	126.66	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10796	HILAA	3	1996-01-25	1996-02-22	1996-02-14	1	26.52	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10797	DRACD	7	1996-01-25	1996-02-22	1996-02-05	2	33.35	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany
10798	ISLAT	2	1996-01-26	1996-02-23	1996-02-05	1	2.33	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10799	KOENE	9	1996-01-26	1996-03-08	1996-02-05	3	30.76	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10800	SEVES	1	1996-01-26	1996-02-23	1996-02-05	3	137.44	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10801	BOLID	4	1996-01-29	1996-02-26	1996-01-31	2	97.09	Bólido Comidas preparadas	C/ Araquil 67	Madrid	\N	28023	Spain
10802	SIMOB	4	1996-01-29	1996-02-26	1996-02-02	2	257.26	Simons bistro	Vinbæltet 34	København	\N	1734	Denmark
10803	WELLI	4	1996-01-30	1996-02-27	1996-02-06	1	55.23	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10804	SEVES	6	1996-01-30	1996-02-27	1996-02-07	2	27.33	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10805	THEBI	2	1996-01-30	1996-02-27	1996-02-09	3	237.34	The Big Cheese	89 Jefferson WaySuite 2	Portland	OR	97201	USA
10806	VICTE	3	1996-01-31	1996-02-28	1996-02-05	2	22.11	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10807	FRANS	4	1996-01-31	1996-02-28	1996-03-01	1	1.36	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy
10808	OLDWO	2	1996-02-01	1996-02-29	1996-02-09	3	45.53	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10809	WELLI	7	1996-02-01	1996-02-29	1996-02-07	1	4.87	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10810	LAUGB	2	1996-02-01	1996-02-29	1996-02-07	3	4.33	Laughing Bacchus Wine Cellars	2319 Elm St.	Vancouver	BC	V3F 2K1	Canada
10811	LINOD	8	1996-02-02	1996-03-01	1996-02-08	1	31.22	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10812	REGGC	5	1996-02-02	1996-03-01	1996-02-12	1	59.78	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10813	RICAR	1	1996-02-05	1996-03-04	1996-02-09	1	47.38	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10814	VICTE	3	1996-02-05	1996-03-04	1996-02-14	3	130.94	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10815	SAVEA	2	1996-02-05	1996-03-04	1996-02-14	3	14.62	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10816	GREAL	4	1996-02-06	1996-03-05	1996-03-06	2	719.78	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
10817	KOENE	3	1996-02-06	1996-02-20	1996-02-13	2	306.07	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10818	MAGAA	7	1996-02-07	1996-03-06	1996-02-12	3	65.48	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10819	CACTU	2	1996-02-07	1996-03-06	1996-02-16	3	19.76	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina
10820	RATTC	3	1996-02-07	1996-03-06	1996-02-13	2	37.52	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10821	SPLIR	1	1996-02-08	1996-03-07	1996-02-15	1	36.68	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10822	TRAIH	6	1996-02-08	1996-03-07	1996-02-16	3	7.0	Trail's Head Gourmet Provisioners	722 DaVinci Blvd.	Kirkland	WA	98034	USA
10823	LILAS	5	1996-02-09	1996-03-08	1996-02-13	2	163.97	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10824	FOLKO	8	1996-02-09	1996-03-08	1996-03-01	1	1.23	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10825	DRACD	1	1996-02-09	1996-03-08	1996-02-14	1	79.25	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany
10826	BLONP	6	1996-02-12	1996-03-11	1996-03-08	1	7.09	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
10827	BONAP	1	1996-02-12	1996-02-26	1996-03-08	2	63.54	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10828	RANCH	9	1996-02-13	1996-02-27	1996-03-06	1	90.85	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina
10829	ISLAT	9	1996-02-13	1996-03-12	1996-02-23	1	154.72	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10830	TRADH	4	1996-02-13	1996-03-26	1996-02-21	2	81.83	Tradição Hipermercados	Av. Inês de Castro 414	São Paulo	SP	05634-030	Brazil
10831	SANTG	3	1996-02-14	1996-03-13	1996-02-23	2	72.19	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway
10832	LAMAI	2	1996-02-14	1996-03-13	1996-02-19	2	43.26	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10833	OTTIK	6	1996-02-15	1996-03-14	1996-02-23	2	71.49	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
10834	TRADH	1	1996-02-15	1996-03-14	1996-02-19	3	29.78	Tradição Hipermercados	Av. Inês de Castro 414	São Paulo	SP	05634-030	Brazil
10835	ALFKI	1	1996-02-15	1996-03-14	1996-02-21	3	69.53	Alfred's Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany
10836	ERNSH	7	1996-02-16	1996-03-15	1996-02-21	1	411.88	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10837	BERGS	9	1996-02-16	1996-03-15	1996-02-23	3	13.32	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10838	LINOD	3	1996-02-19	1996-03-18	1996-02-23	3	59.28	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10839	TRADH	3	1996-02-19	1996-03-18	1996-02-22	3	35.43	Tradição Hipermercados	Av. Inês de Castro 414	São Paulo	SP	05634-030	Brazil
10840	LINOD	4	1996-02-19	1996-04-01	1996-03-18	2	2.71	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10841	SUPRD	5	1996-02-20	1996-03-19	1996-02-29	2	424.3	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10842	TORTU	1	1996-02-20	1996-03-19	1996-02-29	3	54.42	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10843	VICTE	4	1996-02-21	1996-03-20	1996-02-26	2	9.26	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10844	PICCO	8	1996-02-21	1996-03-20	1996-02-26	2	25.22	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
10845	QUICK	8	1996-02-21	1996-03-06	1996-03-01	1	212.98	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10846	SUPRD	2	1996-02-22	1996-04-04	1996-02-23	3	56.46	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10847	SAVEA	4	1996-02-22	1996-03-07	1996-03-12	3	487.57	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10848	CONSH	7	1996-02-23	1996-03-22	1996-02-29	2	38.24	Consolidated Holdings	Berkeley Gardens12  Brewery	London	\N	WX1 6LT	UK
10849	KOENE	9	1996-02-23	1996-03-22	1996-03-01	2	0.56	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10850	VICTE	1	1996-02-23	1996-04-05	1996-03-01	1	49.19	Victuailles en stock	2 rue du Commerce	Lyon	\N	69004	France
10851	RICAR	5	1996-02-26	1996-03-25	1996-03-04	1	160.55	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10852	RATTC	8	1996-02-26	1996-03-11	1996-03-01	1	174.05	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10853	BLAUS	9	1996-02-27	1996-03-26	1996-03-05	2	53.83	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany
10854	ERNSH	3	1996-02-27	1996-03-26	1996-03-07	2	100.22	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10855	OLDWO	3	1996-02-27	1996-03-26	1996-03-06	1	170.97	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10856	ANTON	3	1996-02-28	1996-03-27	1996-03-12	2	58.43	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico
10857	BERGS	8	1996-02-28	1996-03-27	1996-03-08	2	188.85	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10858	LACOR	2	1996-02-29	1996-03-28	1996-03-05	1	52.51	La corne d'abondance	67 avenue de l'Europe	Versailles	\N	78000	France
10859	FRANK	1	1996-02-29	1996-03-28	1996-03-04	2	76.1	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10860	FRANR	3	1996-02-29	1996-03-28	1996-03-06	3	19.26	France restauration	54 rue Royale	Nantes	\N	44000	France
10861	WHITC	4	1996-03-01	1996-03-29	1996-03-19	2	14.93	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10862	LEHMS	8	1996-03-01	1996-04-12	1996-03-04	2	53.23	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10863	HILAA	4	1996-03-04	1996-04-01	1996-03-19	2	30.26	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10864	AROUT	4	1996-03-04	1996-04-01	1996-03-11	2	3.04	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10865	QUICK	2	1996-03-04	1996-03-18	1996-03-14	1	348.14	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10866	BERGS	5	1996-03-05	1996-04-02	1996-03-14	1	109.11	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10867	LONEP	6	1996-03-05	1996-04-16	1996-03-13	1	1.93	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA
10868	QUEEN	7	1996-03-06	1996-04-03	1996-03-25	2	191.27	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10869	SEVES	5	1996-03-06	1996-04-03	1996-03-11	1	143.28	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK
10870	WOLZA	5	1996-03-06	1996-04-03	1996-03-15	3	12.04	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland
10871	BONAP	9	1996-03-07	1996-04-04	1996-03-12	2	112.27	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10872	GODOS	5	1996-03-07	1996-04-04	1996-03-11	2	175.32	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
10873	WILMK	4	1996-03-08	1996-04-05	1996-03-11	1	0.82	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland
10874	GODOS	5	1996-03-08	1996-04-05	1996-03-13	2	19.58	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
10875	BERGS	4	1996-03-08	1996-04-05	1996-04-02	2	32.37	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10876	BONAP	7	1996-03-11	1996-04-08	1996-03-14	3	60.42	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10877	RICAR	1	1996-03-11	1996-04-08	1996-03-21	1	38.06	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
10878	QUICK	4	1996-03-12	1996-04-09	1996-03-14	1	46.69	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10879	WILMK	3	1996-03-12	1996-04-09	1996-03-14	3	8.5	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland
10880	FOLKO	7	1996-03-12	1996-04-23	1996-03-20	1	88.01	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10881	CACTU	4	1996-03-13	1996-04-10	1996-03-20	1	2.84	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina
10882	SAVEA	4	1996-03-13	1996-04-10	1996-03-22	3	23.1	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10883	LONEP	8	1996-03-14	1996-04-11	1996-03-22	3	0.53	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA
10884	LETSS	4	1996-03-14	1996-04-11	1996-03-15	2	90.97	Let's Stop N Shop	87 Polk St.Suite 5	San Francisco	CA	94117	USA
10885	SUPRD	6	1996-03-14	1996-04-11	1996-03-20	3	5.64	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10886	HANAR	1	1996-03-15	1996-04-12	1996-04-01	1	4.99	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10887	GALED	8	1996-03-15	1996-04-12	1996-03-18	3	1.25	Galería del gastronómo	Rambla de Cataluña 23	Barcelona	\N	8022	Spain
10888	GODOS	1	1996-03-18	1996-04-15	1996-03-25	2	51.87	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
10889	RATTC	9	1996-03-18	1996-04-15	1996-03-25	3	280.61	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10890	DUMON	7	1996-03-18	1996-04-15	1996-03-20	1	32.76	Du monde entier	67 rue des Cinquante Otages	Nantes	\N	44000	France
10891	LEHMS	7	1996-03-19	1996-04-16	1996-03-21	2	20.37	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10892	MAISD	4	1996-03-19	1996-04-16	1996-03-21	2	120.27	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium
10893	KOENE	9	1996-03-20	1996-04-17	1996-03-22	2	77.78	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
10894	SAVEA	1	1996-03-20	1996-04-17	1996-03-22	1	116.13	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10895	ERNSH	3	1996-03-20	1996-04-17	1996-03-25	1	162.75	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10896	MAISD	7	1996-03-21	1996-04-18	1996-03-29	3	32.45	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium
10897	HUNGO	3	1996-03-21	1996-04-18	1996-03-27	2	603.54	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10898	OCEAN	4	1996-03-22	1996-04-19	1996-04-05	2	1.27	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585Piso 20-A	Buenos Aires	\N	1010	Argentina
10899	LILAS	5	1996-03-22	1996-04-19	1996-03-28	3	1.21	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10900	WELLI	1	1996-03-22	1996-04-19	1996-04-03	2	1.66	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10901	HILAA	4	1996-03-25	1996-04-22	1996-03-28	1	62.09	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10902	FOLKO	1	1996-03-25	1996-04-22	1996-04-02	1	44.15	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10903	HANAR	3	1996-03-26	1996-04-23	1996-04-03	3	36.71	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10904	WHITC	3	1996-03-26	1996-04-23	1996-03-29	3	162.95	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
10905	WELLI	9	1996-03-26	1996-04-23	1996-04-05	2	13.72	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10906	WOLZA	4	1996-03-27	1996-04-10	1996-04-02	3	26.29	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland
10907	SPECD	6	1996-03-27	1996-04-24	1996-03-29	3	9.19	Spécialités du monde	25 rue Lauriston	Paris	\N	75016	France
10908	REGGC	4	1996-03-28	1996-04-25	1996-04-05	2	32.96	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10909	SANTG	1	1996-03-28	1996-04-25	1996-04-09	2	53.05	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway
10910	WILMK	1	1996-03-28	1996-04-25	1996-04-03	3	38.11	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland
10911	GODOS	3	1996-03-28	1996-04-25	1996-04-04	1	38.19	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
10912	HUNGO	2	1996-03-28	1996-04-25	1996-04-17	2	580.91	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10913	QUEEN	4	1996-03-28	1996-04-25	1996-04-03	1	33.05	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10914	QUEEN	6	1996-03-29	1996-04-26	1996-04-01	1	21.19	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10915	TORTU	2	1996-03-29	1996-04-26	1996-04-01	2	3.51	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
10916	RANCH	1	1996-03-29	1996-04-26	1996-04-08	2	63.77	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina
10917	ROMEY	4	1996-04-01	1996-04-29	1996-04-10	2	8.29	Romero y tomillo	Gran Vía 1	Madrid	\N	28001	Spain
10918	BOTTM	3	1996-04-01	1996-04-29	1996-04-10	3	48.83	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10919	LINOD	2	1996-04-01	1996-04-29	1996-04-03	2	19.8	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10920	AROUT	4	1996-04-02	1996-04-30	1996-04-08	2	29.61	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10921	VAFFE	1	1996-04-02	1996-05-14	1996-04-08	1	176.48	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10922	HANAR	5	1996-04-02	1996-04-30	1996-04-04	3	62.74	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10923	LAMAI	7	1996-04-02	1996-05-14	1996-04-12	3	68.26	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
10924	BERGS	3	1996-04-03	1996-05-01	1996-05-08	2	151.52	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden
10925	HANAR	3	1996-04-03	1996-05-01	1996-04-12	1	2.27	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10926	ANATR	4	1996-04-03	1996-05-01	1996-04-10	3	39.92	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	México D.F.	\N	5021	Mexico
10927	LACOR	4	1996-04-04	1996-05-02	1996-05-08	1	19.79	La corne d'abondance	67 avenue de l'Europe	Versailles	\N	78000	France
10928	GALED	1	1996-04-04	1996-05-02	1996-04-17	1	1.36	Galería del gastronómo	Rambla de Cataluña 23	Barcelona	\N	8022	Spain
10929	FRANK	6	1996-04-04	1996-05-02	1996-04-11	1	33.93	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
10930	SUPRD	4	1996-04-05	1996-05-17	1996-04-17	3	15.55	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
10931	RICSU	4	1996-04-05	1996-04-19	1996-04-18	2	13.6	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
10932	BONAP	8	1996-04-05	1996-05-03	1996-04-23	1	134.64	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10933	ISLAT	6	1996-04-05	1996-05-03	1996-04-15	3	54.15	Island Trading	Garden HouseCrowther Way	Cowes	Isle of Wight	PO31 7PJ	UK
10934	LEHMS	3	1996-04-08	1996-05-06	1996-04-11	3	32.01	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
10935	WELLI	4	1996-04-08	1996-05-06	1996-04-17	3	47.59	Wellington Importadora	Rua do Mercado 12	Resende	SP	08737-363	Brazil
10936	GREAL	3	1996-04-08	1996-05-06	1996-04-17	2	33.68	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
10937	CACTU	7	1996-04-09	1996-04-23	1996-04-12	3	31.51	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina
10938	QUICK	3	1996-04-09	1996-05-07	1996-04-15	2	31.89	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10939	MAGAA	2	1996-04-09	1996-05-07	1996-04-12	2	76.33	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10940	BONAP	8	1996-04-10	1996-05-08	1996-04-22	3	19.77	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
10941	SAVEA	7	1996-04-10	1996-05-08	1996-04-19	2	400.81	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10942	REGGC	9	1996-04-10	1996-05-08	1996-04-17	3	17.95	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
10943	BSBEV	4	1996-04-10	1996-05-08	1996-04-18	2	2.17	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10944	BOTTM	6	1996-04-11	1996-04-25	1996-04-12	3	52.92	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10945	MORGK	4	1996-04-11	1996-05-09	1996-04-17	1	10.22	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany
10946	VAFFE	1	1996-04-11	1996-05-09	1996-04-18	2	27.2	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10947	BSBEV	3	1996-04-12	1996-05-10	1996-04-15	2	3.26	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
10948	GODOS	3	1996-04-12	1996-05-10	1996-04-18	3	23.39	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
10949	BOTTM	2	1996-04-12	1996-05-10	1996-04-16	3	74.44	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10950	MAGAA	1	1996-04-15	1996-05-13	1996-04-22	2	2.5	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy
10951	RICSU	9	1996-04-15	1996-05-27	1996-05-07	2	30.85	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
10952	ALFKI	1	1996-04-15	1996-05-27	1996-04-23	1	40.42	Alfred's Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany
10953	AROUT	9	1996-04-15	1996-04-29	1996-04-24	2	23.72	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
10954	LINOD	5	1996-04-16	1996-05-28	1996-04-19	1	27.91	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
10955	FOLKO	8	1996-04-16	1996-05-14	1996-04-19	2	3.26	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10956	BLAUS	6	1996-04-16	1996-05-28	1996-04-19	2	44.65	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany
10957	HILAA	8	1996-04-17	1996-05-15	1996-04-26	3	105.36	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10958	OCEAN	7	1996-04-17	1996-05-15	1996-04-26	2	49.56	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585Piso 20-A	Buenos Aires	\N	1010	Argentina
10959	GOURL	6	1996-04-17	1996-05-29	1996-04-22	2	4.98	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
10960	HILAA	3	1996-04-18	1996-05-02	1996-05-08	1	2.08	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10961	QUEEN	8	1996-04-18	1996-05-16	1996-04-29	1	104.47	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
10962	QUICK	8	1996-04-18	1996-05-16	1996-04-22	2	275.79	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10963	FURIB	9	1996-04-18	1996-05-16	1996-04-25	3	2.7	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal
10964	SPECD	3	1996-04-19	1996-05-17	1996-04-23	2	87.38	Spécialités du monde	25 rue Lauriston	Paris	\N	75016	France
10965	OLDWO	6	1996-04-19	1996-05-17	1996-04-29	3	144.38	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
10966	CHOPS	4	1996-04-19	1996-05-17	1996-05-08	1	27.19	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland
10967	TOMSP	2	1996-04-22	1996-05-20	1996-05-02	2	62.22	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany
10968	ERNSH	1	1996-04-22	1996-05-20	1996-05-01	3	74.6	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10969	COMMI	1	1996-04-22	1996-05-20	1996-04-29	2	0.21	Comércio Mineiro	Av. dos Lusíadas 23	São Paulo	SP	05432-043	Brazil
10970	BOLID	9	1996-04-23	1996-05-07	1996-05-24	1	16.16	Bólido Comidas preparadas	C/ Araquil 67	Madrid	\N	28023	Spain
10971	FRANR	2	1996-04-23	1996-05-21	1996-05-02	2	121.82	France restauration	54 rue Royale	Nantes	\N	44000	France
10972	LACOR	4	1996-04-23	1996-05-21	1996-04-25	2	0.02	La corne d'abondance	67 avenue de l'Europe	Versailles	\N	78000	France
10973	LACOR	6	1996-04-23	1996-05-21	1996-04-26	2	15.17	La corne d'abondance	67 avenue de l'Europe	Versailles	\N	78000	France
10974	SPLIR	3	1996-04-24	1996-05-08	1996-05-03	3	12.96	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA
10975	BOTTM	1	1996-04-24	1996-05-22	1996-04-26	3	32.27	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10976	HILAA	1	1996-04-24	1996-06-05	1996-05-03	1	37.97	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
10977	FOLKO	8	1996-04-25	1996-05-23	1996-05-10	3	208.5	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10978	MAISD	9	1996-04-25	1996-05-23	1996-05-23	2	32.82	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium
10979	ERNSH	8	1996-04-25	1996-05-23	1996-04-30	2	353.07	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10980	FOLKO	4	1996-04-26	1996-06-07	1996-05-17	1	1.26	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10981	HANAR	1	1996-04-26	1996-05-24	1996-05-02	2	193.37	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
10982	BOTTM	2	1996-04-26	1996-05-24	1996-05-08	1	14.01	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
10983	SAVEA	2	1996-04-26	1996-05-24	1996-05-06	2	657.54	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10984	SAVEA	1	1996-04-29	1996-05-27	1996-05-03	3	211.22	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
10985	HUNGO	2	1996-04-29	1996-05-27	1996-05-02	1	91.51	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
10986	OCEAN	8	1996-04-29	1996-05-27	1996-05-21	2	217.86	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585Piso 20-A	Buenos Aires	\N	1010	Argentina
10987	EASTC	8	1996-04-30	1996-05-28	1996-05-06	1	185.48	Eastern Connection	35 King George	London	\N	WX3 6FW	UK
10988	RATTC	3	1996-04-30	1996-05-28	1996-05-10	2	61.14	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
10989	QUEDE	2	1996-04-30	1996-05-28	1996-05-02	1	34.76	Que Delícia	Rua da Panificadora 12	Rio de Janeiro	RJ	02389-673	Brazil
10990	ERNSH	2	1996-05-01	1996-06-12	1996-05-07	3	117.61	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
10991	QUICK	1	1996-05-01	1996-05-29	1996-05-07	1	38.51	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10992	THEBI	1	1996-05-01	1996-05-29	1996-05-03	3	4.27	The Big Cheese	89 Jefferson WaySuite 2	Portland	OR	97201	USA
10993	FOLKO	7	1996-05-01	1996-05-29	1996-05-10	3	8.81	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
10994	VAFFE	2	1996-05-02	1996-05-16	1996-05-09	3	65.53	Vaffeljernet	Smagsløget 45	Århus	\N	8200	Denmark
10995	PERIC	1	1996-05-02	1996-05-30	1996-05-06	3	46.0	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico
10996	QUICK	4	1996-05-02	1996-05-30	1996-05-10	2	1.12	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
10997	LILAS	8	1996-05-03	1996-06-14	1996-05-13	2	73.91	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
10998	WOLZA	8	1996-05-03	1996-05-17	1996-05-17	2	20.31	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland
10999	OTTIK	6	1996-05-03	1996-05-31	1996-05-10	2	96.35	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
11000	RATTC	2	1996-05-06	1996-06-03	1996-05-14	3	55.12	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
11001	FOLKO	2	1996-05-06	1996-06-03	1996-05-14	2	197.3	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
11002	SAVEA	4	1996-05-06	1996-06-03	1996-05-16	1	141.16	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
11003	THECR	3	1996-05-06	1996-06-03	1996-05-08	3	14.91	The Cracker Box	55 Grizzly Peak Rd.	Butte	MT	59801	USA
11004	MAISD	3	1996-05-07	1996-06-04	1996-05-20	1	44.84	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium
11005	WILMK	2	1996-05-07	1996-06-04	1996-05-10	1	0.75	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland
11006	GREAL	3	1996-05-07	1996-06-04	1996-05-15	2	25.19	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
11007	PRINI	8	1996-05-08	1996-06-05	1996-05-13	2	202.24	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal
11008	ERNSH	7	1996-05-08	1996-06-05	\N	3	79.46	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
11009	GODOS	2	1996-05-08	1996-06-05	5/10/1996	1	59.11	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
11010	REGGC	2	1996-05-09	1996-06-06	5/21/1996	2	28.71	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
11011	ALFKI	3	1996-05-09	1996-06-06	5/13/1996	1	1.21	Alfred's Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany
11012	FRANK	1	1996-05-09	1996-05-23	5/17/1996	3	242.95	Frankenversand	Berliner Platz 43	München	\N	80805	Germany
11013	ROMEY	2	1996-05-09	1996-06-06	5/10/1996	1	32.99	Romero y tomillo	Gran Vía 1	Madrid	\N	28001	Spain
11014	LINOD	2	1996-05-10	1996-06-07	5/15/1996	3	23.6	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
11015	SANTG	2	1996-05-10	1996-05-24	5/20/1996	2	4.62	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway
11016	AROUT	9	1996-05-10	1996-06-07	5/13/1996	2	33.8	Around the Horn	Brook FarmStratford St. Mary	Colchester	Essex	CO7 6JX	UK
11017	ERNSH	9	1996-05-13	1996-06-10	5/20/1996	2	754.26	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
11018	LONEP	4	1996-05-13	1996-06-10	5/16/1996	2	11.65	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA
11019	RANCH	6	1996-05-13	1996-06-10	\N	3	3.17	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina
11020	OTTIK	2	1996-05-14	1996-06-11	5/16/1996	2	43.3	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany
11021	QUICK	3	1996-05-14	1996-06-11	5/21/1996	1	297.18	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany
11022	HANAR	9	1996-05-14	1996-06-11	6/3/1996	2	6.27	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
11023	BSBEV	1	1996-05-14	1996-05-28	5/24/1996	2	123.83	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
11024	EASTC	4	1996-05-15	1996-06-12	5/20/1996	1	74.36	Eastern Connection	35 King George	London	\N	WX3 6FW	UK
11025	WARTH	6	1996-05-15	1996-06-12	5/24/1996	3	29.17	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland
11026	FRANS	4	1996-05-15	1996-06-12	5/28/1996	1	47.09	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy
11027	BOTTM	1	1996-05-16	1996-06-13	5/20/1996	1	52.52	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
11028	KOENE	2	1996-05-16	1996-06-13	5/22/1996	1	29.59	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany
11029	CHOPS	4	1996-05-16	1996-06-13	5/27/1996	1	47.84	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland
11030	SAVEA	7	1996-05-17	1996-06-14	5/27/1996	2	830.75	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
11031	SAVEA	6	1996-05-17	1996-06-14	5/24/1996	2	227.22	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
11032	WHITC	2	1996-05-17	1996-06-14	5/23/1996	3	606.19	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
11033	RICSU	7	1996-05-17	1996-06-14	5/23/1996	3	84.74	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
11034	OLDWO	8	1996-05-20	1996-07-01	5/27/1996	1	40.32	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA
11035	SUPRD	2	1996-05-20	1996-06-17	5/24/1996	2	0.17	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
11036	DRACD	8	1996-05-20	1996-06-17	5/22/1996	3	149.47	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany
11037	GODOS	7	1996-05-21	1996-06-18	5/27/1996	1	3.2	Godos Cocina Típica	C/ Romero 33	Sevilla	\N	41101	Spain
11038	SUPRD	1	1996-05-21	1996-06-18	5/30/1996	2	29.59	Suprêmes délices	Boulevard Tirou 255	Charleroi	\N	B-6000	Belgium
11039	LINOD	1	1996-05-21	1996-06-18	\N	2	65.0	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela
11040	GREAL	4	1996-05-22	1996-06-19	\N	3	18.84	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
11041	CHOPS	3	1996-05-22	1996-06-19	5/28/1996	2	48.22	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland
11042	COMMI	2	1996-05-22	1996-06-05	5/31/1996	1	29.99	Comércio Mineiro	Av. dos Lusíadas 23	São Paulo	SP	05432-043	Brazil
11043	SPECD	5	1996-05-22	1996-06-19	5/29/1996	2	8.8	Spécialités du monde	25 rue Lauriston	Paris	\N	75016	France
11044	WOLZA	4	1996-05-23	1996-06-20	5/31/1996	1	8.72	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland
11045	BOTTM	6	1996-05-23	1996-06-20	\N	2	70.58	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
11046	WANDK	8	1996-05-23	1996-06-20	5/24/1996	2	71.64	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany
11047	EASTC	7	1996-05-24	1996-06-21	5/31/1996	3	46.62	Eastern Connection	35 King George	London	\N	WX3 6FW	UK
11048	BOTTM	7	1996-05-24	1996-06-21	5/30/1996	3	24.12	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada
11049	GOURL	3	1996-05-24	1996-06-21	6/3/1996	1	8.34	Gourmet Lanchonetes	Av. Brasil 442	Campinas	SP	04876-786	Brazil
11050	FOLKO	8	1996-05-27	1996-06-24	6/4/1996	2	59.41	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden
11051	LAMAI	7	1996-05-27	1996-06-24	\N	3	2.79	La maison d'Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France
11052	HANAR	3	1996-05-27	1996-06-24	5/31/1996	1	67.26	Hanari Carnes	Rua do Paço 67	Rio de Janeiro	RJ	05454-876	Brazil
11053	PICCO	2	1996-05-27	1996-06-24	5/29/1996	2	53.05	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria
11054	CACTU	8	1996-05-28	1996-06-25	\N	1	0.33	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina
11055	HILAA	7	1996-05-28	1996-06-25	6/4/1996	2	120.92	HILARIÓN-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela
11056	EASTC	8	1996-05-28	1996-06-11	5/31/1996	2	278.96	Eastern Connection	35 King George	London	\N	WX3 6FW	UK
11057	NORTS	3	1996-05-29	1996-06-26	5/31/1996	3	4.13	North/South	South House300 Queensbridge	London	\N	SW7 1RZ	UK
11058	BLAUS	9	1996-05-29	1996-06-26	\N	3	31.14	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany
11059	RICAR	2	1996-05-29	1996-07-10	\N	2	85.8	Ricardo Adocicados	Av. Copacabana 267	Rio de Janeiro	RJ	02389-890	Brazil
11060	FRANS	2	1996-05-30	1996-06-27	6/3/1996	2	10.98	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy
11061	GREAL	4	1996-05-30	1996-07-11	\N	3	14.01	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA
11062	REGGC	4	1996-05-30	1996-06-27	\N	2	29.93	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy
11063	HUNGO	3	1996-05-30	1996-06-27	6/5/1996	2	81.73	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland
11064	SAVEA	1	1996-05-31	1996-06-28	6/3/1996	1	30.09	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA
11065	LILAS	8	1996-05-31	1996-06-28	\N	1	12.91	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
11066	WHITC	7	1996-05-31	1996-06-28	6/3/1996	2	44.72	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA
11067	DRACD	1	1996-06-03	1996-06-17	6/5/1996	2	7.98	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany
11068	QUEEN	8	1996-06-03	1996-07-01	\N	2	81.75	Queen Cozinha	Alameda dos Canàrios 891	São Paulo	SP	05487-020	Brazil
11069	TORTU	1	1996-06-03	1996-07-01	6/5/1996	2	15.67	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico
11070	LEHMS	2	1996-06-04	1996-07-02	\N	1	136.0	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany
11071	LILAS	1	1996-06-04	1996-07-02	\N	1	0.93	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela
11072	ERNSH	4	1996-06-04	1996-07-02	\N	2	258.64	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria
11073	PERIC	2	1996-06-04	1996-07-02	\N	2	24.95	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico
11074	SIMOB	7	1996-06-05	1996-07-03	\N	2	18.44	Simons bistro	Vinbæltet 34	København	\N	1734	Denmark
11075	RICSU	8	1996-06-05	1996-07-03	\N	2	6.19	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland
11076	BONAP	4	1996-06-05	1996-07-03	\N	2	38.28	Bon app'	12 rue des Bouchers	Marseille	\N	13008	France
11077	RATTC	1	1996-06-05	1996-07-03	\N	2	8.53	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA
11078	BSBEV	9	1999-02-17	\N	\N	2	\N	B's Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK
11079	BLONP	4	1999-02-17	\N	\N	2	25.0	Blondel père et fils	24 place Kléber	Strasbourg	\N	67000	France
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (productid, productname, supplierid, categoryid, quantityperunit, priceperunit, unitsinstock, unitsonorder, reorderlevel, discontinued) FROM stdin;
1	Chai	1	1	10 boxes x 20 bags	18.0	39	0	10	0
2	Chang	1	1	24 - 12 oz bottles	19.0	17	40	25	0
3	Aniseed Syrup	1	2	12 - 550 ml bottles	10.0	13	70	25	0
4	Chef Anton's Cajun Seasoning	2	2	48 - 6 oz jars	22.0	53	0	0	0
5	Chef Anton's Gumbo Mix	2	2	36 boxes	21.35	0	0	0	1
6	Grandma's Boysenberry Spread	3	2	12 - 8 oz jars	25.0	120	0	25	0
7	Uncle Bob's Organic Dried Pears	3	7	12 - 1 lb pkgs.	30.0	15	0	10	0
8	Northwoods Cranberry Sauce	3	2	12 - 12 oz jars	40.0	6	0	0	0
9	Mishi Kobe Niku	4	6	18 - 500 g pkgs.	97.0	29	0	0	1
10	Ikura	4	8	12 - 200 ml jars	31.0	31	0	0	0
11	Queso Cabrales	5	4	1 kg pkg.	21.0	22	30	30	0
12	Queso Manchego La Pastora	5	4	10 - 500 g pkgs.	38.0	86	0	0	0
13	Konbu	6	8	2 kg box	6.0	24	0	5	0
14	Tofu	6	7	40 - 100 g pkgs.	23.25	35	0	0	0
15	Genen Shouyu	6	2	24 - 250 ml bottles	15.5	39	0	5	0
16	Pavlova	7	3	32 - 500 g boxes	17.45	29	0	10	0
17	Alice Mutton	7	6	20 - 1 kg tins	39.0	0	0	0	1
18	Carnarvon Tigers	7	8	16 kg pkg.	62.5	42	0	0	0
19	Teatime Chocolate Biscuits	8	3	10 boxes x 12 pieces	9.2	25	0	5	0
20	Sir Rodney's Marmalade	8	3	30 gift boxes	81.0	40	0	0	0
21	Sir Rodney's Scones	8	3	24 pkgs. x 4 pieces	10.0	3	40	5	0
22	Gustaf's Knäckebröd	9	5	24 - 500 g pkgs.	21.0	104	0	25	0
23	Tunnbröd	9	5	12 - 250 g pkgs.	9.0	61	0	25	0
24	Guaraná Fantástica	10	1	12 - 355 ml cans	4.5	20	0	0	1
25	NuNuCa Nuß-Nougat-Creme	11	3	20 - 450 g glasses	14.0	76	0	30	0
26	Gumbär Gummibärchen	11	3	100 - 250 g bags	31.23	15	0	0	0
27	Schoggi Schokolade	11	3	100 - 100 g pieces	43.9	49	0	30	0
28	Rössle Sauerkraut	12	7	25 - 825 g cans	45.6	26	0	0	1
29	Thüringer Rostbratwurst	12	6	50 bags x 30 sausgs.	123.79	0	0	0	1
30	Nord-Ost Matjeshering	13	8	10 - 200 g glasses	25.89	10	0	15	0
31	Gorgonzola Telino	14	4	12 - 100 g pkgs	12.5	0	70	20	0
32	Mascarpone Fabioli	14	4	24 - 200 g pkgs.	32.0	9	40	25	0
33	Geitost	15	4	500 g	2.5	112	0	20	0
34	Sasquatch Ale	16	1	24 - 12 oz bottles	14.0	111	0	15	0
35	Steeleye Stout	16	1	24 - 12 oz bottles	18.0	20	0	15	0
36	Inlagd Sill	17	8	24 - 250 g  jars	19.0	112	0	20	0
37	Gravad lax	17	8	12 - 500 g pkgs.	26.0	11	50	25	0
38	Côte de Blaye	18	1	12 - 75 cl bottles	263.5	17	0	15	0
39	Chartreuse verte	18	1	750 cc per bottle	18.0	69	0	5	0
40	Boston Crab Meat	19	8	24 - 4 oz tins	18.4	123	0	30	0
41	Jack's New England Clam Chowder	19	8	12 - 12 oz cans	9.65	85	0	10	0
42	Singaporean Hokkien Fried Mee	20	5	32 - 1 kg pkgs.	14.0	26	0	0	1
43	Ipoh Coffee	20	1	16 - 500 g tins	46.0	17	10	25	0
44	Gula Malacca	20	2	20 - 2 kg bags	19.45	27	0	15	0
45	Røgede sild	21	8	1k pkg.	9.5	5	70	15	0
46	Spegesild	21	8	4 - 450 g glasses	12.0	95	0	0	0
47	Zaanse koeken	22	3	10 - 4 oz boxes	9.5	36	0	0	0
48	Chocolade	22	3	10 pkgs.	12.75	15	70	25	0
49	Maxilaku	23	3	24 - 50 g pkgs.	20.0	10	60	15	0
50	Valkoinen suklaa	23	3	12 - 100 g bars	16.25	65	0	30	0
51	Manjimup Dried Apples	24	7	50 - 300 g pkgs.	53.0	20	0	10	0
52	Filo Mix	24	5	16 - 2 kg boxes	7.0	38	0	25	0
53	Perth Pasties	24	6	48 pieces	32.8	0	0	0	1
54	Tourtière	25	6	16 pies	7.45	21	0	10	0
55	Pâté chinois	25	6	24 boxes x 2 pies	24.0	115	0	20	0
56	Gnocchi di nonna Alice	26	5	24 - 250 g pkgs.	38.0	21	10	30	0
57	Ravioli Angelo	26	5	24 - 250 g pkgs.	19.5	36	0	20	0
58	Escargots de Bourgogne	27	8	24 pieces	13.25	62	0	20	0
59	Raclette Courdavault	28	4	5 kg pkg.	55.0	79	0	0	0
60	Camembert Pierrot	28	4	15 - 300 g rounds	34.0	19	0	0	0
61	Sirop d'érable	29	2	24 - 500 ml bottles	28.5	113	0	25	0
62	Tarte au sucre	29	3	48 pies	49.3	17	0	0	0
63	Vegie-spread	7	2	15 - 625 g jars	43.9	24	0	5	0
64	Wimmers gute Semmelknödel	12	5	20 bags x 4 pieces	33.25	22	80	30	0
65	Louisiana Fiery Hot Pepper Sauce	2	2	32 - 8 oz bottles	21.05	76	0	0	0
66	Louisiana Hot Spiced Okra	2	2	24 - 8 oz jars	17.0	4	100	20	0
67	Laughing Lumberjack Lager	16	1	24 - 12 oz bottles	14.0	52	0	10	0
68	Scottish Longbreads	8	3	10 boxes x 8 pieces	12.5	6	10	15	0
69	Gudbrandsdalsost	15	4	10 kg pkg.	36.0	26	0	15	0
70	Outback Lager	7	1	24 - 355 ml bottles	15.0	15	10	30	0
71	Fløtemysost	15	4	10 - 500 g pkgs.	21.5	26	0	0	0
72	Mozzarella di Giovanni	14	4	24 - 200 g pkgs.	34.8	14	0	0	0
73	Röd Kaviar	17	8	24 - 150 g jars	15.0	101	0	5	0
74	Longlife Tofu	4	7	5 kg pkg.	10.0	4	20	5	0
75	Rhönbräu Klosterbier	12	1	24 - 0.5 l bottles	7.75	125	0	25	0
76	Lakkalikööri	23	1	500 ml	18.0	57	0	20	0
77	Original Frankfurter grüne Soße	12	2	12 boxes	13.0	32	0	15	0
\.


--
-- Data for Name: vendors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vendors (supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax, homepage) FROM stdin;
1	Exotic Liquids	Charlotte Cooper	Purchasing Manager	49 Gilbert St.	London	\N	EC1 4SD	UK	(171) 555-2222	\N	\N
2	New Orleans Cajun Delights	Shelley Burke	Order Administrator	P.O. Box 78934	New Orleans	LA	70117	USA	(100) 555-4822	\N	#CAJUN.HTM#
3	Grandma Kelly's Homestead	Regina Murphy	Sales Representative	707 Oxford Rd.	Ann Arbor	MI	48104	USA	(313) 555-5735	(313) 555-3349	\N
4	Tokyo Traders	Yoshi Nagase	Marketing Manager	9-8 Sekimai Musashino-shi	Tokyo	\N	100	Japan	(03) 3555-5011	\N	\N
5	Cooperativa de Quesos 'Las Cabras'	Antonio del Valle Saavedra 	Export Administrator	Calle del Rosal 4	Oviedo	Asturias	33007	Spain	(98) 598 76 54	\N	\N
6	Mayumi's	Mayumi Ohno	Marketing Representative	92 Setsuko Chuo-ku	Osaka	\N	545	Japan	(06) 431-7877	\N	Mayumi's (on the World Wide Web)#http://www.microsoft.com/accessdev/sampleapps/mayumi.htm#
7	Pavlova, Ltd.	Ian Devling	Marketing Manager	74 Rose St. Moonie Ponds	Melbourne	Victoria	3058	Australia	(03) 444-2343	(03) 444-6588	\N
8	Specialty Biscuits, Ltd.	Peter Wilson	Sales Representative	29 King's Way	Manchester	\N	M14 GSD	UK	(161) 555-4448	\N	\N
9	PB Knäckebröd AB	Lars Peterson	Sales Agent	Kaloadagatan 13	Göteborg	\N	S-345 67	Sweden 	031-987 65 43	031-987 65 91	\N
10	Refrescos Americanas LTDA	Carlos Diaz	Marketing Manager	Av. das Americanas 12.890	São Paulo	\N	5442	Brazil	(11) 555 4640	\N	\N
11	Heli Süßwaren GmbH & Co. KG	Petra Winkler	Sales Manager	Tiergartenstraße 5	Berlin	\N	10785	Germany	(010) 9984510	\N	\N
12	Plutzer Lebensmittelgroßmärkte AG	Martin Bein	International Marketing Mgr.	Bogenallee 51	Frankfurt	\N	60439	Germany	(069) 992755	\N	Plutzer (on the World Wide Web)#http://www.microsoft.com/accessdev/sampleapps/plutzer.htm#
13	Nord-Ost-Fisch Handelsgesellschaft mbH	Sven Petersen	Coordinator Foreign Markets	Frahmredder 112a	Cuxhaven	\N	27478	Germany	(04721) 8713	(04721) 8714	\N
14	Formaggi Fortini s.r.l.	Elio Rossi	Sales Representative	Viale Dante, 75	Ravenna	\N	48100	Italy	(0544) 60323	(0544) 60603	#FORMAGGI.HTM#
15	Norske Meierier	Beate Vileid	Marketing Manager	Hatlevegen 5	Sandvika	\N	1320	Norway	(0)2-953010	\N	\N
16	Bigfoot Breweries	Cheryl Saylor	Regional Account Rep.	3400 - 8th Avenue Suite 210	Bend	OR	97101	USA	(503) 555-9931	\N	\N
17	Svensk Sjöföda AB	Michael Björn	Sales Representative	Brovallavägen 231	Stockholm	\N	S-123 45	Sweden	08-123 45 67	\N	\N
18	Aux joyeux ecclésiastiques	Guylène Nodier	Sales Manager	203, Rue des Francs-Bourgeois	Paris	\N	75004	France	(1) 03.83.00.68	(1) 03.83.00.62	\N
19	New England Seafood Cannery	Robb Merchant	Wholesale Account Agent	Order Processing Dept. 2100 Paul Revere Blvd.	Boston	MA	02134	USA	(617) 555-3267	(617) 555-3389	\N
20	Leka Trading	Chandra Leka	Owner	471 Serangoon Loop, Suite #402	Singapore	\N	0512	Singapore	555-8787	\N	\N
21	Lyngbysild	Niels Petersen	Sales Manager	Lyngbysild Fiskebakken 10	Lyngby	\N	2800	Denmark	43844108	43844115	\N
22	Zaanse Snoepfabriek	Dirk Luchte	Accounting Manager	Verkoop Rijnweg 22	Zaandam	\N	9999 ZZ	Netherlands	(12345) 1212	(12345) 1210	\N
23	Karkki Oy	Anne Heikkonen	Product Manager	Valtakatu 12	Lappeenranta	\N	53120	Finland	(953) 10956	\N	\N
24	G'day, Mate	Wendy Mackenzie	Sales Representative	170 Prince Edward Parade Hunter's Hill	Sydney	NSW	2042	Australia	(02) 555-5914	(02) 555-4873	G'day Mate (on the World Wide Web)#http://www.microsoft.com/accessdev/sampleapps/gdaymate.htm#
25	Ma Maison	Jean-Guy Lauzon	Marketing Manager	2960 Rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	(514) 555-9022	\N	\N
26	Pasta Buttini s.r.l.	Giovanni Giudici	Order Administrator	Via dei Gelsomini, 153	Salerno	\N	84100	Italy	(089) 6547665	(089) 6547667	\N
27	Escargots Nouveaux	Marie Delamare	Sales Manager	22, rue H. Voiron	Montceau	\N	71300	France	85.57.00.07	\N	\N
28	Gai pâturage	Eliane Noz	Sales Representative	Bat. B 3, rue des Alpes	Annecy	\N	74000	France	38.76.98.06	38.76.98.58	\N
29	Forêts d'érables	Chantal Goulet	Accounting Manager	148 rue Chasseur	Ste-Hyacinthe	Québec	J2S 7S8	Canada	(514) 555-2955	(514) 555-2921	\N
\.


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customerid);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (orderid);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (productid);


--
-- Name: vendors vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (supplierid);


--
-- PostgreSQL database dump complete
--

