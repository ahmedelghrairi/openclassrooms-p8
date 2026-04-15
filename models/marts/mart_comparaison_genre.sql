-- mart_comparaison_genre.sql
-- Objectif : Comparer la répartition par genre des étudiants
--            avec la population française
-- Répond à : "Les femmes sont-elles sous-représentées et est-ce que ça s'améliore ?"
-- Grain : une ligne par genre et par année

with students as (

    select * from {{ ref('int_students_agg') }}

),

insee as (

    select * from {{ ref('int_insee_agg') }}

),

-- Agrégation étudiants par genre et année
-- On exclut les "Non renseigné" pour la comparaison avec l'INSEE
-- car l'INSEE ne connaît pas cette catégorie
students_genre as (

    select
        YEAR,
        GENDER,
        SUM(NB_INSCRIPTIONS) as NB_INSCRIPTIONS

    from students
    where GENDER in ('F', 'M')
    group by YEAR, GENDER

),

-- Agrégation INSEE au niveau national par genre et année
-- On additionne toutes les régions et toutes les tranches d'âge
insee_genre as (

    select
        YEAR,
        GENDER,
        SUM(POPULATION_TOTALE) as POPULATION_NATIONALE

    from insee
    group by YEAR, GENDER

),

-- Totaux annuels pour calculer les parts
total_students as (

    select YEAR, SUM(NB_INSCRIPTIONS) as TOTAL_INSCRIPTIONS
    from students_genre
    group by YEAR

),

total_population as (

    select YEAR, SUM(POPULATION_NATIONALE) as TOTAL_POPULATION
    from insee_genre
    group by YEAR

),

-- Table finale
final as (

    select
        s.YEAR,
        s.GENDER,

        -- Volume
        s.NB_INSCRIPTIONS,
        i.POPULATION_NATIONALE,

        -- Part de ce genre dans nos étudiants (hors non renseigné)
        ROUND(
            s.NB_INSCRIPTIONS
            / NULLIF(ts.TOTAL_INSCRIPTIONS, 0)
            * 100, 1
        )                           as PART_ETUDIANTS_PCT,

        -- Part de ce genre dans la population française
        ROUND(
            i.POPULATION_NATIONALE
            / NULLIF(tp.TOTAL_POPULATION, 0)
            * 100, 1
        )                           as PART_POPULATION_PCT,

        -- Écart : positif = surreprésenté, négatif = sous-représenté
        ROUND(
            (s.NB_INSCRIPTIONS / NULLIF(ts.TOTAL_INSCRIPTIONS, 0) * 100)
            - (i.POPULATION_NATIONALE / NULLIF(tp.TOTAL_POPULATION, 0) * 100)
        , 1)                        as ECART_PCT

    from students_genre s
    left join insee_genre i
        on  s.GENDER = i.GENDER
        and s.YEAR   = i.YEAR
    left join total_students ts
        on  s.YEAR = ts.YEAR
    left join total_population tp
        on  s.YEAR = tp.YEAR

)

select * from final
order by YEAR, GENDER