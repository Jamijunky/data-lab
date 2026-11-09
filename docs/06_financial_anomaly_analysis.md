# Iteration 6: Financial Anomaly Analysis

## Objective

The objective of this iteration was to investigate unusual financial values in the NYC Yellow Taxi January 2025 dataset. We focused on negative fare amounts and negative total amounts, examined how they were distributed across vendors and payment types, and evaluated whether the patterns could be explained by ordinary transaction behavior.

The goal was not to delete suspicious records immediately. It was to identify patterns, evaluate possible explanations, and determine what conclusions the available data could support.

## 1. Identifying Financial Anomalies

We began by checking the duration-cleaned dataset for missing and unusual values in passenger count, trip distance, fare amount, and total amount.

The dataset contained 3,475,080 records. There were 540,031 records with missing passenger counts and 24,655 records with a passenger count of zero. Trip distance had 90,893 zero values, but no missing or negative values.

The financial fields showed a more interesting pattern: 144,118 records had negative fare amounts, while 63,037 records had negative total amounts. Negative fares were substantially more frequent than negative totals, indicating that other financial components could offset a negative fare in the final total.

## 2. Conditional Aggregation

We used SQL conditional aggregation with `COUNT(*) FILTER (WHERE ...)` to calculate several anomaly counts in a single query.

This technique is useful when multiple conditions must be evaluated over the same dataset. Instead of repeatedly querying the table for each anomaly, we can calculate all the relevant counts together.

The distinction between negative fare amounts and negative total amounts was important. A negative fare does not automatically imply a negative total because the total amount incorporates additional financial components.

## 3. Investigating Payment Types

We grouped records containing negative fares or negative totals by payment type.

The largest groups were:

| Payment Type | Records with Negative Fare or Total | Negative Fares | Negative Totals |
|---|---:|---:|---:|
| 0 | 84,822 | 84,822 | 3,421 |
| 4 | 37,411 | 37,405 | 37,410 |
| 2 | 14,111 | 13,802 | 14,111 |
| 3 | 8,080 | 8,075 | 8,080 |
| 1 | 15 | 14 | 15 |

These counts were calculated only among records where either fare amount or total amount was negative.

The distribution was not uniform across payment types. Payment types 3 and 4 had negative fares in approximately 52.65% and 52.46% of their respective Vendor 2 records. Payment type 0 also showed a substantial negative-fare proportion.

This suggested that negative financial values were associated with specific transaction categories rather than being randomly distributed throughout the dataset.

## 4. Vendor-Level Analysis

We grouped financial anomalies by vendor.

| Vendor ID | Total Records | Negative Fare Records |
|---|---:|---:|
| 1 | 753,665 | 0 |
| 2 | 2,719,838 | 144,118 |
| 6 | 371 | 0 |
| 7 | 1,206 | 0 |

All 144,118 negative-fare records belonged to Vendor 2.

The negative-fare proportion for Vendor 2 was approximately 5.30% of its records. The other vendors had no negative fare amounts in this dataset.

This was one of the strongest associations discovered in the iteration. However, association alone does not establish the underlying cause. Differences in vendor reporting, transaction handling, or record-generation processes could contribute to the observed pattern.

## 5. Vendor and Payment Type Together

We then examined payment types within Vendor 2 rather than treating vendor and payment type as independent dimensions.

| Payment Type | Vendor 2 Records | Negative Fares | Negative-Fare Rate |
|---|---:|---:|---:|
| 0 | 451,456 | 84,822 | 18.79% |
| 1 | 1,877,764 | 14 | Approximately 0.0007% |
| 2 | 303,974 | 13,802 | 4.54% |
| 3 | 15,337 | 8,075 | 52.65% |
| 4 | 71,307 | 37,405 | 52.46% |

This analysis showed that the vendor-level association was not sufficient by itself. The distribution varied substantially across payment types within the same vendor.

