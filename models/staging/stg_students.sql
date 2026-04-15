-- stg_students.sql
-- Objectif : Nettoyer et standardiser les données brutes des étudiants
-- Source : OPENCLASSROOMS_DB.RAW.STUDENTS_DATA

with source as (

    select * from {{ source('raw', 'students_data') }}

),

cleaned as (

    select
        USER_ID,
        PATH_CATEGORY_NAME,
        AGE_GROUP,

        -- Remplacer les valeurs nulles du genre par 'Non renseigné'
        COALESCE(GENDER, 'Non renseigné') as GENDER,

        REGION,
        YEAR_PATH_STARTED

    from source

    -- Exclure les lignes sans USER_ID (données non identifiables)
    where USER_ID is not null

)

select * from cleaned