-- int_insee_agg.sql
-- Objectif : Préparer les données INSEE pour la comparaison avec les étudiants
-- Grain : une ligne par combinaison région / tranche d'âge / genre / année

with insee as (

    select * from {{ ref('stg_insee') }}

),

aggregated as (

    select
        REGION,
        AGE_GROUP,
        GENDER,
        YEAR,
        SUM(POPULATION) as POPULATION_TOTALE

    from insee

    group by
        REGION,
        AGE_GROUP,
        GENDER,
        YEAR

)

select * from aggregated