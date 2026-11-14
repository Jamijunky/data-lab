# Learning Review: Iterations 6–10

## Why did we investigate negative fares and negative total amounts?

After investigating distance anomalies, we moved towards understanding the financial side of taxi transactions. We found 144,118 records with negative `fare_amount` and 63,037 records with negative `total_amount` in the duration-cleaned dataset. These values were unusual because we generally expect a completed taxi trip to have a positive fare. However, simply assuming that every negative value represented corrupted data would have been an incorrect approach. Financial records can contain adjustments, disputes, corrections, and other transaction-related events. We therefore needed to investigate the context in which these values appeared before deciding how to treat them.

One important distinction was that the number of records with negative fares was not the same as the number with negative totals. A negative fare does not necessarily imply a negative total because other financial components can contribute to the final amount. Similarly, a negative total can result from a combination of multiple components. This helped me understand that financial anomaly detection should consider the relationship between individual monetary columns instead of treating each column independently.

## Why did we investigate negative fares by payment type?

After identifying negative fares, we grouped the records by `payment_type` to understand whether the anomalies were distributed uniformly across payment methods. We found that negative fares were concentrated in particular payment categories. For example, among Vendor 2 records, payment type 0 had 84,822 negative fares out of 451,456 records, while payment types 3 and 4 had 8,075 out of 15,337 and 37,405 out of 71,307 respectively.

This comparison revealed that the proportion of negative fares varied considerably across payment types. However, the payment type distribution alone could not explain why these values existed. It only showed an association between payment categories and negative fare records. I learned that grouping anomalies by another dimension helps narrow down where a problem occurs, but it does not automatically reveal its cause.

## Why did we investigate negative fares by vendor?

We also grouped financial anomalies by `VendorID`. This revealed that all 144,118 negative-fare records in our analysis belonged to Vendor 2. Vendor 1, Vendor 6, and Vendor 7 had no negative-fare records in the same dataset.

When we examined Vendor 2 more closely, we found that negative fares were particularly concentrated in payment types 0, 3, and 4. This was useful because it showed that the anomaly was not distributed randomly across the available vendor and payment categories. However, we could not conclude that Vendor 2 was producing incorrect data or that its system was responsible for the negative values. The dataset did not provide enough transaction-level information to establish that explanation.

This taught me an important analytical distinction: identifying where an anomaly is concentrated is different from identifying what caused it. Vendor-level and payment-level comparisons help us investigate patterns, but causal conclusions require additional evidence.

## Why couldn't we simply classify negative fares as refunds?

During the investigation, we considered whether negative fares might represent refunds. However, a refund should ideally be connected to an original transaction, and its amount should have a defensible relationship with that transaction. Our dataset contained individual trip records but did not provide the transaction linkage needed to verify that relationship.

We also examined trip characteristics associated with negative fares. Some records had positive trip distances and realistic-looking durations, while others had zero distances or very short durations. For example, payment type 4 had 37,405 negative-fare records, of which 2,152 had zero distance. Payment type 3 had 8,075 negative-fare records, including 1,407 with zero distance. These observations suggested that negative fares were not limited to one simple type of trip.

We also noticed that some negative-fare records contained positive tips or other financial components. This reinforced the idea that individual monetary columns cannot always be interpreted in isolation. The correct decision was to preserve these records and flag them for investigation rather than automatically deleting them or assigning them a refund classification.

## Why did we separate fare amount from total amount?

In Iteration 7, we shifted from investigating financial anomalies to understanding the relationship between fare, distance, duration, and tips. One important concept was that `fare_amount` and `total_amount` represent different things. The fare amount represents the meter-based time-and-distance fare, whereas the total amount includes additional recorded charges such as tips, tolls, taxes, and surcharges.

This distinction matters because analyzing only the fare amount does not provide a complete picture of what the passenger was charged. Similarly, using total amount as a direct measure of the meter fare would mix the base fare with several additional components. We therefore examined these columns separately and considered how their relationships could help explain the financial characteristics of a trip.

## Why did we investigate the relationship between fare, distance, and duration?

A taxi fare is related to the characteristics of a trip, particularly its distance and duration. However, distance alone does not fully explain fare variation. Two trips covering the same distance can have different durations, and the time spent travelling can influence the meter-based fare.

For this reason, we considered both the relationship between `trip_distance` and `fare_amount` and the relationship between `trip_duration_minutes` and `fare_amount`. We also used correlation as a way to quantify the direction and strength of these relationships. Before interpreting these relationships, we needed to consider invalid or extreme distance and duration values because such observations can distort statistical summaries and correlation calculations.

This helped me understand why analytical comparisons need appropriate filtering conditions. A correlation calculated over records containing impossible distances or invalid durations may still produce a numerical result, but that result may not describe normal taxi trips. At the same time, filtering should be based on documented assumptions rather than arbitrary deletion.

