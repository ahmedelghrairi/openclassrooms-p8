-- stg_insee.sql
-- Objectif : Nettoyer et standardiser les données brutes INSEE
-- Source : OPENCLASSROOMS_DB.RAW.INSEE_POPULATION

with source as (

    select * from {{ source('raw', 'insee_population') }}

),

cleaned as (

    select
        REGION,
        AGE_GROUP,
        GENDER,
        YEAR,
        POPULATION

    from source

    -- Exclure les lignes avec une population nulle ou négative
    where POPULATION is not null
      and POPULATION > 0

)

select * from cleaned