The combination of vendor and payment type provided a more useful explanation of where the anomalies were concentrated.

## 6. Examining Trip Characteristics

We examined distance and duration for records with negative fares.

| Payment Type | Negative-Fare Records | Zero-Distance Records | Positive-Distance Records |
|---|---:|---:|---:|
| 0 | 84,822 | 10,078 | 74,744 |
| 4 | 37,405 | 2,152 | 35,253 |
| 2 | 13,802 | 810 | 12,992 |
| 3 | 8,075 | 1,407 | 6,668 |
| 1 | 14 | 4 | 10 |

Most negative-fare records had positive trip distances and durations of at least one minute. Therefore, negative fares were not limited to records that obviously represented zero-distance or extremely short trips.

However, these statistics describe only records with negative fares. They do not establish how these trips differ from ordinary trips with nonnegative fares.

## 7. Financial Components and Extreme Values

We examined records with particularly negative total amounts and found that individual financial components could behave differently.

Some records contained negative fares alongside positive tips. Certain records also had negative improvement surcharges.

This demonstrated why total amount should not be interpreted as a simple copy of fare amount. It is the result of multiple financial components, and each component needs to be considered when investigating anomalies.

We also examined the frequency of repeated negative fare values. Some values occurred thousands of times. Repeated values may indicate systematic transaction patterns, but frequency alone cannot establish whether those records are valid.

## 8. Business Rules and Transaction Semantics

A negative financial value should not automatically be accepted as a refund.

A refund or adjustment should ideally be interpretable in relation to an original transaction. For example, if a customer paid a certain amount, a refund should be traceable to that payment and should not be treated as an unrelated negative ride fare.

The dataset does not provide sufficient transaction linkage to establish whether each negative fare represents a refund, reversal, correction, dispute, or data-quality problem.

The important distinction is between a statistically unusual value and a value that violates a defined business rule. Statistical analysis can identify suspicious records, but transaction-level business semantics are required to determine whether those records are invalid.

## 9. Final Conclusion

Negative financial values in the January 2025 dataset were strongly associated with Vendor 2 and specific payment types.

All 144,118 negative-fare records belonged to Vendor 2. Within that vendor, negative fares were particularly concentrated in payment types 0, 3, and 4.

These patterns support the hypothesis that the anomalies are related to transaction reporting or processing behavior. However, the available dataset does not establish whether the records represent refunds, reversals, corrections, disputes, or errors.

The defensible conclusion is that these records should be flagged for investigation rather than automatically deleted or accepted as valid.

Future analyses should preserve the original records and apply clearly documented rules when excluding them from a particular analytical task.

## 10. Concepts Learned

### Conditional Aggregation

`COUNT(*) FILTER (WHERE condition)` allows multiple conditional counts to be calculated in a single query. It is useful for profiling and anomaly detection.

### Grouping and Segmentation

Grouping anomalies by vendor and payment type revealed patterns that were hidden in overall counts. Segmentation helps identify whether an anomaly is concentrated in a particular category.

### Denominators and Rates

A raw anomaly count is not enough. A count of 10,000 anomalies means something different in a group of 20,000 records than in a group of 2 million records. Rates require the correct group-level denominator.

### Statistical Anomalies vs. Business-Rule Violations

An unusual value is not automatically invalid. Statistical analysis identifies unusual patterns, while business rules determine whether a record is acceptable for a particular use.

### Data Preservation

Suspicious records should not be deleted without justification. Preserving the original data allows later investigation and makes the analysis reproducible.

## Learning Reflection

This iteration demonstrated that anomaly detection is not just about finding extreme values. The more important task is understanding where those values occur, how they relate to other fields, and what the available evidence can legitimately establish.

The strongest finding was the concentration of negative fares in Vendor 2 and particular payment types. The main unresolved question is the underlying transaction meaning of those negative values.

The analysis reached a defensible conclusion without pretending that the cause had been proven.
