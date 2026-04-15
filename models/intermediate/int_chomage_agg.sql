-- int_chomage_agg.sql
-- Objectif : Préparer les données de chômage pour la jointure avec les étudiants
-- Grain : une ligne par région et par année

with chomage as (

    select * from {{ ref('stg_chomage') }}

),

final as (

    select
        REGION,
        YEAR,
        TAUX_CHOMAGE_PCT

    from chomage

)

select * from final