# SQL Concept Notes

## SELECT & WHERE
Used to filter rows and columns from a table.
mistake: filtering aggregated values using WHERE.

## GROUP BY
Used to aggregate data such as totals and averages.
mistake: selecting columns not included in GROUP BY.

## HAVING
Used to filter aggregated results.
Used when applying conditions on COUNT, SUM, AVG.

## DISTINCT
Removes duplicate values. 
mistake: Using DISTINCT with many columns changing results.

## INNER JOIN
Returns only matching rows from both tables.
Used when related records must exist.

## LEFT JOIN
Returns all rows from left table even if no match exists.
Used to find missing data.

## ORDER BY
Used Top-N reports, rankings.

## ROW_NUMBER → unique ordering
## RANK → skips numbers on ties

## NOT EXISTS
Used to find records that never meet a condition.
Safer than NOT IN when NULLs exist.

## Window Functions
Used to compute rankings and running totals without grouping rows.
