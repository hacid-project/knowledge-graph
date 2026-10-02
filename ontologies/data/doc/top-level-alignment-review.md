# Data ontology: review against the top-level ontology

**Subject:** `ontologies/data/data.owl`, namespace `https://w3id.org/hacid/onto/data/`, prefix `data:`.
**Reference:** the HACID top-level ontology, `ontologies/top-level/top-level.owl` (prefix `top:`),
in its current state (after the DUL alignment, see
[`../../top-level/doc/dul-consistency-review.md`](../../top-level/doc/dul-consistency-review.md)).
**Dependent modules:** `ccso/ccso.owl` is the only module that uses `data:` terms
(`Variable`, `Dataset`, `DataGeneratingProcess`, `DataTransformation`, `hasInput`, `hasOutput`).

> Sections 2–7 describe the module **as reviewed**. Section 5 reports the impact of the proposed
> changes, tested on copies. Section 8 lists the changes that were then applied to `data.owl`.

## 1. Scope and method

The review checks how the data module builds on the top-level:

1. where its classes and properties sit in the top-level hierarchy, and whether that placement
   matches the meaning of the top-level (DUL-based) terms;
2. whether the module is logically consistent with the top-level and stays within OWL 2 DL;
3. whether it overlaps with, or clashes with, terms that the top-level already defines;
4. whether its annotations follow the top-level conventions.

How it was done:

- **Structure.** The module's axioms were extracted with rdflib.
- **Reasoning and profile.** HermiT (strict datatype mode) and ROBOT `validate-profile`, run on
  data + top-level.
- **Impact on dependents.** The changes proposed in section 4 were applied one by one to copies of
  `data.owl` and checked against all the dependent modules (`ccso`, `mdx`, core) together with the
  probe data used for the top-level review: one example link for every property of the modules with
  a declared domain or range, plus one instance of every module class. For each change I compared
  consistency, unsatisfiable classes, inferred class memberships and OWL 2 DL violations with the
  current module.

## 2. Overview

The module defines 110 terms: 36 classes, 65 object properties and 7 datatype properties, plus 2
properties declared as both object and datatype properties. It imports the top-level and anchors
to it as follows.

| Top-level term | Used in `data.owl` as | Data terms |
|---|---|---|
| `top:Concept` | superclass | `Variable` (and so all variables, dimensional spaces, quantizations and binnings: 22 classes), `Aggregation`, `DataFormat` |
| `top:Parameter` | superclass | `VariableSpecialization` |
| `top:Region` | superclass | `data:Region` (and `GeodeticRegion`, `PeriodicRegion`, `TemporalRegion`) |
| `top:InformationEntity` | superclass | `DataSource` |
| `top:Entity` | superclass | `Point` (and `GeodeticPoint`, `Instant`), `DataGeneratingProcess`, `DataConsumingProcess` (and `DataTransformation`) |
| `top:hasPart` | in restrictions | `Variable ⊑ hasPart only Variable`, `FiniteVariable ⊑ hasPart only FiniteVariable` |
| `top:hasRegion` / `top:isRegionFor` and their exact/approximate sub-properties | super-property | the bounding-region and resolution properties, `hasSelectedRegion` |
| `top:associatedWith` | super-property | the other 39 object properties |

No other top-level term is used. In particular, the module does not use the top-level's terms for
time (`TimeInterval`, `startTime`, `endTime`), events and processes (`Event`, `Action`,
`hasParticipant`), parthood and components (`hasComponent`), data values (`hasDataValue`), or
data publication (`Dataset`, `Media`, `DataSchema`).

### Reasoning results

| Check | Result |
|---|---|
| data + top-level, HermiT (strict) | ✅ Consistent, no unsatisfiable classes. |
| data + top-level, OWL 2 DL profile | ❌ **Not OWL 2 DL**: `hasStartDateTime` and `hasEndDateTime` are declared both as object and datatype properties (finding A1). This also turns `xsd:dateTime` into a class, which affects the top-level's own `xsd:dateTime` axioms in any merge. |
| data + all dependents + probe data | ✅ Consistent. The only problems are the known ones in mdx (see the top-level review, 5.3). |

Placement of the data classes in the top-level hierarchy, as inferred by the reasoner:

