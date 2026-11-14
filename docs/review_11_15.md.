# Learning Review: Iterations 11–15

## Why did we perform a separate data quality audit after already cleaning the dataset?

By Iteration 11, we had already performed several analyses involving trip duration, distance, financial values, and other characteristics. However, the earlier cleaning operation had only addressed a specific problem: invalid trip durations. It did not mean that every other column in the dataset was now reliable.

We therefore performed a broader data quality audit to examine completeness, validity, consistency, and unusual values across multiple columns. This helped me understand that data quality is not a single condition that can be established through one cleaning operation. A dataset can have valid timestamps but suspicious distances, complete monetary fields but inconsistent financial components, or valid numerical values that are still unrealistic in the context of the business.

The purpose of this audit was to examine these conditions systematically rather than assuming that the duration-cleaned dataset was completely clean. It also helped us separate the process of identifying quality problems from the process of deciding which records should actually be removed.

## What is the difference between completeness, validity, consistency, and uniqueness?

During the audit, we examined different dimensions of data quality. Completeness concerns whether required values are present. For example, a missing `passenger_count` represents a completeness issue, although whether that field is mandatory depends on the intended analysis.

Validity concerns whether a value satisfies an expected rule or domain. A negative trip duration, for example, is invalid under the chronological definition of a trip. Similarly, a numerical value can be valid according to its data type but still be suspicious according to the business context.

Consistency concerns whether related values agree with each other. For example, the recorded `total_amount` should be reasonably reconcilable with its individual fare components under the applicable calculation rules. Uniqueness concerns whether records that should be distinct actually are distinct, or whether duplicate records exist.

I learned that these dimensions are related but not interchangeable. A record can be complete but invalid, valid but duplicated, or individually valid while being inconsistent with another column. This is why a proper data quality audit needs multiple independent checks.

## Why did we examine timestamp validity separately from trip duration?

We already had a derived `trip_duration_minutes` column, but the audit revisited the underlying timestamps to verify their relationship. Trip duration is calculated from pickup and drop-off timestamps, so the chronological order of those timestamps determines whether the duration is valid.

We used the condition `tpep_dropoff_datetime >= tpep_pickup_datetime` to identify records with valid chronological ordering. This is different from checking whether a derived duration happens to be positive after some transformation. By examining the original timestamps, we can validate the source values and the logic used to derive the duration.

We also considered whether the calculated duration was consistent with the difference between the two timestamps. This is important because derived columns can contain errors if the transformation logic is incorrect. A correct-looking output column does not automatically guarantee that the underlying calculation was performed correctly.

## Why did we use domain checks for numerical columns?

A numerical column can contain values that are technically valid numbers but do not make sense for the analysis. For example, `trip_distance` may be stored as a floating-point number, but a negative distance is not meaningful under the usual interpretation of this field.

We therefore examined conditions such as negative fare amounts, negative total amounts, zero distances, missing passenger counts, and other unusual numerical values. These checks helped us identify records that required further investigation.

However, I learned that a domain check should not be confused with an automatic deletion rule. A negative fare may be unusual but could represent a financial adjustment, while a zero distance may represent a cancelled or otherwise unusual transaction. The correct treatment depends on the meaning of the field and the purpose of the analysis.

## Why did we avoid adding all quality-flag counts together?

One important detail in the audit was that quality conditions can overlap. A single record might have a negative fare, zero distance, and an unusually short duration at the same time. If we count each condition independently and add the results, that record may be counted multiple times.

For this reason, the number of records satisfying individual quality checks cannot automatically be interpreted as the total number of bad records. To calculate a unique total, we would need to define a combined row-level condition and count records satisfying at least one of the selected conditions.

We also created consolidated quality flags to represent multiple conditions at the record level. This made it possible to inspect records with several simultaneous issues without losing the distinction between the individual reasons for flagging them.

This helped me understand the difference between counting anomalies by category and counting unique records containing anomalies. Both are useful, but they answer different questions.

## Why did we investigate duplicate-looking records instead of immediately deleting them?

During data quality analysis, records that look identical can indicate duplication, but identical-looking values do not always prove that the underlying events are duplicates. Two legitimate taxi trips could have the same pickup location, drop-off location, fare, distance, and timestamps at the available precision.

We therefore used a composite set of columns to identify candidate duplicate groups. This approach helped us locate repeated combinations of values for further investigation.

The important distinction is between a duplicate candidate and a confirmed duplicate. To establish that a record is truly duplicated, we need to understand the uniqueness rules of the source system or have a reliable transaction identifier. Without that information, deleting repeated-looking rows could remove legitimate trips.