## Why did we need to distinguish credit-card tips from cash tips?

One of the most important details in this iteration was how the NYC TLC dataset records tips. The `tip_amount` field is automatically populated for credit-card tips, whereas cash tips are not captured in the same way. Therefore, a record with `tip_amount = 0` does not necessarily mean that the passenger did not give a tip. The passenger might have paid a cash tip that is not represented in this field.

This changes how tip analysis should be performed. If we want to study recorded tip behaviour, we should focus on credit-card transactions where the field provides a more consistent basis for comparison. We can then examine tip distributions, average tips, and the proportion of credit-card trips with recorded tips. However, the resulting analysis describes recorded credit-card tipping behaviour, not the complete tipping behaviour of all taxi passengers.

This was a useful example of why understanding the meaning and collection process of a column is just as important as knowing its data type. A numerical column can appear straightforward while still having limitations that significantly affect the conclusions we can draw from it.

## Why did we analyze pickup and drop-off locations separately?

In Iteration 8, we moved from financial analysis towards geographical analysis. The dataset contains `PULocationID` and `DOLocationID`, which identify the taxi zones where the meter was engaged and disengaged respectively. These columns allow us to study where trips begin and where they end.

Pickup demand and drop-off demand answer different questions. Pickup demand measures how many trips originate from a location, whereas drop-off demand measures how many trips terminate there. A location can have high pickup demand without having equally high drop-off demand. Comparing both distributions can help us understand how taxi activity is distributed across locations.

We also compared pickup and drop-off counts using separate aggregations and a `FULL OUTER JOIN`. This was important because an ordinary inner join would retain only locations present in both summaries. A full outer join preserves locations appearing in either summary, allowing us to compare both sides without silently losing unmatched locations. We used `COALESCE` to replace missing counts with zero when a location appeared on only one side.

## What does an origin-destination pair tell us that pickup counts alone cannot?

A pickup count tells us how many trips started in a particular location, but it does not tell us where those trips went. An origin-destination pair combines the pickup and drop-off locations of a trip and allows us to investigate the movement between geographical areas.

For example, a zone may have a large number of pickups, but those trips could be distributed across many different destinations. Another zone might have fewer pickups but a particularly strong connection with one destination. By grouping records using both `PULocationID` and `DOLocationID`, we can identify frequently travelled routes and examine how demand is distributed between locations.

We also considered grouping location demand by hour. This adds a temporal dimension to geographical analysis and helps identify whether particular locations experience different levels of demand at different times. I learned that adding dimensions to an aggregation can reveal patterns that are hidden when we summarize everything using only one column.

## Why did we need taxi zone reference data?

The location columns in the original dataset contain numerical taxi zone identifiers rather than descriptive geographical names. Although these identifiers are sufficient for grouping and counting records, they are not particularly useful when trying to explain findings in geographical terms.

To address this, we later used the NYC TLC taxi zone lookup table, which maps location identifiers to zone names, boroughs, and service-zone categories. This reference data makes it possible to enrich trip records with geographical information and perform borough-level analysis.

The important concept here is data enrichment. The original trip dataset contains transaction-level information, while the lookup table provides descriptive information about the locations referenced by those transactions. Joining the two allows us to perform more meaningful geographical analysis without having to manually interpret numerical identifiers.

## Why did we analyze rate codes and individual fare components?

In Iteration 9, we examined how taxi fares are structured and how different rate categories relate to financial values. The `RatecodeID` column identifies the rate category associated with a trip, such as standard rate, JFK, Newark, Nassau or Westchester, negotiated fare, and group ride. This provides additional context when comparing fares because not every trip necessarily follows the same pricing category.

We also examined the individual financial components that contribute to `total_amount`. These include `fare_amount`, `extra`, `mta_tax`, `tip_amount`, `tolls_amount`, `improvement_surcharge`, `congestion_surcharge`, `airport_fee`, and `cbd_congestion_fee`. Looking at these components separately helps us understand which charges contribute to the total and how their distributions vary across rate codes.

This iteration helped me understand the difference between a derived total and its individual components. If we want to validate the recorded total, we can reconstruct a candidate total by adding the available components and compare it with `total_amount`. However, we must handle missing values carefully because arithmetic involving `NULL` can produce a `NULL` result. We used `COALESCE` to treat missing components as zero for the purpose of the reconciliation calculation. This is an explicit analytical assumption, not proof that every missing component represents a zero charge.

## Why did we investigate the congestion charge around January 5, 2025?

The January 2025 dataset provided an opportunity to examine a time-dependent fare component. The Congestion Relief Zone charge began on January 5, 2025, so we investigated the `cbd_congestion_fee` field across the period before and after that date.

