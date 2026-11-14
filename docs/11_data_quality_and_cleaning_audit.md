# Iteration 11: Data Quality and Cleaning Audit

## Objective

The objective of this iteration is to consolidate the data quality investigations performed throughout the previous iterations and establish a systematic approach to auditing the NYC Yellow Taxi dataset.

Earlier analyses examined missing passenger counts, invalid trip durations, unusual distances and speeds, negative fares, unusual financial records, and location information.

Instead of treating these as isolated problems, this iteration organizes them into a broader data quality framework.

## Understanding Data Quality

Data quality is not a single property. A dataset can contain records that are complete but invalid, valid but suspicious, or internally consistent but inaccurate.

Five important dimensions are considered in this audit.

### 1. Completeness

Completeness concerns whether the required information is present.

For example, the `passenger_count` column contains missing values. This affects completeness because the passenger count is unavailable for those records.

However, a missing value does not automatically make an entire trip unusable. The importance of a missing field depends on the analysis being performed.

### 2. Validity

Validity concerns whether values satisfy defined constraints.

A trip with a drop-off timestamp earlier than its pickup timestamp violates a chronological constraint. A negative trip duration is therefore invalid.

Other examples include values outside an explicitly permitted domain or records that violate the expected structure of a field.

Validity rules should be based on documented constraints rather than arbitrary assumptions.

### 3. Consistency

Consistency concerns whether related values agree with one another.

For example, pickup and drop-off timestamps should produce a nonnegative duration. Similarly, the recorded total amount can be compared with the sum of its individual fare components.

A discrepancy identifies a record requiring investigation. It does not necessarily prove that the source record is incorrect.

### 4. Uniqueness

Uniqueness concerns whether records that should be distinct are represented only once.

Repeated records can indicate duplicate ingestion or source-data duplication. However, two taxi trips may legitimately have identical values across several columns.

Consequently, matching records should be treated as candidate duplicates unless a reliable unique identifier or business rule establishes that they are duplicates.

### 5. Accuracy

Accuracy concerns whether recorded values represent the real-world event correctly.

A record can pass completeness, validity, consistency, and uniqueness checks while still being inaccurate.

For example, a trip could contain plausible timestamps and a plausible fare but still have an incorrectly reported distance.

Without independent ground truth, accuracy cannot be conclusively established from the trip dataset alone.

## Missing Values and Their Interpretation

The earlier profiling analysis identified 540,031 missing passenger counts in the duration-cleaned dataset.

This is a completeness issue, but it does not imply that every affected trip is unusable.

The correct treatment depends on the purpose of the analysis. Passenger-count analysis may exclude or separately classify these records, while distance analysis may still use them.

Missing values should not be replaced with zero unless zero has a valid business meaning.

## Invalid and Suspicious Records

The distinction between invalid and suspicious records is important.

An invalid record violates an established rule. For example, a drop-off timestamp earlier than the pickup timestamp violates the expected chronological relationship.

A suspicious record looks unusual but cannot be rejected confidently. Extremely high distances, unusual calculated speeds, and unexpected fare combinations belong in this category until additional evidence establishes otherwise.

A zero-distance trip may be legitimate in some circumstances. Similarly, a negative fare may reflect a financial adjustment or another reporting condition that cannot be understood from the fare value alone.

The audit should therefore preserve suspicious records and record the reason they were flagged.

## Cross-Column Validation

Individual column checks are not sufficient for reliable data quality analysis.

Some issues only become visible when multiple fields are considered together.

Examples include:

- Pickup and drop-off timestamps compared to calculate trip duration.
- Distance and duration compared to calculate average speed.
- Fare components compared against total amount.
- Rate codes compared with fare characteristics.
- Pickup and drop-off location IDs checked for missing or unexpected values.

These checks provide stronger evidence than examining individual columns in isolation.

## Duplicate Detection

Duplicate detection requires a clear definition of what makes a trip unique.

A repeated combination of vendor, pickup timestamp, drop-off timestamp, pickup location, drop-off location, and trip characteristics can be flagged for investigation.

However, this combination is only a candidate duplicate key. Two genuine trips may share these attributes.

The audit therefore reports repeated combinations without automatically removing them.

## Data Quality Audit Strategy

The audit follows a sequence:

1. Profile missing values in important columns.
2. Validate timestamps and derived trip durations.
3. Check numeric fields for negative, zero, and extreme values.
4. Compare related fields for internal consistency.
5. Identify candidate duplicate records.
6. Summarize the results and document the treatment of each issue.

The purpose is to make data quality decisions explicit and reproducible.

## Cleaning Decisions

Not every quality issue should result in deletion.

Invalid records may be excluded from analyses that depend on the violated constraint. Suspicious records should generally be flagged and investigated. Missing values should be handled according to the requirements of the analysis.

The existing duration-cleaned dataset remains unchanged during this audit. This iteration focuses on documenting and consolidating quality checks rather than creating another aggressively filtered dataset.

## Analytical Conclusions

Data quality requires more than checking for NULL values or removing extreme numbers.

Completeness, validity, consistency, uniqueness, and accuracy describe different aspects of quality. A record can satisfy some dimensions while failing others.

The most important conclusion is that cleaning decisions must be based on explicit rules and the intended analytical use of the data.

The audit also reinforces the distinction between a data error and an unusual observation. Automatically deleting suspicious records can remove legitimate information and introduce bias.

## Limitations

The audit relies on the information available in the January 2025 NYC Yellow Taxi trip records.

It cannot independently verify whether a recorded trip actually occurred, whether the reported distance is correct, or whether a financial transaction was processed accurately.

Candidate duplicate records cannot be confirmed without a reliable unique trip identifier or additional source information.

## Learning Reflection

This iteration brings together the data quality concepts encountered throughout the previous analyses.

It develops a more systematic approach to profiling, validation, anomaly detection, duplicate investigation, and cleaning decisions.

The next stage can use these principles to enrich the dataset with external taxi zone metadata and improve the geographical interpretation of trip records.
