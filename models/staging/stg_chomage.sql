-- stg_chomage.sql
-- Objectif : Nettoyer et standardiser les données de taux de chômage par région
-- Source : OPENCLASSROOMS_DB.RAW.CHOMAGE_REGIONS

with source as (

    select * from {{ source('raw', 'chomage_regions') }}

),

cleaned as (

    select
        REGION,
        YEAR,
        TAUX_CHOMAGE_PCT

    from source

    -- Exclure les lignes avec un taux nul ou négatif (données aberrantes)
    where TAUX_CHOMAGE_PCT is not null
      and TAUX_CHOMAGE_PCT > 0

)

select * from cleaned