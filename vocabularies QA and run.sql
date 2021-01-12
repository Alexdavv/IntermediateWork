select CURRENT_USER;
show search_path;


--01. Create_DEV_from_DevV5_DDL
--https://github.com/OHDSI/Vocabulary-v5.0/blob/master/working/Create_DEV_from_DevV5_DDL.sql



--02. Fast recreate
--Use this script to recreate main tables (concept, concept_relationship, concept_synonym etc) without dropping your schema
--devv5 - static variable;

--02.1. Recreate with default settings (copy from devv5, w/o ancestor, deprecated relationships and synonyms (faster)
--SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5');

--02.2. Same as above, but table concept_ancestor is included
--SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5', include_concept_ancestor=>true);

--02.3 Full recreate, all tables are included
SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5', include_concept_ancestor=>true, include_deprecated_rels=>true, include_synonyms=>true);

--02.4 Preserve old concept_ancestor, but it will be ignored if the include_concept_ancestor is set to true
--SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5', drop_concept_ancestor=>false);



--03. SQL script checklist:
--1. Check cyrillic symbols, especially 'с'
--2. Check in console that every query does something (otherwise, there will be 'completed in'/'0 rows' message)
--3. Check every IN () statement has WHERE IS NOT NULL limitation
--4. Confirm that every IN statement retrieve something
--5. OR statement inside AND statement



--04. schema DDL check
select * from devv5.qa_ddl();



--05. DRUG input tables checks
--05.1. Errors
--RUN https://github.com/OHDSI/Vocabulary-v5.0/blob/master/working/input_QA_integratable_E.sql --All queries should retrieve NULL

--05.2. Warnings
--RUN https://github.com/OHDSI/Vocabulary-v5.0/blob/master/working/input_QA_integratable_W.sql --All non-NULL results should be reviewed

--05.3. Old checks
--RUN all queries from Vocabulary-v5.0/working/drug_stage_tables_QA.sql --All queries should retrieve NULL
--RUN all queries from Vocabulary-v5.0/working/Drug_stage_QA_optional.sql --All queries should retrieve NULL, but see comment inside



--06. stage tables checks (should retrieve NULL)
SELECT * FROM qa_tests.check_stage_tables ();



--07. GenericUpdate; devv5 - static variable
DO $_$
BEGIN
	PERFORM devv5.GenericUpdate();
END $_$;



--08. Basic tables checks

--08.1. QA checks (should retrieve NULL)
select * from QA_TESTS.GET_CHECKS();

--08.2. DRUG basic tables checks
--RUN all queries from Vocabulary-v5.working/Basic_tables_QA.sql --All queries should retrieve NULL

--08.3. New Vocabulary QA
--RUN all queries from Vocabulary-v5.0/working/CreateNewVocabulary_QA.sql --All queries should retrieve NULL



--09. Manual checks after generic
--09.1. RUN and review the results: https://github.com/OHDSI/Vocabulary-v5.0/blob/master/working/manual_checks_after_generic.sql

--09.2. Vocabulary-specific manual checks can be found in the manual_work directory in each vocabulary



--10. manual ConceptAncestor (needed vocabularies are to be specified)
/* DO $_$
 BEGIN
    PERFORM VOCABULARY_PACK.pManualConceptAncestor(
    pVocabularies => 'SNOMED,LOINC'
 );
 END $_$;*/



--11. get_summary - changes in tables between dev-schema (current) and devv5/prodv5/any other schema
--supported tables: concept, concept_relationship, concept_ancestor

--11.1. first clean cache
select * from qa_tests.purge_cache();

--11.2. summary (table to check, schema to compare)
select * from qa_tests.get_summary (table_name=>'concept',pCompareWith=>'devv5');

--11.3. summary (table to check, schema to compare)
select * from qa_tests.get_summary (table_name=>'concept_relationship',pCompareWith=>'devv5');

--11.4. summary (table to check, schema to compare)
select * from qa_tests.get_summary (table_name=>'concept_ancestor',pCompareWith=>'devv5');



--12. Statistics QA checks
--changes in tables between dev-schema (current) and devv5/prodv5/any other schema

--12.1. Domain changes
select * from qa_tests.get_domain_changes(pCompareWith=>'devv5');

--12.2. Newly added concepts grouped by vocabulary_id and domain
select * from qa_tests.get_newly_concepts(pCompareWith=>'devv5');

--12.3. Standard concept changes
select * from qa_tests.get_standard_concept_changes(pCompareWith=>'devv5');

--12.4. Newly added concepts and their standard concept status
select * from qa_tests.get_newly_concepts_standard_concept_status(pCompareWith=>'devv5');

--12.5. Changes of concept mapping status grouped by target domain
select * from qa_tests.get_changes_concept_mapping(pCompareWith=>'devv5');