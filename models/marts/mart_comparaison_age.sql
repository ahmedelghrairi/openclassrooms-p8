-- mart_comparaison_age.sql
-- Objectif : Comparer la répartition par tranche d'âge des étudiants
--            avec la population française
-- Répond à : "Certaines tranches d'âge sont-elles surreprésentées ?"
-- Grain : une ligne par tranche d'âge et par année

with students as (

    select * from {{ ref('int_students_agg') }}

),

insee as (

    select * from {{ ref('int_insee_agg') }}

),

-- Agrégation étudiants par tranche d'âge et année
-- On additionne toutes les régions et tous les genres
students_age as (

    select
        YEAR,
        AGE_GROUP,
        SUM(NB_INSCRIPTIONS) as NB_INSCRIPTIONS

    from students
    group by YEAR, AGE_GROUP

),

-- Agrégation INSEE au niveau national par tranche d'âge et année
-- On additionne toutes les régions et les deux genres
insee_age as (

    select
        YEAR,
        AGE_GROUP,
        SUM(POPULATION_TOTALE) as POPULATION_NATIONALE

    from insee
    group by YEAR, AGE_GROUP

),

-- Totaux annuels pour calculer les parts
total_students as (

    select YEAR, SUM(NB_INSCRIPTIONS) as TOTAL_INSCRIPTIONS
    from students_age
    group by YEAR

),

total_population as (

    select YEAR, SUM(POPULATION_NATIONALE) as TOTAL_POPULATION
    from insee_age
    group by YEAR

),

-- Table finale
final as (

    select
        s.YEAR,
        s.AGE_GROUP,

        -- Volume
        s.NB_INSCRIPTIONS,
        i.POPULATION_NATIONALE,

        -- Part de cette tranche dans nos étudiants
        ROUND(
            s.NB_INSCRIPTIONS
            / NULLIF(ts.TOTAL_INSCRIPTIONS, 0)
            * 100, 1
        )                           as PART_ETUDIANTS_PCT,

        -- Part de cette tranche dans la population française
        ROUND(
            i.POPULATION_NATIONALE
            / NULLIF(tp.TOTAL_POPULATION, 0)
            * 100, 1
        )                           as PART_POPULATION_PCT,

        -- Écart : positif = surreprésentée, négatif = sous-représentée
        ROUND(
            (s.NB_INSCRIPTIONS / NULLIF(ts.TOTAL_INSCRIPTIONS, 0) * 100)
            - (i.POPULATION_NATIONALE / NULLIF(tp.TOTAL_POPULATION, 0) * 100)
        , 1)                        as ECART_PCT

    from students_age s
    left join insee_age i
        on  s.AGE_GROUP = i.AGE_GROUP
        and s.YEAR      = i.YEAR
    left join total_students ts
        on  s.YEAR = ts.YEAR
    left join total_population tp
        on  s.YEAR = tp.YEAR

)

select * from final
order by YEAR, AGE_GROUP