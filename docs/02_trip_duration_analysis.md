# Trip Duration Analysis

## Objective

Understand the distribution of taxi trip durations and evaluate the influence of unusually short, negative, and long recorded durations.

## Methodology

Trip duration was calculated from pickup and drop-off timestamps:

    duration_minutes = (drop-off timestamp - pickup timestamp) / 60

The analysis used January 2025 pickup records.

Duration was calculated in SQL using DuckDB's `date_diff` function.

## Initial Distribution

| Metric | Result |
|---|---:|
| Trips | 3,475,204 |
| Mean duration | 15.02 minutes |
| Median duration | 11.70 minutes |
| Minimum duration | -51,472.32 minutes |
| Maximum duration | 5,626.32 minutes |
| 25th percentile | 7.28 minutes |
| 50th percentile | 11.70 minutes |
| 75th percentile | 18.33 minutes |
| 90th percentile | 27.55 minutes |
| 95th percentile | 36.20 minutes |
| 99th percentile | 58.92 minutes |

## Data Quality Findings

### Negative durations

After excluding negative durations:

- Remaining trips: 3,475,080
- Negative-duration records: 124
- Mean duration: 15.03 minutes
- Median duration: 11.70 minutes

The negative-duration records were inconsistent with the expected chronological order of pickup and drop-off timestamps.

Removing these records from the calculation had little effect on the mean or median.

### Long durations

The maximum nonnegative duration was 5,626.32 minutes, approximately 93.8 hours.

This is suspicious for an ordinary taxi trip and indicates a potential timestamp or recording issue.

### Sensitivity to long durations

| Metric | Result |
|---|---:|
| Mean with nonnegative durations | 15.03 minutes |
| Mean excluding trips over 2 hours | 14.57 minutes |
| Mean excluding trips over 1 hour | 14.07 minutes |
| Median excluding trips over 2 hours | 11.70 minutes |
| Trips over 2 hours | 2,014 |
| Trips over 1 hour | 31,866 |

Trips exceeding two hours represented approximately 0.058% of nonnegative trips.

Excluding these trips reduced the mean by 0.46 minutes, while the median remained unchanged.

## Interpretation

The median duration of 11.7 minutes provides a stable measure of a typical trip.

The mean is more sensitive to long-duration records. However, the extreme maximum does not imply that the entire distribution is severely distorted.

The investigation indicates that:

- Negative durations are rare.
- Extremely long durations exist.
- Long durations influence the mean to some extent.
- The median remains stable under the tested filters.

## Analytical Decisions

- The raw dataset remains unchanged.
- Negative durations were excluded only for the filtered statistical calculation.
- Trips exceeding one or two hours were treated as exploratory outlier groups, not automatically invalid records.
- No official TLC duration-validity threshold was established.

## Limitations

The analysis identifies suspicious durations but does not establish their underlying cause.

The chosen duration thresholds are exploratory and should not be interpreted as official data-cleaning rules.

## Concepts Practiced

- Timestamp arithmetic
- Derived columns
- Mean versus median
- Percentile interpretation
- Outlier sensitivity
- Conditional aggregation
- Data-quality filtering
- Reproducible SQL analysis