## Why did we enrich taxi records using a separate location lookup table?

In Iteration 12, we moved from auditing individual records to making the geographical analysis more meaningful. The original trip dataset contained `PULocationID` and `DOLocationID`, which were numerical identifiers rather than descriptive location names.

We downloaded the NYC TLC taxi zone lookup table and used it to map these identifiers to zone names, boroughs, and service-zone categories. This is an example of data enrichment: adding descriptive information from a separate reference dataset to the original transactional records.

We first needed to validate the lookup table itself. In particular, the `LocationID` column needed to be unique. If a lookup table contains multiple rows for the same key, joining it to the trip dataset can multiply records and distort subsequent aggregations.

This taught me that validating reference data is just as important as validating the main dataset. A join can execute successfully while still producing incorrect results if the join keys are not unique or the mapping is incomplete.

## Why did we use LEFT JOINs when enriching pickup and drop-off locations?

We used `LEFT JOIN` to attach pickup and drop-off information while preserving the original trip records. The trip dataset was the primary dataset, and the lookup table supplied additional descriptive information.

An inner join would remove trips whose location identifiers did not match the lookup table. That might be appropriate for a particular analysis, but it would change the number of records. A left join preserves the left-side records and returns `NULL` for unmatched lookup values.

This was particularly important because we wanted to verify whether enrichment changed the total number of trips. If the lookup keys were unique, each trip should match at most one pickup location and at most one drop-off location. The enriched record count should therefore remain equal to the cleaned record count.

We also checked unmatched location identifiers rather than assuming that every identifier would have a corresponding lookup entry. This helped me understand that a successful join is not sufficient validation. We must examine record counts, key uniqueness, and unmatched values after the join.

## Why did we perform borough-level analysis after enriching the dataset?

Once the trip records contained borough and zone information, we could move beyond numerical location identifiers and examine geographical patterns at different levels.

Zone-level analysis provides detailed information about individual taxi zones, while borough-level analysis aggregates multiple zones into larger geographical areas. These two levels answer different questions. Zone-level analysis can identify specific high-demand locations, whereas borough-level analysis provides a broader comparison of activity across geographical regions.

We also examined pickup and drop-off activity by borough and compared borough-to-borough origin-destination combinations. This connected the earlier location analysis with the new reference data.

I learned that enrichment is not simply about making a dataset easier to read. It changes the kinds of questions we can answer. Without borough information, we can count trips by zone identifier. With borough information, we can compare larger geographical regions and investigate the movement of trips between them.

## Why did we study CTEs and window functions in Iteration 13?

After completing several analyses using filtering, grouping, aggregation, and joins, we moved towards more advanced analytical SQL. The main objective was to understand how SQL can perform calculations across related rows without reducing the entire dataset to one row per group.

Common Table Expressions, or CTEs, allow us to divide a complex query into named logical steps. Instead of writing one large query with deeply nested subqueries, we can define intermediate results and use them in subsequent operations. This improves readability and makes analytical logic easier to reason about.

Window functions solve a different problem. A normal `GROUP BY` produces aggregated rows, whereas a window function calculates a value across a related set of rows while retaining the individual rows in the result. This makes window functions useful for ranking, running totals, comparisons with group averages, and changes between consecutive observations.

Understanding the distinction between aggregation and window calculations was one of the most important lessons of this iteration.

## What is the difference between ROW_NUMBER, RANK, and DENSE_RANK?

We used ranking functions to identify top taxi zones and compare their demand within boroughs. These functions look similar, but they behave differently when multiple rows have the same ranking value.

`ROW_NUMBER()` assigns a unique sequential number to each row, even when multiple rows have identical values in the ordering column. `RANK()` assigns the same rank to tied rows but leaves gaps in the subsequent ranking numbers. `DENSE_RANK()` also assigns the same rank to tied rows, but does not leave gaps.

For example, if three zones have trip counts of 100, 100, and 80, their rankings would be:

| Zone | Trips | ROW_NUMBER | RANK | DENSE_RANK |
|---|---:|---:|---:|---:|
| A | 100 | 1 | 1 | 1 |
| B | 100 | 2 | 1 | 1 |
| C | 80 | 3 | 3 | 2 |

This difference matters when defining a top-N analysis. If we want exactly five rows per borough, `ROW_NUMBER()` is appropriate, provided the ordering is deterministic. If we want all zones tied within the top five ranks, `RANK()` or `DENSE_RANK()` may be more appropriate depending on whether gaps should count.

I learned that choosing a ranking function is not just a syntax decision. It depends on the exact meaning of top-N that the analysis requires.

## Why did we use PARTITION BY in window functions?

