# Iteration 10: Time-Based Demand and Fare Analysis

## Objective

The objective of this iteration is to understand how taxi demand, trip duration, distance, and fare characteristics vary across time.

Earlier iterations analyzed hourly demand and weekday versus weekend patterns separately. This iteration combines temporal demand analysis with financial and trip characteristics to develop a broader understanding of when taxi trips occur and how their characteristics change.

## Understanding Temporal Aggregation

The pickup timestamp represents when the taxi meter was engaged. It is therefore a useful basis for measuring trip demand.

Different time granularities reveal different patterns. Hourly aggregation can expose commuting periods and overnight activity. Weekday aggregation can reveal differences between working days and weekends. Combining weekday and hour allows us to identify patterns that would be hidden by examining either dimension independently.

Time-based analysis also requires careful interpretation. A high number of trips during a particular hour indicates observed trip demand, not necessarily the total number of passengers seeking taxis or the number of taxis available.

## Demand by Hour and Weekday

Hourly demand provides a broad view of taxi activity throughout the day.

However, aggregating the entire month into 24 hours hides variation between weekdays and weekends. A particular hour may have high demand on weekdays but relatively low demand on weekends.

Grouping by both weekday and hour allows these patterns to be compared directly.

The analysis should distinguish between the number of trips and the characteristics of those trips. A high-demand period may contain many short trips, while a lower-demand period may contain longer trips.

## Trip Duration and Distance Over Time

Trip duration and distance provide additional context for demand patterns.

Average duration can be influenced by traffic conditions, trip destinations, and the mixture of short and long trips. Distance can also vary depending on the time of day and the locations connected by taxi trips.

The mean should be interpreted alongside the median because extreme durations and distances can distort averages.

The dataset contains previously identified distance and speed anomalies. These should not be silently removed from every analysis. Instead, the analysis should clearly state whether it uses the duration-cleaned dataset alone or applies additional filters for a specific comparison.

## Fare Characteristics by Time

Fare analysis by hour can reveal whether recorded trip charges differ across temporal periods.

However, the average total amount is influenced by trip distance, duration, rate codes, tolls, airport fees, tips, and other components.

A higher average total amount during an hour does not automatically indicate that taxi pricing is higher during that hour.

To interpret fare differences, the analysis should compare fare amount with distance and duration. It should also distinguish fare amount from total amount because the latter includes additional charges.

Recorded tips should be interpreted cautiously. The TLC data dictionary states that tip_amount is automatically populated for credit-card tips and does not include cash tips. Therefore, recorded tip patterns do not represent all tips paid by passengers.

## Weekday and Weekend Comparisons

Weekday and weekend comparisons can reveal differences in travel behavior.

The analysis should compare trip counts, average and median duration, distance, fare, and total amount.

These comparisons should be interpreted as descriptive patterns. The dataset does not establish why passengers travel at particular times or whether a specific event caused a demand change.

## Analytical Conclusions

This iteration combines temporal demand analysis with trip and financial characteristics.

Hourly demand describes when trips begin. Weekday-hour comparisons reveal temporal variation. Duration and distance provide context for the trips occurring during those periods, while fare analysis describes recorded financial characteristics.

The most important analytical lesson is that demand and fare should not be interpreted independently. A change in average fare may reflect a change in trip composition rather than a change in pricing.

## Limitations

The dataset covers January 2025 only. It cannot establish seasonal patterns or represent demand throughout the year.

Trip records describe completed taxi trips rather than all passenger requests or taxi availability.

The results are descriptive and do not establish causal relationships between time, demand, fare, or traffic conditions.

## Learning Reflection

This iteration strengthens the use of temporal aggregation in SQL and demonstrates how multiple analytical dimensions can be combined.

It also reinforces the distinction between observed demand, trip characteristics, and financial outcomes.

The next iteration will consolidate data quality checks and cleaning decisions into a more systematic audit.