| Data classes | Inferred top-level superclasses |
|---|---|
| all variables and dimensional spaces, quantizations, binnings, `Aggregation`, `DataFormat` | `Concept` ⊑ `SocialObject` ⊑ `Object` |
| `VariableSpecialization` | `Parameter` ⊑ `Concept`, and `Characteristic` |
| `data:Region`, `GeodeticRegion`, `PeriodicRegion`, `TemporalRegion` | `Region` ⊑ `FormalEntity` ⊑ `Abstract` |
| `DataSource` | `InformationEntity` |
| `Point`, `GeodeticPoint`, `Instant`, the three process classes | only `Entity` |

## 3. Findings

Severity: **A** = logical or technical problem. **B** = placement or property choice that does not
match the meaning of the top-level terms, or misses a top-level term that fits. **C** = overlap
or name clash with top-level terms. **D** = annotations.

### A. Logical and technical problems

**A1. `hasStartDateTime` / `hasEndDateTime` are declared both as object and datatype properties.**
The object-property declaration carries the domain `TemporalRegion` and the range `xsd:dateTime`.
The datatype-property declaration is empty. OWL 2 DL forbids using one IRI as both kinds of
property, and an object property with range `xsd:dateTime` makes `xsd:dateTime` a class. In any
merge with the top-level, that also breaks the top-level's `xsd:dateTime` axioms (`time`,
`startTime`, `endTime`, and the `TimeInterval` restrictions). These are the only OWL 2 DL
violations of data + top-level.
*Recommendation:* keep only the datatype-property declaration, moving the domain and range to it
(change P1 in section 5).

**A2. The property chain on `isSpecializationOfVariable` may point to the wrong variable.**
`isSpecializedAccordingTo ∘ isSpecializationOn ⊑ isSpecializationOfVariable`: if a variable *X* is
specialised according to a specification *VS*, and *VS* constrains the independent variable *IV*,
then *X* is inferred to be a specialisation of *IV*. According to the comments and to CQ7–CQ10 in
`competency-questions.md`, *X* is a specialisation of the *dependent* variable it was derived from,
while *IV* is the variable whose values are fixed. Unless the intent is different, the chain infers
the wrong statement. This is internal to the data module; it is reported because it surfaced during
the review.

### B. Placement in the top-level and choice of super-properties

**B1. Data processes are only `Entity`.** `DataGeneratingProcess`, `DataConsumingProcess` and
`DataTransformation` are described as processes, which in the top-level are `Event`s (or `Action`s
when an agent executes a task). In ccso, 20 classes are subclasses of them (e.g. `ccso:ClimateSimulation`,
`ccso:Downscaling`, `ccso:Aggregation`). Their inputs and outputs (`hasInput`, `hasOutput`) are
participants in the process, which the top-level models with `hasParticipant` / `isParticipantIn`.
*Recommendation:* `DataGeneratingProcess`, `DataConsumingProcess` ⊑ `top:Event`; `hasInput`,
`hasOutput` ⊑ `top:hasParticipant`; `isInputOf`, `isOutputOf` ⊑ `top:isParticipantIn` (P3).
`top:Action` would be more specific, but it requires an agent and an executed task, which automated
processes may not have in the data.

**B2. Points are not regions.** `Point` (with `GeodeticPoint` and `Instant`) is only an `Entity`,
while `data:Region` is a `top:Region`. In the top-level (DUL), a `Region` is any region of a
dimensional space used as a value (e.g. "34° E, 20° S", "August 9th, 2004"); a point is a degenerate
region. *Recommendation:* `Point ⊑ top:Region` (P4).

**B3. Time is modelled twice.** `data:TemporalRegion` with `hasStartDateTime` / `hasEndDateTime`
(`xsd:dateTime`) duplicates `top:TimeInterval` with `startTime` / `endTime` (`xsd:dateTime`), which
was aligned to DUL and to OWL 2 datatypes in the top-level review. *Recommendation:*
`TemporalRegion ⊑ top:TimeInterval`, `hasStartDateTime ⊑ top:startTime`,
`hasEndDateTime ⊑ top:endTime` (P2). The top-level allows at most one start and one end time per
interval, which matches the intended use.

