# Learning Review: Iterations 1–5

## Why do we profile data before analyzing it?

Before analyzing a dataset, we need to understand what we are working with. Profiling helps us examine its structure, data types, missing values, distributions, and unusual observations. In our NYC Taxi dataset, we found missing passenger counts and extreme distances, which could affect our analysis if ignored. This helped me understand that profiling is not just an initial formality. It gives us the information needed to decide what to investigate and whether our results can be trusted.

## What is the difference between data cleaning and data transformation?

Data cleaning deals with data-quality problems, while data transformation changes the representation of data or derives useful information from it. In our project, excluding records with invalid durations was a cleaning operation, whereas calculating trip duration from pickup and drop-off timestamps was a transformation. These operations can overlap, but their purposes are different. Cleaning improves the reliability of the data, while transformation makes it more useful for analysis.

## Why did we derive trip duration?

The original dataset contained pickup and drop-off timestamps, but we needed trip duration as a separate feature for our analysis. By calculating the difference between these timestamps, we could examine how long trips lasted, identify invalid durations, and later calculate average speed. This taught me that datasets do not always contain every feature we need. Sometimes we have to derive useful information from existing columns before we can answer our analytical questions.

## Why did we compare weekdays and weekends?

We had already analyzed hourly taxi demand, but an overall pattern might hide differences between weekdays and weekends. By grouping the records according to day type and comparing their hourly demand, we could investigate whether taxi usage followed different patterns. This helped me understand the importance of aggregation and comparison. Aggregation summarizes large amounts of data, while comparison helps reveal differences between groups. However, observing a difference does not automatically explain why it exists.

## Why is average speed useful for investigating distance anomalies?

A large trip distance alone does not necessarily indicate an invalid record. A long trip might be reasonable if it took several hours, whereas the same distance completed in a few minutes would be physically implausible. We calculated average speed using trip distance and duration to investigate these inconsistencies. This helped us identify suspicious records that would have been harder to recognize by examining distance alone. It also showed me why combining multiple features can provide more meaningful information than analyzing individual columns independently.

## Why did we choose 100 mph, and why is that threshold not universally valid?

During our investigation, we found 899 records with average speeds exceeding 100 mph among trips with positive distance and duration. We selected 100 mph as a practical threshold for our distance-based analysis. However, this is an assumption based on our particular dataset and analytical purpose, not a universal rule. Different transportation datasets may require different thresholds depending on their vehicles, geography, and conditions. The important lesson is that thresholds need justification and should be documented rather than treated as absolute truths.

## Why should we preserve the original dataset instead of deleting anomalous records?

Our decisions about suspicious records depend on assumptions and thresholds that might change as we learn more about the data. If we permanently delete these records, we lose the ability to investigate them again or compare different cleaning strategies. Preserving the original dataset allows us to reconsider our decisions and reproduce our analysis. This is why we use validity flags and derived datasets instead of modifying the original data unnecessarily.

## Did our duration-cleaned dataset already exclude negative distances?

This was an important misunderstanding we corrected during our review. Our duration-cleaned dataset was created using the `duration_valid` condition, which checked whether the drop-off timestamp was greater than or equal to the pickup timestamp. It did not explicitly check whether trip distance was negative. Therefore, we cannot assume that the dataset was cleaned for every possible data-quality issue simply because one cleaning operation had already been performed.

## Did we actually create a separate distance-cleaned dataset?

No. We investigated distance anomalies, calculated average speeds, selected a threshold, and created a `distance_valid` flag. However, we did not filter the records using that flag and save a separate distance-cleaned dataset. This distinction helped me understand that investigating anomalies, creating a validity flag, and materializing a cleaned dataset are separate operations. We should always describe what we actually implemented rather than what we intended to do.

## Why were the 899 speed anomalies different from the total number of invalid distance records?

The 899 records specifically represented trips with positive distance and duration whose average speed exceeded 100 mph. However, our `distance_valid` condition also excluded records with nonpositive distance or duration. Therefore, the total number of records marked invalid under that condition was larger. This helped me understand that the number of invalid records depends on the complete rule being applied, and different filters may exclude records for different reasons.

## Why do we maintain SQL files, documentation, and Git history?

These serve different purposes in our project. SQL files preserve the analytical logic we executed, documentation explains why we performed the analysis and what we learned, and Git history records how the project evolved. Maintaining all three means that we can revisit the project later without reconstructing everything from memory. It also makes our work easier for someone else to understand, verify, and reproduce.

## How do these five iterations connect?

The first five iterations were not independent exercises. We started by profiling the dataset to understand its structure and quality. We then derived trip duration and removed invalid-duration records. After preparing the data, we analyzed hourly demand and compared weekdays with weekends. Finally, we investigated suspicious distances using average speed and additional information from the dataset. Each iteration helped us ask better questions in the next one.

The broader process is to understand the data, prepare useful features, analyze patterns, investigate anomalies, and document our decisions. This is how data analysis becomes an iterative process rather than a collection of unrelated SQL queries.

## What should I remember from these iterations?

The most important thing I learned is that data analysis requires reasoning about the data, not just executing queries. Profiling helps us understand what we are working with, cleaning addresses quality problems, transformation derives useful information, and aggregation reveals patterns. Comparisons help us understand differences between groups, while anomaly investigation requires us to consider multiple features and justify our assumptions.

I also need to remember that suspicious records should not automatically be deleted, thresholds are context-dependent, and a validity flag is not the same as a cleaned dataset. Preserving the original data and documenting our decisions makes the entire process reproducible.

The goal of this project is to become capable of approaching an unfamiliar dataset independently, understanding its quality, asking meaningful questions, analyzing it properly, and explaining the reasoning behind the conclusions.