`PARTITION BY` divides the rows into independent groups for window calculations. It is similar to grouping data conceptually, but it does not collapse the rows into one result per group.

For example, when ranking pickup zones within each borough, we partition the data by borough and order the zones by their pickup counts. Each borough receives its own ranking sequence rather than all zones competing in one global ranking.

This is useful because many analytical questions are relative to a group. We might want to compare a zone with other zones in the same borough, calculate a borough-level average for each trip, or calculate a running total separately for each category.

The important distinction is that `GROUP BY` changes the granularity of the result, while `PARTITION BY` defines the groups over which a window function operates without necessarily changing that granularity.

## What do LAG and LEAD allow us to calculate?

We used `LAG()` to access a value from a preceding row within an ordered window. This is useful for comparing the current observation with the previous observation without joining a table to itself.

For example, when examining daily taxi demand, we can use `LAG(trip_count)` to retrieve the previous day's trip count. We can then calculate the absolute difference or percentage change between consecutive days.

The ordering is essential. Without a meaningful `ORDER BY`, the concept of a previous row is not well-defined. We also need to decide what defines the sequence. For daily demand, it should be the date; for hourly demand, it might be the hour within a particular day.

`LEAD()` performs the corresponding operation in the forward direction by accessing a subsequent row. These functions are useful for time-series analysis, trend comparisons, and detecting changes between consecutive observations.

## Why did we calculate running totals and cumulative demand?

A running total accumulates values as we move through an ordered sequence of rows. We used this concept to understand how daily trip demand accumulated over time.

A normal daily aggregation gives the number of trips on each day independently. A running total adds each day's demand to the accumulated demand from all preceding days. This allows us to understand cumulative activity across the selected period.

The ordering and window frame matter because they determine which rows contribute to the running calculation. If the data is not ordered correctly, the result will not represent the intended progression through time.

This helped me understand that window functions are not limited to ranking. They can also preserve individual observations while adding contextual information about preceding rows and cumulative values.

## Why did we compare individual zones with their borough averages?

A zone's trip count is easier to interpret when compared with the broader group to which it belongs. A zone with 10,000 trips might be highly active in one borough but relatively ordinary in another.

We therefore used window calculations to derive borough-level averages and compare individual zone demand against those averages. This allowed us to examine how each zone performed relative to its own borough instead of comparing every zone against one global average.

This is an example of contextual analysis. A numerical value does not always have meaning on its own. Comparing it with an appropriate reference group can make the result more informative.

## Why did we introduce a repeatable Python and DuckDB pipeline in Iteration 14?

Until this point, much of our work involved writing and executing SQL queries manually. This was useful for learning analytical concepts, but repeating the same preparation steps manually is inefficient and increases the chance of inconsistent execution.

In Iteration 14, we moved towards a repeatable local pipeline using Python and DuckDB. The Python script handled input validation, execution of the data preparation logic, output generation, and validation of the resulting datasets.

We used `pathlib` to construct paths relative to the script's location rather than depending entirely on the current working directory. This makes the script easier to run from different locations within the repository.

DuckDB handled the Parquet reading, filtering, joining, and writing operations. This allowed us to use SQL for data transformations while Python coordinated the overall execution.

The important learning was that a data pipeline is not simply a large SQL query. It is an organized sequence of operations with defined inputs, transformations, outputs, and validation checks.

## Why did we validate input files before running the pipeline?

A pipeline depends on assumptions about its input data. If the expected Parquet file is missing, a required column has changed, or the location lookup contains duplicate identifiers, the transformation may fail or produce incorrect output.

We therefore added input validation before performing the transformations. The script checked that the expected input files and required columns were available and that the lookup table did not contain duplicate `LocationID` values.

This helped me understand the importance of failing early. It is better for a pipeline to detect an invalid input and stop with a clear error than to continue processing and produce an output that looks valid but is incorrect.

Input validation also makes the pipeline's assumptions explicit. Anyone running the script can understand what the process expects before it begins.

## What does idempotency mean, and how did we approach it?

Idempotency means that repeating an operation with the same inputs should produce the same intended final state, rather than creating additional unintended effects each time it runs.

Our pipeline generated cleaned and enriched Parquet files. A repeated execution should regenerate these outputs instead of failing because the destination files already exist or accidentally appending duplicate data.

DuckDB's `COPY` operation does not automatically overwrite an existing output file in the way our initial implementation expected. We therefore modified the script to remove existing generated outputs before recreating them.

This gave us a basic repeatable regeneration workflow for our local pipeline. However, it is important to recognize its limitation: deleting the previous outputs before generating replacements is not an atomic operation. If the script fails after deleting the old files but before successfully writing the new ones, the outputs may be missing.

