-- mart_comparaison_region.sql
-- Objectif : Comparer la répartition régionale des étudiants
--            avec la population française et le taux de chômage
-- Répond à : "Certaines régions sont-elles sur/sous-représentées ?"
--            "Y a-t-il un lien entre chômage et inscriptions ?"
-- Grain : une ligne par région et par année

with students as (

    select * from {{ ref('int_students_agg') }}

),

insee as (

    select * from {{ ref('int_insee_agg') }}

),

chomage as (

    select * from {{ ref('int_chomage_agg') }}

),

-- Agrégation étudiants par région et année
-- On additionne toutes les tranches d'âge et tous les genres
students_region as (

    select
        REGION,
        YEAR,
        SUM(NB_INSCRIPTIONS) as NB_INSCRIPTIONS

    from students
    group by REGION, YEAR

),

-- Agrégation INSEE au niveau régional
-- On additionne toutes les tranches d'âge et les deux genres
insee_region as (

    select
        REGION,
        YEAR,
        SUM(POPULATION_TOTALE) as POPULATION_REGIONALE

    from insee
    group by REGION, YEAR

),

-- Totaux nationaux pour calculer les parts
total_students as (

    select YEAR, SUM(NB_INSCRIPTIONS) as TOTAL_INSCRIPTIONS
    from students_region
    -- On exclut les DROM car pas de données INSEE correspondantes
    where REGION != 'DROM'
    group by YEAR

),

total_population as (

    select YEAR, SUM(POPULATION_REGIONALE) as TOTAL_POPULATION
    from insee_region
    group by YEAR

),

-- Table finale
final as (

    select
        s.REGION,
        s.YEAR,

        -- Volume
        s.NB_INSCRIPTIONS,
        p.POPULATION_REGIONALE,

        -- Part de la région dans nos étudiants
        ROUND(
            s.NB_INSCRIPTIONS
            / NULLIF(ts.TOTAL_INSCRIPTIONS, 0)
            * 100, 1
        )                                           as PART_ETUDIANTS_PCT,

        -- Part de la région dans la population française
        ROUND(
            p.POPULATION_REGIONALE
            / NULLIF(tp.TOTAL_POPULATION, 0)
            * 100, 1
        )                                           as PART_POPULATION_PCT,

        -- Écart de représentation
        -- Positif = surreprésentée, négatif = sous-représentée
        ROUND(
            (s.NB_INSCRIPTIONS / NULLIF(ts.TOTAL_INSCRIPTIONS, 0) * 100)
            - (p.POPULATION_REGIONALE / NULLIF(tp.TOTAL_POPULATION, 0) * 100)
        , 1)                                        as ECART_PCT,

        -- Taux normalisé pour comparer équitablement les régions
        -- Nombre d'inscriptions pour 100 000 habitants
        ROUND(
            s.NB_INSCRIPTIONS
            / NULLIF(p.POPULATION_REGIONALE, 0)
            * 100000, 1
        )                                           as TAUX_INSCRIPTIONS_100K,

        -- Taux de chômage annuel moyen de la région
        c.TAUX_CHOMAGE_PCT

    from students_region s
    -- Left join pour garder les DROM même sans données INSEE
    left join insee_region p
        on  s.REGION = p.REGION
        and s.YEAR   = p.YEAR
    left join chomage c
        on  s.REGION = c.REGION
        and s.YEAR   = c.YEAR
    left join total_students ts
        on  s.YEAR = ts.YEAR
    left join total_population tp
        on  s.YEAR = tp.YEAR

)

select * from final
order by YEAR, REGION