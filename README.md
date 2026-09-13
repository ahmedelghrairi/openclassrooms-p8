# Analyse de l'évolution du profil sociodémographique des étudiants Data — OpenClassrooms

OpenClassrooms veut savoir si son parcours Data est réellement accessible à tous. La direction pédagogique demande un pipeline dbt documenté et reproductible pour suivre l'évolution du profil des étudiants sur quatre ans (2022-2025), en le comparant à la population française à partir de données INSEE.

Étude de cas complète, avec démarche et recommandations : [voir sur mon portfolio](https://ahmedelghrairi.github.io/projets/profil-etudiants.html)

## Contenu du dépôt

- `models/staging/` : déclaration des trois sources et nettoyage (`stg_students`, `stg_insee`, `stg_chomage`)
- `models/intermediate/` : agrégation des trois sources au même grain région / tranche d'âge / genre / année
- `models/marts/` : quatre tables analytiques (`mart_comparaison_age`, `mart_comparaison_genre`, `mart_comparaison_region`, `mart_evolution_annuelle`)
- `dbt_project.yml`, `models/staging/sources.yml` : configuration du projet et des sources
- un fichier `.yml` de tests et de documentation à côté de chaque modèle `.sql`
- `data_exportee/` : les quatre tables finales exportées en CSV (mart_evolution_annuelle, mart_comparaison_age, mart_comparaison_genre, mart_comparaison_region), le livrable de données demandé par la consigne.

## Les données

Trois sources croisées sur la période 2022-2025 : les inscriptions internes OpenClassrooms au parcours Data (4 647 lignes, avec identifiant pseudonymisé, tranche d'âge, genre déclaré, région et année de début), la population française par région/âge/genre (INSEE), et le taux de chômage régional (INSEE/France Travail). Le genre n'est pas renseigné pour environ 27 % des inscriptions sur l'ensemble de la période, une donnée manquante que le pipeline traite explicitement plutôt que de l'ignorer.

**RGPD.** L'identifiant étudiant est une donnée pseudonymisée qui ne sert qu'à compter les inscriptions. Il disparaît dès la couche intermediate, où les données sont agrégées par région, tranche d'âge, genre et année : aucune des tables analytiques finales ne permet de remonter à un individu. Les données INSEE et France Travail, publiques, ne sont soumises à aucune contrainte RGPD.

## La démarche

Architecture en trois couches, une source dbt par table brute. La couche staging nettoie et documente chaque source séparément : les genres manquants sont remplacés par "Non renseigné" plutôt que supprimés, pour ne pas fausser les volumes totaux, et les tranches d'âge INSEE, plus fines que celles du dataset étudiant, sont regroupées pour correspondre exactement à sa granularité.

La couche intermediate agrège les trois sources au même grain, région / tranche d'âge / genre / année. C'est l'étape où l'identifiant étudiant individuel disparaît, remplacé par des comptages : c'est le point de conformité RGPD du pipeline, documenté comme tel dans chaque fichier de configuration.

Les quatre tables de la couche marts répondent chacune à une question métier précise : l'évolution globale d'une année sur l'autre, la comparaison des étudiants à la population française par âge, par genre, et par région avec un indicateur normalisé (inscriptions pour 100 000 habitants) pour comparer équitablement des régions de tailles différentes, et le lien entre chômage régional et inscriptions.

Chaque colonne de chaque modèle est testée : `not_null` partout, `accepted_values` sur les colonnes catégorielles pour détecter tout changement inattendu dans les données sources dès le prochain `dbt run`.

## Quelques résultats

- Les inscriptions chutent de 50 % entre 2022 et 2024, avant un premier rebond de 12 % en 2025.
- Les femmes représentent environ 30 % des inscrits, contre 52 % de la population française : un écart stable sur les quatre années, sans amélioration mesurable.
- L'Île-de-France concentre 41 à 54 % des inscriptions selon les années, avec un taux d'inscription pour 100 000 habitants trois fois supérieur à toutes les autres régions.
- Aucune corrélation entre le taux de chômage régional et le volume d'inscriptions : les régions les plus touchées par le chômage ne se reconvertissent pas davantage vers la Data, un signal qui interroge l'accessibilité réelle de la formation au-delà de son coût.

## Outils

dbt, Snowflake, SQL.

Ahmed El Ghrairi, 2026.
