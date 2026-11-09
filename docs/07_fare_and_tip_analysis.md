# Iteration 7: Fare and Tip Analysis

## Objective

The objective of this iteration was to investigate how taxi fares and tips relate to trip distance, trip duration, and payment type in the NYC Yellow Taxi January 2025 dataset.

The analysis builds on the previous iterations, particularly trip duration cleaning, distance anomaly investigation, and financial anomaly analysis.

The main questions were whether longer trips generally have higher fares, how trip duration contributes to fare variation, and how tips should be analyzed across payment methods.

## 1. Understanding Fare Amount

The `fare_amount` field represents the time-and-distance fare calculated by the taxi meter.

This means fare amount is not determined by distance alone. Two trips with similar distances can have different fares because their durations, rates, and other circumstances may differ.

The first important distinction is between a relationship and a complete explanation. A positive relationship between distance and fare is reasonable to expect, but distance alone cannot explain every fare variation.

## 2. Fare and Trip Distance

Trip distance was compared with fare amount using summary statistics, distance-based groups, and correlation analysis.

The purpose of grouping trips by distance was to make the relationship easier to interpret. Instead of relying on individual records, groups allow us to compare typical fares across short, medium, and longer trips.

The analysis also distinguishes a general trend from an exact pricing rule. A positive association between distance and fare does not mean every longer trip costs more than every shorter trip.

Distance anomalies identified in Iteration 5 were excluded from the primary distance-based analysis. This prevents physically implausible measurements from distorting the relationship.

## 3. Fare and Trip Duration

Trip duration provides another important dimension of fare analysis.

Since the meter fare is based on both time and distance, duration can help explain why trips with similar distances may have different fares.

The analysis compared fare amounts across duration groups and examined the relationship between fare and duration.

However, duration and distance are not independent. Longer trips may also cover greater distances, so their individual relationships with fare should not be interpreted as completely separate effects.

## 4. Correlation and Its Limitations

Correlation was used to quantify the strength and direction of the relationships between fare, distance, and duration.

A positive correlation indicates that larger values of one variable tend to occur with larger values of another. It does not establish causation or prove that one variable alone determines the other.

Correlation can also be affected by extreme values, unusual rate codes, airport trips, negotiated fares, and other pricing circumstances.

Therefore, correlation should be interpreted alongside grouped summaries and the underlying fare structure.

## 5. Understanding Tip Amount

The `tip_amount` field requires special treatment.

According to the NYC Taxi and Limousine Commission data dictionary, this field is automatically populated for credit-card tips. Cash tips are not included in the dataset.

This means that a recorded tip amount of zero does not necessarily mean the passenger did not tip. The passenger may have paid in cash and left a tip that was not recorded in this field.

Tip analysis must therefore distinguish between payment methods rather than treating every zero tip as a genuine absence of tipping.

## 6. Payment Type and Tip Analysis

Payment type was used to separate credit-card transactions from other payment categories.

Credit-card transactions were used for the primary tip analysis because the dataset records credit-card tips.

The analysis examined:

- The distribution of recorded tip amounts.
- The proportion of credit-card trips with recorded positive tips.
- The relationship between tip amount and fare amount.
- The relationship between tip percentage and fare amount.
- Differences in recorded tips across fare and distance groups.

Cash transactions were not used to estimate tip rates because their cash tips are not recorded.

## 7. Tip Percentage

Tip percentage was calculated relative to fare amount for eligible credit-card trips.

This provides a normalized measure that can be compared across trips of different fare amounts.

For example, a $5 tip on a $25 fare represents a different tipping rate from a $5 tip on a $100 fare.

Tip percentage should only be calculated when fare amount is positive. Zero or negative fares make the percentage difficult to interpret and can produce misleading results.

## 8. Analytical Limitations

The dataset provides recorded trip fares and credit-card tips, but it does not contain every aspect of the passenger's payment behavior.

Cash tips are not recorded. Therefore, the observed tip distribution is not a complete representation of all tips received by taxi drivers.

Fare amount is also influenced by time, distance, rate codes, surcharges, tolls, and other pricing circumstances.

The analysis identifies relationships within the dataset but does not establish passenger motivation or explain every individual fare.

## 9. Conclusion

Fare amount should be analyzed using both trip distance and duration. Distance is an important component of taxi pricing, but it cannot fully explain fare variation on its own.

The analysis of fare and duration provides a more complete view of the relationship between trip characteristics and the meter fare.

Tip analysis requires a different approach. Since the dataset records credit-card tips but excludes cash tips, the recorded tip distribution represents only part of passenger tipping behavior.

The appropriate conclusion is that fare analysis should consider multiple trip characteristics, while tip analysis must account for payment method and the limitations of the recorded data.

The dataset is useful for understanding these relationships, but it should not be treated as a complete record of every passenger's payment behavior.

## 10. Concepts Learned

### Fare Components

Taxi fare is influenced by time and distance. Distance alone is insufficient to explain every difference in fare amount.

### Correlation

Correlation measures the strength and direction of a relationship between two variables. It does not establish causation or imply that one variable completely determines another.

### Grouped Analysis

Grouping trips by distance, duration, or fare provides a clearer way to compare typical values and identify trends.

### Payment-Type Segmentation

Payment type affects how financial fields should be interpreted. Different payment categories may contain different kinds of recorded information.

### Missing Information vs. Zero

A zero recorded tip is not equivalent to proof that no tip was given. Cash tips are excluded from the dataset, so the field has a specific limitation.

### Data Interpretation

Understanding what a column represents is as important as calculating statistics from it. Incorrect assumptions about the meaning of a field can lead to misleading conclusions.

## Learning Reflection

This iteration reinforced the importance of understanding the meaning of dataset fields before analyzing them.

Fare analysis requires consideration of both distance and duration. Tip analysis requires awareness of the payment method and the fact that cash tips are not recorded.

The main lesson is that analytical results depend not only on the calculations performed, but also on the assumptions and limitations behind the data.
