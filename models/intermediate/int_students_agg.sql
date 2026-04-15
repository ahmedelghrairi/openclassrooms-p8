-- int_students_agg.sql
-- Objectif : Agréger les inscriptions des étudiants par dimension sociodémographique
-- Grain : une ligne par combinaison région / tranche d'âge / genre / année

with students as (

    select * from {{ ref('stg_students') }}

),

aggregated as (

    select
        REGION,
        AGE_GROUP,
        GENDER,
        YEAR_PATH_STARTED                    as YEAR,
        COUNT(*)                             as NB_INSCRIPTIONS,
        COUNT(DISTINCT USER_ID)              as NB_ETUDIANTS_DISTINCTS

    from students

    group by
        REGION,
        AGE_GROUP,
        GENDER,
        YEAR_PATH_STARTED

)

select * from aggregated