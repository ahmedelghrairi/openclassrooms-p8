-- mart_evolution_annuelle.sql
-- Objectif : Analyser l'évolution globale des inscriptions par année
-- Répond à : "Comment évolue le profil global sur 4 ans ?"
-- Grain : une ligne par année

with students as (

    select * from {{ ref('int_students_agg') }}

),

evolution as (

    select
        YEAR,

        -- Volume total d'inscriptions par année
        SUM(NB_INSCRIPTIONS)                                as NB_INSCRIPTIONS_TOTAL,

        -- Part des femmes parmi les genres renseignés uniquement
        -- On exclut les "Non renseigné" pour ne pas fausser le pourcentage
        ROUND(
            SUM(CASE WHEN GENDER = 'F' THEN NB_INSCRIPTIONS ELSE 0 END)
            / NULLIF(SUM(CASE WHEN GENDER IN ('F','M') THEN NB_INSCRIPTIONS ELSE 0 END), 0)
            * 100, 1
        )                                                   as PART_FEMMES_PCT,

        -- Part des hommes parmi les genres renseignés uniquement
        ROUND(
            SUM(CASE WHEN GENDER = 'M' THEN NB_INSCRIPTIONS ELSE 0 END)
            / NULLIF(SUM(CASE WHEN GENDER IN ('F','M') THEN NB_INSCRIPTIONS ELSE 0 END), 0)
            * 100, 1
        )                                                   as PART_HOMMES_PCT,

        -- Part des genres non renseignés sur le total
        -- Indicateur de qualité des données : doit diminuer dans le temps
        ROUND(
            SUM(CASE WHEN GENDER = 'Non renseigné' THEN NB_INSCRIPTIONS ELSE 0 END)
            / NULLIF(SUM(NB_INSCRIPTIONS), 0)
            * 100, 1
        )                                                   as PART_NON_RENSEIGNE_PCT,

        -- Part de l'Île-de-France dans le total national
        -- Indicateur d'accessibilité géographique
        ROUND(
            SUM(CASE WHEN REGION = 'Île-de-France' THEN NB_INSCRIPTIONS ELSE 0 END)
            / NULLIF(SUM(NB_INSCRIPTIONS), 0)
            * 100, 1
        )                                                   as PART_IDF_PCT

    from students
    group by YEAR

)

select * from evolution
order by YEAR