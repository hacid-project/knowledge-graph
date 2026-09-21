# Competency Questions for the HACID Data Ontology (`data:`)

Ontology under test: [`https://w3id.org/hacid/onto/data`](https://w3id.org/hacid/onto/data)
(source: [`ontologies/data/data.owl`](https://github.com/hacid-project/knowledge-graph/blob/main/ontologies/data/data.owl) in the [`hacid-project/knowledge-graph`](https://github.com/hacid-project/knowledge-graph) repository)

Companion resource for: M. Ceriani, A. Nuzzolese, *"Formalising Data Structures Without Overdoing It: an Ontology for Dependency, Composition, and Value-Space Structure of Variables and Datasets"*, WOP 2026.

## Purpose and scope

These competency questions (CQs) were formulated following the eXtreme Design
methodology to drive and validate the design of the `data:` ontology module.
The original use case that motivated the module is drawn from the climate
services domain (see the paper's worked example, §Usage Example), but the
module is intended to be domain-agnostic: it models variables, their
dimensional spaces, and the dependency/derivation/aggregation relationships
between them, without committing to any specific scientific or statistical
domain. To probe this claim, the CQs below deliberately also cover domains
outside climate science — official/business statistics, epidemiology and
public health, finance and economics, environmental remote sensing, energy
and smart-grid data, and social-science survey indicators — alongside the
climate example used throughout the paper.

Each CQ is annotated with the ontology terms (classes and properties, using
the `data:` prefix) it exercises, and with the modelling pattern from the
paper it corresponds to, so that it can be used both as a documentation aid
and as a basis for a SPARQL-based test suite (e.g., as CONSTRUCT/ASK queries
against instance data such as the paper's usage example graph).

## Legend

- **Pattern** refers to the mechanism as named in the paper: *dependency*,
  *specialization*, *rescaling*, *componenthood*, *aggregation*,
  *discretization* (sampling/binning), *bounding/coverage*, *finiteness*,
  *provenance*, *equivalence*.
- **Domain** indicates the scenario the CQ is phrased against.
  "Generic" CQs are domain-independent and phrased directly in terms of the
  ontology's abstractions.

## 1. Variables and dimensional spaces (basics)

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ1 | Generic | What is the dimensional space on which a given variable takes its values? | `data:Variable`, `data:hasValuesOn`, `data:DimensionalSpace` |
| CQ2 | Generic | Is a given variable independent, or does it depend on one or more other variables? | `data:IndependentVariable`, `data:DependentVariable` |

## 2. Dependency

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ3 | Generic | On which independent variables does a given dependent variable depend? | `data:dependsOnVariable` |
| CQ4 | Finance | What are the independent variables of "daily closing price of an equity" (e.g., trading date, instrument identifier)? | `data:DependentVariable`, `data:dependsOnVariable` |
| CQ5 | Epidemiology | Does "weekly influenza-like-illness incidence rate" depend on both a temporal and a geographic independent variable? | `data:dependsOnVariable` |

## 3. Specialization

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ6 | Generic | From which more general variable is a given (derived) variable derived? | `data:DerivedVariable`, `data:derivedFromVariable` |
| CQ7 | Climate | Of which more general variable is "near-surface air temperature" (CMOR `tasmax`) a specialization, and which independent variable does the specialization fix (constrain to a specific region)? | `data:isSpecializationOfVariable`, `data:VariableSpecialization`, `data:isSpecializationOn`, `data:isConstrainedVariableIn` |
| CQ8 | Epidemiology | Is "measles incidence rate in Region X" a specialization of the general "measles incidence rate" variable, obtained by constraining the geodetic-region independent variable? | `data:isSpecializationOfVariable`, `data:VariableSpecialization` |
| CQ9 | Finance | Is "NASDAQ-100 closing price" a specialization of a generic "equity-index closing price" variable, restricted to a specific index? | `data:isSpecializationOfVariable` |
| CQ10 | Generic | Which independent variable is constrained by a given variable-specialization instance? | `data:VariableSpecialization`, `data:isSpecializationOn` |

## 4. Rescaling

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ11 | Generic | Is a given variable a rescaled version of another variable, and if so, which is the original (non-rescaled) variable? | `data:isRescaledVersionOfVariable`, `data:hasRescaledVersion` |
| CQ12 | Climate | Is "air temperature in Celsius" a rescaled version of "air temperature in Kelvin", without changing the underlying dependency structure? | `data:isRescaledVersionOfVariable` |
| CQ13 | Finance | Is "closing price in EUR" a rescaled version of "closing price in USD" for the same underlying asset variable? | `data:isRescaledVersionOfVariable` |

## 5. Componenthood and composite variables

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ14 | Generic | What are the component variables of a given composite variable? | `data:hasComponentVariable`, `data:isComponentVariableOf` |
| CQ15 | Climate | What are the component variables of a "geodetic coordinate" variable (e.g., latitude and longitude)? | `data:hasComponentVariable` |
| CQ16 | Social science | Is a composite "socio-economic status index" composed of component variables such as household income, educational attainment, and occupational prestige? | `data:hasComponentVariable` |
| CQ17 | Generic | Which dimensional space is a sub-dimensional space (projection) of a composite spatio-temporal dimensional space? | `data:hasSubDimensionalSpace`, `data:isSubDimensionalSpaceOf` |

## 6. Aggregation

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ18 | Generic | Is a given dependent variable "aggregating", and if so, which aggregation(s) does it define? | `data:definesAggregation`, `data:Aggregation` |
| CQ19 | Generic | Over which variable does a given aggregation group values, and which quantizations are suggested as candidate granularities for it? | `data:aggregatesVariable`, `data:hasSuggestedQuantization` |
| CQ20 | Climate | Along which two independent variables (time and geodetic space) is `tasmax` aggregated, and what quantization is suggested for each? | `data:definesAggregation`, `data:aggregatesVariable`, `data:hasSuggestedQuantization` |
| CQ21 | Business intelligence | For a KPI defined by a SQL expression such as `AVG(sales)` with a deferred `GROUP BY`, what is the variable being aggregated, and which candidate quantizations (e.g., daily, monthly, quarterly grouping) are suggested before a specific granularity is chosen? | `data:Aggregation`, `data:aggregatesVariable`, `data:hasSuggestedQuantization` |
| CQ22 | Energy / smart grid | Which aggregation function and axis produce "average daily household energy consumption" from raw smart-meter readings, and which temporal quantization (e.g., daily bins) does it suggest? | `data:definesAggregation`, `data:hasSuggestedQuantization` |

## 7. Dimensional-space structure and discretization

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ23 | Generic | Is a given dimensional space continuous or discrete? | `data:Continuum`, `data:DiscreteDimensionalSpace` |
| CQ24 | Generic | Of which continuum is a given quantization a discretization, and is it obtained by sampling or by binning? | `data:hasDiscretization`, `data:Sampling`, `data:Binning` |
| CQ25 | Climate | What is the (exact) resolution of the daily temporal quantization used to grid `tasmax` for the year 2024? | `data:hasResolution`, `data:hasExactResolution` |
| CQ26 | Remote sensing | What is the spatial bin size (resolution) of a satellite-derived land-cover raster, and is it a regular binning? | `data:RegularBinning`, `data:hasResolution` |
| CQ27 | Epidemiology | Are weekly disease-surveillance counts obtained via a periodic binning of a temporal continuum, and what are its period and in-period resolution? | `data:PeriodicBinning`, `data:hasPeriod`, `data:hasInPeriodResolution` |
| CQ28 | Generic | Is a given discrete dimensional space also bounded, and therefore finite (fully enumerable with finite resources)? | `data:BoundedDimensionalSpace`, `data:FiniteDimensionalSpace` |

## 8. Bounding and coverage

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ29 | Generic | What is the exact (or approximate) bounding region of a given dimensional space or dataset? | `data:hasExactBoundingRegion`, `data:hasApproximateBoundingRegion` |
| CQ30 | Finance | What time span does a historical stock-price dataset cover? | `data:hasExactBoundingRegion`, `data:TemporalRegion`, `data:hasStartDateTime`, `data:hasEndDateTime` |
| CQ31 | Climate | What is the geodetic and temporal coverage of the `tasmax, Italy, 2024` dataset? | `data:hasExactBoundingRegion`, `data:GeodeticRegion`, `data:TemporalRegion` |

## 9. Data sources, formats, and provenance

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ32 | Generic | Which data source(s) offer a serialization of a given dataset, and in which data format(s)? | `data:hasDataSerialization`, `data:hasAvailableDataFormat`, `data:hasURL` |
| CQ33 | Energy / smart grid | In which formats (e.g., CSV, Parquet) is a smart-meter aggregate dataset available, and at which URL? | `data:DataSource`, `data:hasAvailableDataFormat`, `data:hasURL` |
| CQ34 | Generic | By which process was a given dataset generated, and does that process also consume other dataset(s) as input (i.e., is it a data transformation)? | `data:hasOutput`, `data:hasInput`, `data:DataGeneratingProcess`, `data:DataConsumingProcess`, `data:DataTransformation` |
| CQ35 | Epidemiology | Which raw case-report dataset(s) were consumed by the process that produced a weekly aggregated incidence dataset? | `data:hasInput`, `data:hasOutput`, `data:DataTransformation` |

## 11. Equivalence and cross-provider alignment

| ID | Domain | Competency Question | Ontology terms exercised |
|----|--------|----------------------|---------------------------|
| CQ36 | Generic | Are two independently modelled variables asserted to always coincide in value, despite being derived through different chains? | `data:isEquivalentTo` |
| CQ37 | Economics | Is "GDP per capita" as published by the World Bank equivalent to "GDP per capita" as published by the IMF, even though the two are modelled by different providers with different derivation chains? | `data:isEquivalentTo` |