**B4. Dimensional spaces are concepts, not regions.** In DUL, "a dimensional space is a maximal
Region". In the data module, a `DimensionalSpace` is an `IndependentVariable` (the "default
variable" with values on itself, see the module header), hence a `Concept`. Since the top-level
now declares `Abstract ⊥ Object` (and `Concept ⊑ SocialObject ⊑ Object`), a dimensional space can
never also be a region. This is a deliberate and documented design choice, and it is consistent
with how the module relates spaces and regions: through separate individuals linked by `data:hasRegion`,
`hasBoundingRegion`, etc. It should be kept in mind when data are produced. For example, the bounded
dimensional space of an area and the area's region must be two distinct individuals.
*Recommendation:* mention the divergence from DUL in the comment of `DimensionalSpace`.

**B5. `hasSelectedRegion` uses `top:hasRegion` instead of `top:parametrises`.**
`VariableSpecialization` is a `top:Parameter`. The region it selects is the region that the
parameter constrains, which is what the top-level's `parametrises` / `isParametrisedBy` (DUL
`parametrizes`) express. `hasRegion` instead relates an entity to the region of one of its own
qualities. *Recommendation:* `hasSelectedRegion ⊑ top:parametrises`,
`isSelectedRegionFor ⊑ top:isParametrisedBy` (P6).

**B6. Component variables are not parts.** The module restricts parthood on variables
(`Variable ⊑ hasPart only Variable`, `FiniteVariable ⊑ hasPart only FiniteVariable`), but it
relates a composite variable to its components with `hasComponentVariable`, which is not a
parthood property. So the restrictions never apply to components: nothing infers that the
components of a finite variable are finite. *Recommendation:* `hasComponentVariable ⊑ top:hasComponent`,
`isComponentVariableOf ⊑ top:isComponentOf` (P5). `hasSubDimensionalSpace` is a sub-property of
`hasComponentVariable` and follows.

**B7. Literal values are not under `top:hasDataValue`.** `hasPointValue`, `hasRegionValue`,
`hasResolutionValue`, `hasOffsetValue`, `hasPeriodValue` and `hasInPeriodResolutionValue` encode
literal values. The top-level now replicates DUL's root for this, `hasDataValue`.
*Recommendation:* declare them sub-properties of `top:hasDataValue` (P8). `hasPeriodValue` is also
declared a sub-property of `owl:topDataProperty`, which is redundant.

**B8. The resolution-like properties are treated inconsistently.** `hasResolution` (and its exact
and approximate variants) is a sub-property of `top:hasRegion`, while the analogous `hasOffset`,
`hasPeriod` and `hasInPeriodResolution` hang directly under `associatedWith`. If resolutions are
regions (sizes in the dimensional space), offsets and periods are too. *Recommendation:* treat
them the same way, either all under `top:hasRegion` or all under `associatedWith`. This is a
modelling decision for the module's authors.

### C. Overlaps and name clashes with the top-level

| Data term | Top-level term | Relationship |
|---|---|---|
| `data:Dataset` (≡ `FiniteVariable`, ⊑ `Variable` ⊑ `Concept`) | `top:Dataset` (⊑ `Collection`, "a collection of data") | **Same local name, different notions.** Both are compatible with each other logically, but a dataset is a variable in one and a collection in the other. `top:Dataset` is used only in a ccso documentation file (`ccso/doc/modules/dataset.rdf`). |
| `data:DataSource`, `hasURL`, `DataFormat`, `hasAvailableDataFormat`, `hasDataSerialization` | `top:Media`, `hasDownloadURL`, `mediaType`, `hasDataSchema`, `hasMedia` | Two models of the same thing: a downloadable serialisation of data. `top:Media` requires exactly one media type, URL and data schema; `data:DataSource` allows several formats. So one cannot simply be declared a subclass of the other. |
| variables, component variables, dimensional spaces | `top:DataSchema`, `SchemaAttribute`, `hasSchemaAttribute` | The data module describes the structure of a dataset through its variables. The top-level's data schema and schema attributes describe the same structure in a different way. |
| `data:hasOutput` (data process → dataset) | `top:hasOutput` (action → object) | Same local name. With P3, data processes are `Event`s, not `Action`s, so `data:hasOutput` cannot be a sub-property of `top:hasOutput` (domain `Action`); it becomes a sub-property of `hasParticipant`, like `top:hasOutput` could be. |
| `data:hasRegion` / `isRegionOf` (dimensional space ↔ the regions it contains) | `top:hasRegion` / `isRegionFor` (entity ↔ region of one of its qualities) | **Same local name, different relations.** `data:hasRegion` is not, and should not be, a sub-property of `top:hasRegion`. Since the module also uses `top:hasRegion` (as super-property of the bounding-region and resolution properties), the clash is easy to get wrong in queries. A distinct name (e.g. `containsRegion`) would avoid confusion. |
| `data:Region` | `top:Region` | Same local name; `data:Region ⊑ top:Region`, which is correct. Only a readability issue. |

