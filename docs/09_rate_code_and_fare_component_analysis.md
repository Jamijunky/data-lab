# Iteration 9: Rate Code and Fare Component Analysis

## Objective

The objective of this analysis is to understand how NYC Yellow Taxi fares vary across rate codes and how individual fare components contribute to the final recorded amount.

Previous analyses examined fare amounts, tips, financial anomalies, and trip characteristics. This iteration shifts the focus toward the pricing structure itself.

## Understanding Rate Codes

The `RatecodeID` column represents the final rate code in effect at the end of a trip. According to the NYC Taxi and Limousine Commission's data dictionary, the available codes are:

| Rate Code | Description |
|---|---|
| 1 | Standard rate |
| 2 | JFK |
| 3 | Newark |
| 4 | Nassau or Westchester |
| 5 | Negotiated fare |
| 6 | Group ride |
| 99 | Null or unknown |

These categories represent different fare conditions. Therefore, comparing every trip under one pricing assumption would be misleading.

Rate codes should first be examined by frequency. A category with very few observations may have extreme averages that are not representative of a broader population.

## Rate Code and Trip Characteristics

Rate codes can be compared against trip distance, duration, fare amount, and total amount.

The analysis should distinguish between differences caused by pricing rules and differences caused by trip characteristics. For example, airport-related trips may have different distances and durations from ordinary city trips.

A higher average fare for a rate code does not automatically mean that the rate itself is more expensive. The trips assigned to that code may simply be longer or otherwise different.

Median values are important alongside averages because taxi trip data contains extreme observations and financial anomalies. The median provides a more robust representation of a typical trip.

## Understanding Fare Components

The dataset contains several monetary columns:

- `fare_amount`: Meter-based time-and-distance fare.
- `extra`: Miscellaneous extras and surcharges.
- `mta_tax`: MTA tax.
- `tip_amount`: Recorded tip amount.
- `tolls_amount`: Total tolls paid during the trip.
- `improvement_surcharge`: Improvement surcharge.
- `congestion_surcharge`: New York State congestion surcharge.
- `airport_fee`: Airport pickup fee.
- `cbd_congestion_fee`: Congestion Relief Zone charge.
- `total_amount`: Total recorded passenger charge.

These fields should not be treated as interchangeable. The meter fare is only one part of the total.

The TLC data dictionary also states that cash tips are not included in `tip_amount` or `total_amount`. Therefore, the recorded total should not be interpreted as the complete amount a passenger may have paid including cash tips.

## Fare Component Analysis

The first step is to examine the distribution of each component independently.

This helps distinguish components that are frequently charged from those that occur only on particular trips. For example, tolls and airport fees are not expected to appear on every trip.

The analysis should include the number of trips with a positive charge, zero charge, negative charge, or missing value for each component.

This distinction matters because a zero value and a missing value do not necessarily mean the same thing. A zero can indicate that no charge was recorded for that component, while a missing value may represent unavailable information.

## Reconciliation of Total Amount

A useful analytical question is whether the recorded total amount can be reconciled with its component fields.

A candidate reconstruction is:

`fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge + airport_fee + cbd_congestion_fee`

This expression is a hypothesis to test against the data, not an assumed universal accounting rule.

The analysis should calculate the difference between the recorded total and the reconstructed total. The difference should then be examined by rate code, payment type, and surcharge presence.

Before interpreting any discrepancy as an error, the applicable data definitions and reporting conventions must be considered.

## Congestion Relief Zone Fee

The `cbd_congestion_fee` field is particularly important for this dataset because the TLC data dictionary identifies January 5, 2025 as the beginning of the Congestion Relief Zone charge.

January 2025 therefore contains two periods: before and after the charge began.

The analysis can compare fee presence and recorded amounts across these periods. However, a date-based difference alone does not establish that the policy caused every observed change in trip totals.

## Analytical Conclusions

This iteration establishes a framework for understanding NYC taxi pricing through rate codes and individual fare components.

Rate codes provide important context for comparing fares. Surcharges and additional fees explain why the final passenger charge differs from the meter fare. Reconciliation helps identify records requiring further investigation, but discrepancies should not automatically be classified as errors.

The analysis preserves unusual records for investigation rather than deleting them without a documented rule.

## Limitations

This analysis uses trip-record data submitted to the NYC Taxi and Limousine Commission. It does not independently verify the underlying payment transactions.

The dataset does not establish why a particular fare was assigned, whether every surcharge was correctly applied, or whether a recorded discrepancy represents a reporting issue.

The conclusions should therefore be limited to patterns observed in the records.

## Learning Reflection

This iteration expands the understanding of financial data analysis beyond simply calculating averages and totals.

It demonstrates the importance of distinguishing base amounts from additional charges, understanding categorical pricing conditions, validating accounting relationships, and interpreting missing or unusual values carefully.

The next stage of the learning journey can build on this foundation by examining how pricing and trip patterns change over time.
