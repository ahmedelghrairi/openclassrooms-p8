# Projet P8 — Analyse sociodémographique des étudiants Data OpenClassrooms

## Contexte
Analyse de l'évolution du profil sociodémographique des étudiants 
inscrits aux parcours Data sur 4 ans (2022-2025).

## Sources de données
- Données internes OpenClassrooms (4 647 inscriptions)
- INSEE — population par région/âge/genre
- INSEE/France Travail — taux de chômage régional

## Architecture DBT
3 couches : Staging → Intermediate → Marts
3 sources → 10 modèles → 4 tables analytiques

## Comment exécuter le pipeline
1. Charger les données dans Snowflake (RAW.*)
2. dbt run
3. dbt test

## Auteur
Ahmed El Ghrairi — Formation Data Analyst OpenClassrooms — Avril 2026