This helped me understand that idempotency is a design property, not merely a matter of rerunning a script. A more robust production pipeline would use temporary outputs, validation, and controlled replacement so that a failed run does not destroy the last known-good outputs.

## Why did we validate the cleaned and enriched outputs separately?

The pipeline produced two different outputs: a duration-cleaned dataset and an enriched dataset containing geographical information.

The cleaned dataset was expected to contain only January pickup records with valid chronological pickup and drop-off timestamps. The enriched dataset was expected to contain the same trips with additional pickup and drop-off location attributes.

We needed to validate both outputs because they represent different stages of processing. For the cleaned dataset, we checked whether the filtering logic produced an appropriate record count. For the enriched dataset, we checked whether the number of records remained equal to the cleaned dataset's count.

The expected relationship was that enrichment should not change the number of trips when the lookup keys are unique and the joins are one-to-one or many-to-one. We also needed to inspect unmatched location values rather than assuming that every location identifier had been mapped successfully.

This reinforced an important data engineering principle: generating an output is not the same as validating it. A pipeline should verify that its outputs satisfy the expected structural and logical conditions.

## Why did we perform a final analytical synthesis in Iteration 15?

After completing the earlier analytical and engineering iterations, we needed to bring the findings together instead of leaving them scattered across individual SQL files and learning journals.

The final synthesis revisited overall dataset statistics, borough-level demand, top pickup zones, hourly and weekday patterns, origin-destination combinations, rate code distributions, financial summaries, and data quality indicators.

The purpose was to connect the different dimensions of the analysis. Financial behaviour, geographical demand, temporal patterns, and data quality are not isolated topics. They describe different aspects of the same underlying trip records.

For example, borough-level demand becomes more meaningful when combined with hourly patterns. Financial comparisons become more meaningful when interpreted alongside rate codes and payment types. Analytical findings also become more trustworthy when their underlying data quality limitations are documented.

The final synthesis was therefore not intended to introduce an entirely new analytical technique. It was intended to consolidate the work and make the overall understanding of the dataset more coherent.

## How do Iterations 11–15 connect?

These five iterations marked a shift from primarily investigating individual analytical questions towards building a more structured and repeatable data workflow.

We began with a broader data quality audit to understand the limitations of the cleaned dataset. We then enriched the trip records with taxi zone reference data so that geographical analysis could be performed at the zone and borough levels. After that, we explored more advanced SQL concepts such as CTEs, ranking functions, window partitions, running totals, and comparisons between consecutive observations.

We then moved from manual execution towards a Python and DuckDB pipeline that validated inputs, performed transformations, generated outputs, and checked the resulting datasets. Finally, we brought the analytical work together in a final synthesis.

The progression was important because each stage addressed a different weakness in the preceding workflow. Data quality checks improved our understanding of reliability. Reference data made numerical identifiers meaningful. Advanced SQL allowed more complex analytical comparisons. Pipeline automation made preparation repeatable. Final synthesis connected the individual findings into one coherent analysis.

## What should I remember from Iterations 11–15?

The most important lesson is that a reliable analytical workflow requires more than correct SQL queries. We need to understand data quality at multiple levels, validate reference data before joining it, preserve records when unmatched values need investigation, and understand how different SQL operations affect the granularity of the result.

I should remember that completeness, validity, consistency, and uniqueness are separate dimensions of data quality. Candidate duplicates are not necessarily confirmed duplicates, and overlapping quality flags cannot be added together to calculate unique bad records.

I also need to understand the difference between `GROUP BY` and window functions, and the different behaviour of `ROW_NUMBER`, `RANK`, and `DENSE_RANK`. CTEs make complex SQL easier to organize, while `LAG` and running totals allow us to analyze ordered sequences without losing the individual rows.

From the engineering side, I learned that a repeatable pipeline needs explicit input assumptions, validation, predictable output paths, and checks after transformation. Idempotency means repeated execution should produce the intended final state, but a basic delete-and-recreate strategy still has failure risks.

Most importantly, I learned that data engineering and analytics are connected. Data quality determines what we can trust, enrichment provides additional context, SQL allows us to investigate patterns, and pipelines make the preparation process repeatable. The final responsibility is to explain what the analysis establishes, what assumptions it depends on, and what remains uncertain.

The goal of this learning cycle was not merely to complete fifteen iterations. It was to develop the ability to take an unfamiliar dataset, investigate its structure and quality, transform it responsibly, perform increasingly sophisticated analysis, automate repeatable operations, and explain the reasoning behind the entire process.
