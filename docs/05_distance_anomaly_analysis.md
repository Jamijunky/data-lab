# Distance Anomaly Analysis

## Objective

Investigate anomalous `trip_distance` values in the January 2025 NYC Yellow Taxi dataset and identify records that are physically implausible based on their reported distance and trip duration.

## 1. Investigation

During the initial analysis, several trips were found with unusually large distances. Some records reported thousands or even hundreds of thousands of miles within a few minutes.

To investigate these anomalies, average trip speed was calculated using the reported distance and duration.

**Average speed (mph)** = trip distance (miles) / trip duration (hours)

This metric was used to identify records whose reported distances were inconsistent with realistic taxi travel.

## 2. Initial Findings

The dataset contained:

- Total records after trip-duration cleaning: 3,475,080
- Records with positive trip distance and positive duration: 3,382,952
- Records with calculated average speed above 100 mph: 899

The 899 suspicious records represented approximately 0.027% of the dataset.

### Distribution of calculated average speeds

| Average speed | Number of trips |
|---|---:|
| 0–100 mph | 3,382,053 |
| 100–200 mph | 184 |
| 200–500 mph | 196 |
| Above 500 mph | 519 |

The highest calculated speed was approximately 3,722,497 mph, indicating severe distance anomalies.

## 3. Investigation of Extreme Distances

Individual records were inspected using their trip distance, pickup timestamp, dropoff timestamp, passenger count, and calculated duration.

Examples included:

| Trip distance | Duration | Calculated speed |
|---:|---:|---:|
| 276,423.57 miles | 2 minutes | Extremely implausible |
| 44,730.3 miles | 123.8 minutes | Approximately 21,678 mph |
| 7,146.63 miles | 11 minutes | Approximately 38,982 mph |
| 3,462.61 miles | 12 minutes | Approximately 17,313 mph |

The timestamps were internally consistent in several of these records, while the reported distances were clearly corrupted.

Anomalies were found both in records with missing passenger counts and in records with passenger counts present. Therefore, missing passenger count was associated with some anomalies but could not independently identify all invalid distances.

## 4. Cleaning Decision

A threshold of **100 mph** was selected for this dataset.

Records satisfying the following condition were considered invalid for distance-based analysis:

`trip_distance / (trip_duration_minutes / 60) > 100`

This threshold is a pragmatic rule based on the investigation of NYC taxi trips. It should not be treated as a universal rule for other transportation datasets.

The resulting exclusion count was 899 records.

## 5. Important Considerations

- The original raw dataset was preserved.
- The previously cleaned dataset was also preserved.
- The distance anomaly rule is intended for distance-based analysis.
- Zero-distance and zero-duration records were not included in the average-speed calculation and require separate treatment if they affect a particular analysis.
- Unusual distances should not automatically be considered invalid without examining their duration and contextual plausibility.
- Cleaning decisions should remain documented and reproducible.

## Conclusion

The investigation identified 899 trips with calculated average speeds above 100 mph. These records were considered physically implausible for NYC taxi trips and were selected for exclusion from distance-based analysis.

The analysis demonstrates how derived metrics such as average speed can help identify corrupted measurements while preserving the original dataset for future investigation.