*Recommendation:* decide which module owns the description of datasets and their distributions.
The data module's model is richer and is the one used by ccso. If it is the reference, the overlapping
top-level terms (`top:Dataset`, `Media`, `DataSchema`, `SchemaAttribute` and their properties) could
be deprecated, or linked to the data terms where the meanings match.

### D. Annotations

- **No Italian labels or comments.** The top-level is bilingual (en/it); the data module is English
  only.
- **13 terms have no comment:** `Binning`, `IntervalSampling`, `PeriodicBinning`, `PeriodicRegion`,
  `Point`, `Quantization`, `Region`, `RegularBinning`, `RegularPeriodicBinning`, `Sampling`,
  `SimpleRegularBinning`, `SinglePeriodicBinning`, `hasURL`.
- **2 terms have no `rdfs:isDefinedBy`:** `Instant`, `specifiesVariableSpecializationFor`.
- **Label style:** class labels are in Title Case ("Bounded Dimensional Space") except
  "Temporal region"; the top-level uses sentence case ("Physical object", "Time interval").
- **Typos in comments:** "indepedent", "depedent", "inependent", "georaphic", "encompassin",
  "possibile", "direclty", "anelement", "streching", "indefinetely", "expressable", "i,e".
  The header uses "serialisation" while the property is `hasDataSerialization`.
- **The ontology header mentions terms that do not exist:** `data:Grid` and
  `data:hasDataSerialisation` (the property is `hasDataSerialization`).

## 4. Proposed changes

| ID | Change | Finding |
|---|---|---|
| P1 | Declare `hasStartDateTime` / `hasEndDateTime` only as datatype properties (domain `TemporalRegion`, range `xsd:dateTime`). | A1 |
| P2 | `TemporalRegion ⊑ top:TimeInterval`; `hasStartDateTime ⊑ top:startTime`; `hasEndDateTime ⊑ top:endTime`. | B3 |
| P3 | `DataGeneratingProcess`, `DataConsumingProcess` ⊑ `top:Event`; `hasInput`, `hasOutput` ⊑ `top:hasParticipant`; `isInputOf`, `isOutputOf` ⊑ `top:isParticipantIn`. | B1 |
| P4 | `Point ⊑ top:Region`. | B2 |
| P5 | `hasComponentVariable ⊑ top:hasComponent`; `isComponentVariableOf ⊑ top:isComponentOf`. | B6 |
| P6 | `hasSelectedRegion ⊑ top:parametrises`; `isSelectedRegionFor ⊑ top:isParametrisedBy` (instead of `hasRegion` / `isRegionFor`). | B5 |
| P8 | The six `…Value` datatype properties ⊑ `top:hasDataValue`. | B7 |

Not tested, because they are decisions for the module's authors: A2 (property chain), B4 (comment
only), B8 (resolution-like properties), the overlaps of section C, and the annotations of section D.

## 5. Impact of the proposed changes

Each change was applied (together with P1, which is needed for a clean DL check) to a copy of
`data.owl`. It was then checked with all the dependent modules and the probe data, alone and with
all the changes combined.

| Change | Consistency | New inferences (vs current module) | OWL 2 DL |
|---|---|---|---|
| P1 | unchanged | none | data + top-level becomes **in profile** |
| P2 | unchanged | `TemporalRegion` ⊑ `TimeInterval`, `TemporalEntity` | in profile |
| P3 | unchanged | the 3 data process classes and 20 ccso process classes (e.g. `ccso:ClimateSimulation`, `ccso:Downscaling`) become `Event`s | in profile |
| P4 | unchanged | `Point`, `GeodeticPoint`, `Instant` ⊑ `Region` ⊑ `Abstract` | in profile |
| P5 | unchanged | none on the current data | in profile |
| P6 | unchanged | none on the current data | in profile |
| P8 | unchanged | none | in profile |
| all together | unchanged | the union of the above, nothing else | in profile |