This required us to use date-based filtering and compare the distribution of the charge across different periods. We also considered how the charge varied by pickup location. The geographical dimension was relevant because the charge was associated with the Congestion Relief Zone rather than being an arbitrary additional amount applied uniformly to every trip.

The important lesson was that business rules and external events can influence the interpretation of data. A column's values should not always be analyzed without considering when a particular rule or policy became applicable. At the same time, observing a difference before and after a date does not independently establish that the policy caused every change in the dataset. We need to distinguish a time-based comparison from a causal evaluation.

## Why did we analyze demand by both hour and weekday?

In Iteration 10, we combined the temporal analysis from earlier iterations with fare and trip characteristics. We had already examined hourly demand, but grouping all records by hour can hide differences between weekdays and weekends. For example, the same hour may have different demand patterns depending on the day of the week.

We therefore grouped records by weekday and pickup hour, allowing us to examine demand at a more detailed level. We also compared weekday and weekend activity, and investigated how distance, duration, fare, and recorded tips varied across different time periods.

This taught me that aggregation is not simply about reducing the number of rows. The dimensions chosen for grouping determine what kind of question the result can answer. Grouping only by hour gives an overall hourly pattern, whereas grouping by weekday and hour allows us to compare the hourly pattern across individual days. More detailed grouping can reveal differences that would otherwise disappear inside an overall average.

## Why did we define rush hours explicitly?

For one of our comparisons, we classified weekday trips between 7–9 AM and 4–6 PM as rush-hour trips. This allowed us to compare demand and trip characteristics during those periods against other times.

However, the selected intervals were analytical definitions for our investigation, not universal definitions of rush hour. Different cities, transport systems, and analytical objectives may require different time windows. We needed to define the intervals explicitly so that the comparison was reproducible and its assumptions were visible.

I also learned that a difference in average fare between rush-hour and non-rush-hour trips does not necessarily mean that the pricing changed. Trips during those periods may differ in distance, duration, destination, or rate category. A meaningful comparison should therefore consider the characteristics of the trips being compared rather than relying on average fare alone.

## Why is correlation not the same as causation?

Across these iterations, we repeatedly grouped records by vendors, payment types, locations, rate codes, and time periods. These comparisons helped us identify relationships and differences between groups. However, finding that two variables change together does not prove that one variable caused the other to change.

For example, we observed that negative fares were concentrated in Vendor 2 records. This establishes an association in our dataset, but it does not prove that the vendor caused the negative fares. Similarly, if average fares differ between two time periods, that does not prove that the time period itself caused the difference. Other variables, such as trip distance, duration, or rate code, may explain part of the observed variation.

This distinction is essential because SQL can calculate counts, averages, percentages, and correlations, but the interpretation still requires reasoning about the data and the underlying business process. A correct query does not automatically produce a correct explanation.

## Why do these five iterations form a connected analytical process?

These iterations gradually expanded the scope of our analysis. We began with financial anomaly detection by investigating negative fares and totals. We then examined the relationship between fare, distance, duration, and recorded tips. After understanding the financial characteristics of individual trips, we moved towards geographical analysis using pickup and drop-off locations. We enriched that analysis by examining rate codes and individual fare components, and finally combined temporal dimensions with demand and fare analysis.

The progression helped me understand that data analysis is not a collection of unrelated SQL queries. Each investigation raises additional questions. Financial anomalies led us to examine payment types and vendors. Fare analysis required us to understand how individual components contribute to the total. Location analysis required reference data to make numerical identifiers meaningful. Time-based analysis required us to preserve multiple grouping dimensions to avoid hiding important patterns.

The broader process is to identify an analytical question, select the relevant columns, choose appropriate filters and grouping dimensions, calculate the required measures, and then interpret the result within the limitations of the available data.

## What should I remember from Iterations 6–10?

The most important lesson from these iterations is that analytical SQL requires more than knowing how to use `GROUP BY`, joins, aggregate functions, and date extraction. I need to understand what each column represents, why a particular grouping is useful, how missing values affect calculations, and what conclusions the resulting numbers actually support.

I should remember that negative financial values need investigation rather than automatic deletion, that recorded tips do not represent all tips, and that fare amount and total amount are different measures. Pickup demand and drop-off demand describe different types of activity, while origin-destination analysis reveals connections between locations. Rate codes and fare components provide additional context for interpreting financial records, and time-based aggregation helps reveal patterns that disappear in overall summaries.

I also need to be careful with assumptions. A threshold, a rush-hour definition, or a missing-value replacement rule must be explicitly documented. Correlation and group-level differences should not be presented as proof of causation. Most importantly, I should be able to explain not only what a query calculates, but why that calculation is appropriate and what its result cannot tell me.

These iterations strengthened my ability to approach a dataset from multiple analytical perspectives. Instead of looking at a single column and calculating its average, I learned to connect financial, geographical, temporal, and operational dimensions to investigate more meaningful questions.

