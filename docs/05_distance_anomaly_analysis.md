# Distance Anomaly Analysis

## Objective

Investigate anomalous `trip_distance` values in the January 2025 NYC Yellow Taxi dataset. The objective was to identify physically implausible distance measurements, understand their relationship with other variables, and establish a reproducible cleaning rule.

This analysis builds on the initial profiling, trip-duration cleaning, and passenger-count missingness investigation.

## 1. Passenger Count Missingness

Before investigating distance anomalies, passenger-count missingness was examined.

The cleaned dataset contained 3,475,080 records.

| Passenger count | Records |
|---|---:|
| Missing | 540,031 |
| 0 | 24,655 |
| 1 | 2,322,416 |
| 2 | 407,755 |
| 3 | 91,409 |
| 4 | 59,009 |
| 5 | 17,784 |
| 6 | 12,003 |
| 7 | 4 |
| 8 | 11 |
| 9 | 3 |

Approximately 15.54% of passenger-count values were missing.

Missing values and zero passenger counts were treated as distinct categories. Missing passenger counts were not automatically replaced with zero.

### Missingness by Vendor

Passenger-count missingness was also investigated by vendor.

| Vendor ID | Records | Missing passenger count |
|---|---:|---:|
| 1 | 753,665 | 11.70% |
| 2 | 2,719,838 | 16.60% |
| 6 | 371 | 100% |
| 7 | 1,206 | 0% |

Missingness differed across vendors. Vendor 6 had entirely missing passenger counts, but its sample was small. Vendor 2 contributed the largest number of missing values because it represented most of the dataset.

This suggests an association between vendor and passenger-count missingness, but does not establish the underlying cause or missingness mechanism.

## 2. Passenger Count and Trip Distance

Trip-distance distributions were compared between records with missing and nonmissing passenger counts.

| Passenger count status | Median distance |
|---|---:|
| Present | 1.60 miles |
| Missing | 2.04 miles |

The missing-passenger group also had much larger maximum distances.

However, the mean and standard deviation were heavily influenced by extreme distance values. Therefore, the difference in median distance was more informative than comparing means alone.

This investigation motivated a closer examination of extreme trip distances.

## 3. Initial Distance Investigation

Trips with distances exceeding 100 miles were extracted and inspected alongside their pickup timestamps, dropoff timestamps, durations, and passenger counts.

The initial investigation found:

| Distance threshold | Records |
|---|---:|
| Above 100 miles | 162 |
| Above 1,000 miles | 116 |
| Above 10,000 miles | 105 |

The maximum reported trip distance was 276,423.57 miles.

Distance-range analysis revealed that some extreme measurements occurred over very short durations.

The following records were particularly suspicious:

- Distances of tens of thousands of miles over a few minutes.
- Distances of thousands of miles over approximately 10–60 minutes.
- Records whose timestamps appeared internally consistent despite implausible distances.

These observations suggested that the distance measurements were corrupted rather than the timestamps necessarily being incorrect.

## 4. Average Speed as an Anomaly Detection Metric

To investigate distance and duration jointly, average speed was calculated.

Average speed in miles per hour:

`trip_distance / (trip_duration_minutes / 60)`

This metric provided a way to identify distances that were physically inconsistent with the reported trip duration.

### Examples of Extreme Records

| Distance | Duration | Approximate speed |
|---:|---:|---:|
| 44,730.3 miles | 123.8 minutes | 21,678 mph |
| 44,684.1 miles | 68.02 minutes | 39,412 mph |
| 33,588.9 miles | 24.98 minutes | 80,668 mph |
| 11,187.2 miles | 76.78 minutes | 8,741 mph |

These records were clearly invalid for taxi-distance analysis.

The investigation also found extreme distances in records with passenger counts present. Missing passenger count was associated with many anomalies, but it was not sufficient to identify all corrupted distances.

## 5. Dataset-Wide Speed Investigation

Average speed was calculated for all records with positive trip distance and positive trip duration.

| Metric | Count |
|---|---:|
| Total cleaned records | 3,475,080 |
| Positive distance and positive duration | 3,382,952 |
| Average speed above 100 mph | 899 |
| Average speed above 200 mph | 715 |
| Average speed above 500 mph | 519 |

The highest calculated average speed was approximately 3,722,497 mph.

### Speed Distribution

| Average speed | Records |
|---|---:|
| 0–100 mph | 3,382,053 |
| 100–200 mph | 184 |
| 200–500 mph | 196 |
| Above 500 mph | 519 |

The thresholds are nested. For example, the 519 records above 500 mph are included in the 715 records above 200 mph.

The 899 records above 100 mph represented approximately 0.027% of the cleaned dataset.

## 6. Cleaning Decision

A threshold of 100 mph was selected for this NYC taxi dataset.

Records with positive trip distance and positive duration whose calculated average speed exceeded 100 mph were classified as invalid for distance-based analysis.

This threshold was chosen based on the observed anomalies and physical plausibility of NYC taxi trips.

It is a dataset-specific cleaning rule, not a universal rule for transportation data.

The original raw dataset and previously cleaned dataset were preserved.

The exclusion rule should be applied through a separate validity flag or analytical dataset rather than permanently deleting records from the source.

## 7. Important Limitations

- Average speed is a derived metric and depends on the correctness of both distance and duration.
- Unusual distances are not automatically invalid.
- Zero-distance and zero-duration records were excluded from the speed calculation and require separate treatment for analyses that depend on them.
- The distance-validity rule is intended for distance-based analysis.
- The investigation does not establish why the original distance values were corrupted.
- Duplicate-looking records observed during the investigation require a separate duplicate analysis rather than automatic deletion.

## Conclusion

The investigation identified 899 records with calculated average speeds above 100 mph.

The extreme values were physically implausible for NYC taxi trips and were selected for exclusion from distance-based analysis.

The investigation also demonstrated that missing passenger counts and extreme distances were associated in many records, but neither variable alone was sufficient to identify all anomalies.

The resulting cleaning rule was documented to preserve reproducibility and maintain the distinction between raw data, cleaned data, and analysis-specific valid records.