"Unchanged" means that the only problems are the known mdx ones (an unsatisfiable class and an
inconsistent test dataset, see the top-level review, 5.3). All the new inferences are the intended
ones. None of the changes causes an inconsistency, an unsatisfiable class or a loss of inferences
in ccso or the other modules. They are therefore all safe to apply.

## 6. Prioritised recommendations

1. **Fix the date-time properties (A1, P1).** This is the only OWL 2 DL violation, and it also
   damages the top-level's time axioms in any merge.
2. **Align time, processes and points with the top-level (B1–B3: P2, P3, P4).** Data then reuses the
   top-level's time model and process model, and ccso's processes become events.
3. **Use the more specific top-level properties (B5–B7: P5, P6, P8).**
4. **Check the property chain of `isSpecializationOfVariable` (A2).**
5. **Decide the ownership of the dataset and distribution model (C)**, and rename `data:hasRegion` to
   avoid the clash with `top:hasRegion`. Renaming is a breaking change for existing data.
6. **Annotations (D):** add the missing comments and `isDefinedBy`, fix the typos and the header,
   harmonise label case, and consider Italian labels and comments.

## 7. Reproducing the checks

The data module imports the top-level by its w3id IRI; to use the local copy, merge the two files
(the import is then already satisfied) or use an XML catalog.

```bash
T=ontologies/top-level/top-level.owl
D=ontologies/data/data.owl
robot merge --input $T --input $D --output /tmp/data-top.owl
robot validate-profile --input /tmp/data-top.owl --profile DL --output data-top-dl.txt
robot reason --reasoner hermit --input /tmp/data-top.owl --output /tmp/out.owl
```

## 8. Changes applied

| Finding | Change in `data.owl` |
|---|---|
| **A1** | `hasStartDateTime` / `hasEndDateTime` are now only datatype properties (domain `TemporalRegion`, range `xsd:dateTime`). The declaration of `xsd:dateTime` as a class is removed. |
| **A2** | The property chain `isSpecializedAccordingTo ∘ isSpecializationOn ⊑ isSpecializationOfVariable` is removed. |
| **B2** | `Point ⊑ top:Region`, instead of `top:Entity`. `GeodeticPoint` and `Instant` follow. |
| **B4** | The comment of `DimensionalSpace` now explains the divergence from DUL. A dimensional space is a variable, hence a `top:Concept`, so it is always a distinct individual from its regions, including its bounding regions. |
| **B5** | `hasSelectedRegion ⊑ top:parametrises` and `isSelectedRegionFor ⊑ top:isParametrisedBy`, instead of `top:hasRegion` / `top:isRegionFor`. |
| **B6** | `hasComponentVariable ⊑ top:hasComponent` and `isComponentVariableOf ⊑ top:isComponentOf`. The parthood restrictions on `Variable` and `FiniteVariable` now apply to component variables. |
| **D** | Typos fixed in comments and in the ontology header. These include "corrisponding", "latitute" and "more specific that", found in a second pass. In the header, `data:hasDataSerialisation` became `data:hasDataSerialization`, and `data:Grid` (which does not exist) became `data:Binning`. "Serialisation" is now spelled "serialization", like the property names. Class labels are all in Title Case ("Temporal region" became "Temporal Region"); property labels stay in lower case. `rdfs:isDefinedBy` was added to `Instant` and `specifiesVariableSpecializationFor`. Comments were added to the 13 terms that had none. |

Not applied: B1 and B3 (processes as `Event`s, time aligned with `top:TimeInterval`), B7 and
B8 (value properties and resolution-like properties), the overlaps and name clashes of section C,
and Italian annotations.

**Checks after the changes**, with the same method as section 5:
- Data + top-level is **in OWL 2 DL** and accepted by HermiT in strict mode.
- On the dependent modules with their test data, and on the probe data regenerated from the
  updated modules:
  - no change in consistency or unsatisfiable classes;
  - no new OWL 2 DL violation.
- The only new inferences are those of B2: `Point`, `GeodeticPoint`, `Instant` and their instances
  become `top:Region`s, hence `Abstract`.
- The only lost inference comes from A2. On an example of the removed chain, the specialised
  variable is no longer inferred to be a `DerivedVariable` through the wrong
  `isSpecializationOfVariable` link.

The comments added for `IntervalSampling`, `SimpleRegularBinning`, `SinglePeriodicBinning` and
`PeriodicRegion` interpret the class names and their position in the hierarchy, since there was
no other documentation. They should be checked by the module's authors.
