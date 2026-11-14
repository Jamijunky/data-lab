# Iteration 12: Taxi Zone Enrichment and Borough-Level Analysis

## Objective

The objective of this iteration is to enrich NYC Yellow Taxi trip records with geographical information using the official Taxi Zone Lookup dataset.

The trip dataset contains `PULocationID` and `DOLocationID`. These columns identify pickup and drop-off taxi zones through numeric IDs. However, the IDs alone do not provide meaningful geographical descriptions.

The lookup dataset provides the corresponding borough, zone name, and service-zone classification.

By joining these datasets, we can move from analyzing numeric location identifiers to analyzing actual geographical areas.

## Understanding Reference Data

Reference data provides descriptive information about values stored in another dataset.

In this case, the trip dataset stores taxi zone IDs, while the lookup dataset maps each ID to its geographical description.

The lookup table is not another collection of taxi trips. It is a separate dataset that provides context for interpreting the existing trip records.

This process is called data enrichment because additional descriptive information is attached to the original records without changing the meaning of the original trip measurements.

## Understanding Lookup Tables and Joins

A lookup table commonly contains a key that connects it to another dataset.

Here, `LocationID` is the key in the lookup table. It corresponds to both `PULocationID` and `DOLocationID` in the trip dataset.

Two joins are required because a trip has two geographical endpoints.

The first join maps `PULocationID` to the pickup zone. The second maps `DOLocationID` to the drop-off zone.

Both are LEFT JOIN operations because we want to preserve the original trip records even if a location ID does not have a matching lookup entry.

An INNER JOIN would discard records without matching locations, potentially hiding data quality issues.

## Pickup and Drop-off Enrichment

After joining the lookup table, each trip can contain:

- Pickup borough and zone.
- Drop-off borough and zone.
- Pickup service-zone classification.
- Drop-off service-zone classification.

This makes it possible to interpret trip movements geographically.

For example, instead of reporting that a particular numeric location ID has high pickup demand, we can report its corresponding zone and borough.

## Borough-Level Analysis

Grouping enriched records by borough provides a broader geographical view.

The analysis can compare pickup and drop-off counts across boroughs, helping identify where taxi trips begin and end.

However, pickup and drop-off counts describe trip endpoints, not the number of unique passengers or the total number of taxis operating in a borough.

The analysis should also preserve trips whose pickup and drop-off boroughs differ. These trips provide information about movement between geographical areas.

## Zone-Level Analysis

Borough-level aggregation can hide substantial variation between individual zones.

Zone-level analysis provides a more detailed view of pickup demand, drop-off demand, and trip connections.

The most frequently used pickup zones and drop-off zones can be identified after joining the lookup table.

The analysis can also identify common origin-destination pairs using readable zone names rather than numeric IDs.

## Origin-Destination Analysis

An origin-destination pair represents the starting and ending locations of a trip.

For example, a trip from one Manhattan zone to another Manhattan zone is different from a trip connecting Manhattan and Queens.

Grouping by pickup borough and drop-off borough reveals broader movement patterns.

Grouping by individual pickup and drop-off zones provides more detailed information about common routes.

These are trip counts, not direct measurements of road traffic or passenger demand.

## Lookup Integrity and Unmatched Records

Reference data must be validated before it is used for enrichment.

The lookup table should be checked for duplicate `LocationID` values because duplicate keys can multiply records during a join.

The trip dataset should also be checked for location IDs that do not exist in the lookup table.

NULL location IDs and unmatched non-NULL IDs are different cases. A NULL means that the trip record does not provide a location identifier. An unmatched ID means an identifier was provided but no corresponding lookup row was found.

Both should be reported separately.

## Enriched Dataset

The joined dataset can be written to a separate Parquet file.

The original duration-cleaned dataset remains unchanged. The enriched dataset adds descriptive geographical columns while retaining the original trip fields.

This demonstrates a basic data transformation pattern:

Raw trip data + Reference data = Enriched analytical data.

The enriched output can be reused for later analysis without repeating the geographical joins.

## Analytical Conclusions

This iteration demonstrates how reference datasets make numerical identifiers useful for analytical interpretation.

The lookup join allows pickup and drop-off locations to be analyzed by borough, zone, and service-zone classification.

Borough-level aggregation provides a broad geographical overview, while zone-level and origin-destination analysis reveal more detailed movement patterns.

The audit of lookup keys and unmatched IDs is essential because an incorrect join can silently produce duplicated or missing analytical records.

## Limitations

Taxi zones approximate neighborhoods and should not be treated as exact administrative neighborhood boundaries.

Borough-level trip counts represent the number of recorded trip endpoints, not the total number of passengers or available taxis.

The analysis uses January 2025 Yellow Taxi trip records and does not represent other transportation services.

The lookup table provides geographical labels but does not provide the actual geographical boundaries needed for spatial calculations or mapping.

## Learning Reflection

This iteration introduces reference data, lookup tables, relational joins, and data enrichment.

It demonstrates how separate datasets can be combined to improve the analytical usefulness of existing records.

It also reinforces the importance of validating join keys, preserving unmatched records, and checking whether joins change the number of records unexpectedly.

The next iteration will focus on advanced analytical SQL techniques and more complex query construction.

## Implementation and Validation

The official TLC Taxi Zone Lookup CSV was downloaded and joined with the duration-cleaned trip dataset.

Two LEFT JOIN operations were used: one to enrich pickup locations and another to enrich drop-off locations.

The resulting dataset was written to:

`data/processed/yellow_tripdata_2025-01_enriched.parquet`

The enriched dataset was designed to retain all original trip records. Record counts and lookup coverage should be checked to ensure that duplicate lookup keys have not multiplied records and that unmatched locations are identified.

The enriched dataset makes borough-level, zone-level, and origin-destination analysis possible without repeatedly performing the lookup joins.

The original duration-cleaned dataset remains unchanged.
