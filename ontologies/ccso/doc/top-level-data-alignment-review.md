# CCSO: review against the top-level and data ontologies

**Subject:** `ontologies/ccso/ccso.owl` (Core Climate Services Ontology), namespace
`https://w3id.org/hacid/onto/ccso/`, prefix `ccso:`.
**Reference:** the HACID top-level ontology, `ontologies/top-level/top-level.owl` (prefix `top:`), and
the data ontology, `ontologies/data/data.owl` (prefix `data:`), in their current state (after the
changes described in
[`../../top-level/doc/dul-consistency-review.md`](../../top-level/doc/dul-consistency-review.md) and
[`../../data/doc/top-level-alignment-review.md`](../../data/doc/top-level-alignment-review.md)).
**Other imports:** `core/judgement` (prefix `jdg:`), used only for `Assessment`.

> Sections 2–7 describe the module **as reviewed**. Section 5 reports the impact of the proposed
> changes, tested on copies. Section 8 lists the changes that were then applied to `ccso.owl`.

## 1. Scope and method

The review checks how CCSO builds on the top-level and data modules:

1. where its classes and properties sit in the top-level hierarchy, and whether that placement
   matches the meaning of the top-level (DUL-based) and data terms;
2. whether the module is logically consistent with its imports and stays within OWL 2 DL;
3. whether it overlaps with, or clashes with, terms of the top-level or data modules;
4. whether its annotations follow the conventions of the other modules.

How it was done:

- **Structure.** The module's axioms were extracted with rdflib.
- **Reasoning and profile.** HermiT (strict datatype mode) and ROBOT `validate-profile`, run on
  ccso + data + top-level + judgement (and its imports).
- **Impact.** The changes proposed in section 4 were applied one by one, and then all together, to
  copies of `ccso.owl`. Each copy was checked together with all the other local modules (data, mdx,
  core) and the probe data used in the previous reviews: one example link for every property of the
  modules with a declared domain or range, plus one instance of every module class. For each change
  I compared consistency, unsatisfiable classes, inferred class memberships and OWL 2 DL violations
  with the current module.

## 2. Overview

The module defines 81 terms: 46 classes, 34 object properties and 1 datatype property. It also
contains 12 named individuals for the emission scenarios (7 RCPs and 5 SSPs) in the
`https://w3id.org/hacid/data/cs/scenarios/` namespace.

It anchors to its imports as follows.

| Imported term | Used in `ccso.owl` as | CCSO terms |
|---|---|---|
| `top:Concept` | superclass | `AssetType`, `ClimatePhenomenonType` (and `HazardType`), `ImpactType`, `VulnerabilityType`, `EmissionScenario` (and its 2 subclasses), `GlobalWarmingLevel` |
| `top:classifies` | in restrictions | `XType ⊑ classifies only X` for the four type classes |
| `top:Situation` | superclass | `ClimatePhenomenon`, `Impact`, `Vulnerability`, `Request` |
| `top:Object` | superclass | `Asset` |
| `top:Entity` | superclass | `ClimateModel` (and its 4 subclasses) |
| `jdg:Judgement` | superclass | `Assessment` |
| `data:Dataset` | superclass | `Projection` (and its 5 subclasses) |
| `data:DataGeneratingProcess` | superclass | `ProjectionProduction`, `Simulation` (and so all 20 process classes) |
| `data:DataTransformation` | superclass | `ProjectionTransformation` |
| `data:hasInput`, `data:hasOutput` | in restrictions | `ProjectionProduction ⊑ hasOutput some Projection`, `ProjectionTransformation ⊑ hasInput some Projection` |
| `data:Variable` | domain / range | `hasIndicator`, `isIndicatorOf` |
| `top:classifies` / `top:isClassifiedBy` | super-property | `isScenarioReferredBy`, `isGlobalWarmingLevelReferredBy` / `refersToScenario`, `refersToGlobalWarmingLevel` |
| `top:associatedWith` | super-property | the other 30 object properties |
| `top:acronym` | on individuals | the scenario individuals |

The single datatype property, `productId`, has no super-property.

Other top-level terms could be relevant to CCSO, but the module does not use them:

- `Description`, for models;
- `Parameter`, for thresholds;
- `Agent`, for maintainers;
- `isPartOf`, for ensemble members;
- `involves` / `isInvolvedIn`, for the participants of a situation;
- `isRelatedToConcept`, for links between types;
- `identifier`, for identifiers;
- `Event` and `hasParticipant`, for processes.

### Reasoning results

| Check | Result |
|---|---|
| ccso + imports, HermiT (strict) | ✅ Consistent, no unsatisfiable classes. |
| ccso + imports, OWL 2 DL profile | ✅ No violation caused by ccso. The violations reported in the merge come from other modules (e.g. `rdf:Property` in evidence, the undeclared `ar:hasEventuality` in agentrole); they are the same with or without ccso. |
| ccso + all modules + probe data | ✅ Consistent. The only problems are the known ones in mdx (see the top-level review, 5.3). |

Placement of the CCSO classes in the top-level hierarchy, as inferred by the reasoner:

| CCSO classes | Inferred top-level superclasses |
|---|---|
| the type classes, `EmissionScenario` and its subclasses, `GlobalWarmingLevel` | `Concept` ⊑ `SocialObject` ⊑ `Object` |
| `Projection` and its subclasses | `data:Dataset` ⊑ `data:Variable` ⊑ `Concept` |
| the process classes (simulations, productions, transformations, downscalings) | `data:DataGeneratingProcess`, and so only `Entity` |
| `ClimateModel` and its subclasses | only `Entity` |
| `ClimatePhenomenon`, `Impact`, `Vulnerability`, `Request` | `Situation` |
| `Assessment` | `jdg:Judgement` (and so `Situation`, via judgement) |
| `Asset` | `Object` |

## 3. Findings

Severity: **A** = logical or technical problem. **B** = placement or property choice that does not
match the meaning of the top-level or data terms, or misses a term that fits. **C** = overlap or
name clash. **D** = annotations, header and individuals.

### A. Logical and technical problems

No logical problems: the module is consistent with its imports and within OWL 2 DL. Two
modelling errors in the hierarchy have logical effects.

**A1. The two ensemble experiments are not simulations.**
`PerturbedParameterClimateEnsembleSimulation` and `ClimateModelIntercomparisonExperiment` are
declared only as subclasses of `EnsembleProjectionProduction`. Their names and comments ("a set of
simulations run with the same model / using multiple models") make them ensemble simulations.
`EnsembleSimulation` and `ClimateSimulation` are the classes that carry the simulation axioms
(`usesModel some ClimateModel`, disjointness from `SingleSimulation`), so a reasoner does not apply
them to these two classes today. *Proposal Q3.*

**A2. `isMaintainedBy` and `maintains` are incomplete.**
`isMaintainedBy` has domain `top:Entity` and no range; its inverse `maintains` has range
`top:Entity` and no domain. The comment ("link an object to a maintainer") implies that the
maintainer is an agent. As declared, any entity can maintain any entity. *Proposal Q8.*

**A3. `relatedWithPhenomenon` is underspecified.**
It is declared symmetric and also `owl:inverseOf` itself. This is redundant but harmless. It has
no domain, range or comment, and nothing else in the module uses it, so its intended use is
unclear: phenomena (`ClimatePhenomenon`) or phenomenon types (`ClimatePhenomenonType`)? Either
specify it or remove it.

**A4. `Downscaling ⊑ isDownscalingOf some ClimateSimulation` is too strong for statistical downscaling.**
`StatisticalDownscaling` inherits the axiom, so every statistical downscaling must start from a
climate simulation. Its own comment, however, says that the input is "a climate projection", which
need not come from a simulation (e.g. it can be another statistical product). If projections that do
not come from simulations can be downscaled, move the restriction to `DynamicalDownscaling`, or
state it on `Downscaling` as `data:hasInput some Projection` (already inherited from
`ProjectionTransformation`). Not tested: it is a decision for the authors.

### B. Placement in the top-level and choice of super-properties

**B1. `GlobalWarmingLevel` is a parameter.**
A global warming level is "a threshold specified as global temperature increase". In the top-level
(as in DUL), this is exactly a `Parameter`: a concept that constrains or selects values of a region
("e.g. VeryHigh"). *Proposal Q1:* `GlobalWarmingLevel ⊑ top:Parameter`.
`refersToGlobalWarmingLevel ⊑ isClassifiedBy` still holds, because `Parameter ⊑ Concept`.

**B2. `ClimateModel` is a description.**
A climate model is "a representation of the Earth's climate system". In the top-level, a
representation that uses concepts to describe something is a `Description`, i.e. a `SocialObject`,
like a plan or a theory. Today the class is only an `Entity`, so nothing distinguishes a model from
a physical object or an event. *Proposal Q2:* `ClimateModel ⊑ top:Description`. If the model is
meant primarily as software (code that is run), `top:InformationEntity` is an alternative. The two
readings can coexist in DUL fashion: the software is an information entity that expresses the
description.

**B3. `EmissionScenario` as `Concept` or `Description`.**
An emission scenario is "a projected trajectory of future emissions, concentrations and impacts".
That is a description of a possible future: a `Description` in DUL terms, with projections that
satisfy it. The module uses it instead as a `Concept` that classifies projections
(`refersToScenario ⊑ isClassifiedBy`). This is a legitimate simplification and it is consistent.
Changing it would require replacing `refersToScenario ⊑ isClassifiedBy` with
`top:satisfies`-like properties. Report only; no change proposed.

**B4. Situations and their participants.**
`ClimatePhenomenon`, `Impact`, `Vulnerability` and `Request` are `Situation`s. This fits well:

- an impact relates a phenomenon, an asset and an impact type;
- a vulnerability relates an asset, impact types and assessment factors.

So all four are n-ary relational contexts, not qualities or events. (`Vulnerability` could also be
read as a `Quality` of an asset; the situation reading is justified by its n-ary nature, and is
kept.) However, the properties that link a situation to the entities it involves are generic
`associatedWith`. The top-level has `involves` / `isInvolvedIn` for exactly this purpose.
*Proposal Q4:*

- `hasImpact`, `sufferedImpact`, `hasVulnerability` ⊑ `top:isInvolvedIn`;
- `isSufferedImpactOf`, `isVulnerabilityOf` ⊑ `top:involves`.

`hasImpact` (from phenomenon to impact) relates two situations. It is included because, in the
top-level, `isInvolvedIn` has range `Situation` and no domain restriction that excludes situations.

**B5. Relations between types.**
Twelve properties relate two type concepts (e.g. a hazard type and an impact type). In the
top-level, links between concepts go under `isRelatedToConcept`. *Proposal Q5:*

- `causesPhenomenaOfType`, `isCausedByPhenomenaOfType`;
- `hasPotentialImpactType`, `isPotentialImpactTypeOf`;
- `hasPotentialVulnerabilityType`, `isPotentialVulnerabilityTypeOf`;
- `potentiallySuffersImpactType`, `isPotentiallySufferedImpactTypeOf`;
- `potentiallyAssertsVulnerabilityToImpactType`, `isImpactTypeOfAssertedVulnerability`;
- `hasIndicator`, `isIndicatorOf` (`data:Variable` is a `Concept`).

All twelve go ⊑ `top:isRelatedToConcept`.

The properties from an instance to a type (`suffersImpactType`, `isSufferedImpactTypeOf`,
`isVulnerabilityToImpactType`, `hasPotentiallyImpactedVulnerability`,
`assertsVulnerabilityToImpactType`) are not classification in the strict sense: an asset that
suffers an impact type is not classified by it. They are therefore correctly left under
`associatedWith`.

**B6. Ensemble members.**
`isMemberSimulationOf` relates a simulation to the ensemble simulation that includes it. That is
parthood. *Proposal Q6:* `isMemberSimulationOf ⊑ top:isPartOf`. The module has no inverse property;
one could be added (`hasMemberSimulation ⊑ top:hasPart`).

**B7. Identifiers.**
`productId` has no super-property. *Proposal Q7:* `productId ⊑ top:identifier`.

**B8. Processes and models.**
All the CCSO processes inherit their top-level placement from `data:DataGeneratingProcess`, which is
only an `Entity`. If data's recommendation B1 is applied (`DataGeneratingProcess ⊑ top:Event`,
`hasInput` / `hasOutput` ⊑ `hasParticipant`), all 20 CCSO process classes become events with no
change in CCSO (tested in the data review, P3). After that, `usesModel` / `isModelUsedBy` could go
under `top:hasParticipant` / `top:isParticipantIn`. Similarly, `hasDownscaling` / `isDownscalingOf`,
which relate two processes, could go under `top:precedes` / `top:follows`. These depend on the data
decision, and are not proposed now.

**B9. `isMaintainedBy` and agents.**
See A2. *Proposal Q8:* `isMaintainedBy` range `top:Agent`; `maintains` domain `top:Agent`.

### C. Overlaps and name clashes

**C1. `ccso:Aggregation` vs `data:Aggregation`.**
The two modules define two different `Aggregation` classes:

- `ccso:Aggregation` is a process: a rescaling of a projection to a coarser resolution.
- `data:Aggregation` is a `Concept`: the specification that a dependent variable is aggregated
  along one or more variables (`aggregatesVariable`), with suggested quantizations. It does not
  fix the aggregation function nor the quantization.

They are disjoint in practice (a `DataGeneratingProcess` vs a `Concept`), and their IRIs differ, so
there is no logical conflict. However, both are labelled "Aggregation", which is confusing in tools
and queries that work on labels. Rename one of them. *Resolved* by renaming the data class to
`data:AggregationSpecification` (see section 8).

**C2. The header comment describes data terms.**
The ontology's `rdfs:comment` mentions "object properties such as spatial and temporal coverage,
spatial and temporal resolution". Those properties are defined in the data module, not in CCSO
(they were moved there). The comment should describe the current module.

No other overlap: CCSO does not redefine any top-level or data term.

### D. Annotations, header and individuals

**D1. Header.**

- `dc:description` points to `ontologies/climate-services/visual/simpler_model_rev.png`, which does
  not exist in the repository (there is no `climate-services` folder and no file with that name).
- The default namespace is declared as `https://w3id.org/hacid/onto/ccso#`, but all terms use `/`;
  it is unused and misleading.
- See also C2.

**D2. Missing comments.**

- 9 classes have no comment: `Asset`, `AssetType`, `ClimatePhenomenon`, `ClimatePhenomenonType`,
  `HazardType`, `Impact`, `ImpactType`, `Simulation`, `VulnerabilityType`.
- 18 object properties have no comment: `hasPotentialImpactType`, `hasPotentialVulnerabilityType`,
  `hasPotentiallyImpactedVulnerability`, `hasVulnerability`, `isImpactTypeOfAssertedVulnerability`,
  `isModelUsedBy`, `isPotentialImpactTypeOf`, `isPotentialVulnerabilityTypeOf`,
  `isPotentiallySufferedImpactTypeOf`, `isSufferedImpactOf`, `isSufferedImpactTypeOf`,
  `isVulnerabilityOf`, `isVulnerabilityToImpactType`, `maintains`, `potentiallySuffersImpactType`,
  `relatedWithPhenomenon`, `sufferedImpact`, `suffersImpactType`.
- `usesModel` has two English comments: one is written from the model's point of view ("a climate
  model is used by an experiment") and belongs to its inverse `isModelUsedBy`.

**D3. Labels.**

- `EnsembleProjectionProduction` is labelled "Projection Ensemble Production"; the word order
  differs from the IRI (it should be "Ensemble Projection Production").
- `isPotentialImpactTypeOf` is labelled "is potential impact of" (missing "type").
- Two class labels are not in Title Case, unlike all the others and the convention adopted for the
  data module: "Greenhouse gas concentration pathway", "Shared socio-economic pathway".
- `productId` is labelled "product ID". The capitalised acronym is fine, but the IRI uses "Id".
- There are no Italian labels or comments, unlike the top-level.

**D4. Scenario individuals.**

- SSP1 has the acronym "SS1" and the title "SS1: Sustainability ('Taking the Green Road')"; both
  should read SSP1. The other SSPs use "SSP 2" … "SSP 5" (with a space) as acronym and "SSP2: …"
  (without) in the title.
- SSP labels use the plural, "Shared Socioeconomic Pathways 1": it should be the singular
  "Shared Socioeconomic Pathway 1", like "Representative Concentration Pathway 2.6".
- The individuals live in a data namespace (`https://w3id.org/hacid/data/cs/scenarios/`). Their
  `rdfs:isDefinedBy` points to the ccso ontology, which is correct for reference individuals
  shipped with the module. Moving them into a separate data file is an option if the module is meant
  to contain only the schema.

## 4. Proposed changes

| ID | Change | Finding |
|---|---|---|
| Q1 | `GlobalWarmingLevel ⊑ top:Parameter` (instead of `top:Concept`). | B1 |
| Q2 | `ClimateModel ⊑ top:Description` (instead of `top:Entity`). | B2 |
| Q3 | `PerturbedParameterClimateEnsembleSimulation`, `ClimateModelIntercomparisonExperiment` ⊑ `EnsembleSimulation`, `ClimateSimulation` (keeping `EnsembleProjectionProduction`). | A1 |
| Q4 | `hasImpact`, `sufferedImpact`, `hasVulnerability` ⊑ `top:isInvolvedIn`; `isSufferedImpactOf`, `isVulnerabilityOf` ⊑ `top:involves`. | B4 |
| Q5 | The 12 type-to-type properties ⊑ `top:isRelatedToConcept`. | B5 |
| Q6 | `isMemberSimulationOf ⊑ top:isPartOf`. | B6 |
| Q7 | `productId ⊑ top:identifier`. | B7 |
| Q8 | `isMaintainedBy` range `top:Agent`; `maintains` domain `top:Agent`. | A2, B9 |

Not tested, because they are decisions for the module's authors: A3 (`relatedWithPhenomenon`), A4
(downscaling input), B3 (scenarios as descriptions), B8 (depends on data B1), the clash and header
comment of section C, and the annotations of section D.

## 5. Impact of the proposed changes

Each change was applied to a copy of `ccso.owl`. It was then checked with all the other modules and
the probe data, alone and with all the changes combined.

| Change | Consistency | New inferences (vs current module) | OWL 2 DL |
|---|---|---|---|
| Q1 | unchanged | `GlobalWarmingLevel` ⊑ `Parameter`, `Characteristic` | unchanged |
| Q2 | unchanged | `ClimateModel` and subclasses ⊑ `Description` ⊑ `SocialObject` ⊑ `Object` | unchanged |
| Q3 | unchanged | the two ensemble classes ⊑ `EnsembleSimulation`, `ClimateSimulation`, `Simulation` (and so `usesModel some ClimateModel`) | unchanged |
| Q4 | unchanged | none on the current data | unchanged |
| Q5 | unchanged | none on the current data | unchanged |
| Q6 | unchanged | none on the current data | unchanged |
| Q7 | unchanged | none on the current data | unchanged |
| Q8 | unchanged | maintainers become `Agent`s | unchanged |
| all together | unchanged | the union of the above (60 new facts on the probe data), nothing lost | unchanged |

"Unchanged" means:

- for consistency, that the only problems are the known mdx ones (an unsatisfiable class and an
  inconsistent test dataset, see the top-level review, 5.3);
- for OWL 2 DL, that the violations reported are the same 5 as for the current module, all from
  other modules.

The new property inferences of Q4–Q7 do not show up as class memberships, because the top-level's
`involves`, `isRelatedToConcept`, `isPartOf` and `identifier` add no domain or range that the probe
individuals did not already have. Their benefit is for queries: e.g. a query on `top:involves` now
finds the assets of impacts and vulnerabilities.

None of the changes causes an inconsistency, an unsatisfiable class or a loss of inferences in CCSO
or the other modules. All are safe to apply.

## 6. Prioritised recommendations

1. **Fix the hierarchy of the ensemble experiments and complete the maintainer properties (A1, A2:
   Q3, Q8).** These are modelling errors with logical effects.
2. **Place models and warming levels in the top-level (B1, B2: Q1, Q2).**
3. **Use the more specific top-level properties (B4–B7: Q4–Q7).** They make the module queryable
   through the top-level's generic properties.
4. **Resolve the `Aggregation` clash and update the header comment (C1, C2).**
5. **Annotations and individuals (D):**
   - add the missing comments and move the misplaced `usesModel` comment;
   - fix the labels (word order, missing "type", Title Case);
   - fix the SSP1 acronym and title and the plural in the SSP labels;
   - remove the dead image link and the unused `#` namespace;
   - consider Italian labels and comments.
6. **Decide on `relatedWithPhenomenon` (A3) and the input of downscaling (A4).**
7. **After data B1 (processes as events), revisit the process properties (B8).**

## 7. Reproducing the checks

CCSO imports the top-level, data and judgement modules by their w3id IRIs. To use the local copies,
merge the files (the imports are then already satisfied) or use an XML catalog.

```bash
T=ontologies/top-level/top-level.owl
D=ontologies/data/data.owl
C=ontologies/ccso/ccso.owl
J=ontologies/core/judgement.owl
robot merge --input $T --input $D --input $J --input $C --output /tmp/ccso-all.owl
robot validate-profile --input /tmp/ccso-all.owl --profile DL --output ccso-dl.txt
robot reason --reasoner hermit --input /tmp/ccso-all.owl --output /tmp/out.owl
```

## 8. Changes applied

| Finding | Change in `ccso.owl` |
|---|---|
| **A1** (Q3) | `PerturbedParameterClimateEnsembleSimulation` and `ClimateModelIntercomparisonExperiment` are now also subclasses of `EnsembleSimulation` and `ClimateSimulation`. |
| **A2, B9** (Q8) | `isMaintainedBy` has range `top:Agent`; `maintains` has domain `top:Agent`. |
| **B1** (Q1) | `GlobalWarmingLevel ⊑ top:Parameter`, instead of `top:Concept`. |
| **B2** (Q2) | `ClimateModel ⊑ top:Description`, instead of `top:Entity`. |
| **B4** (Q4) | `hasImpact`, `sufferedImpact`, `hasVulnerability` ⊑ `top:isInvolvedIn`; `isSufferedImpactOf`, `isVulnerabilityOf` ⊑ `top:involves` (instead of `top:associatedWith`). |
| **B5** (Q5) | The 12 type-to-type properties ⊑ `top:isRelatedToConcept` (instead of `top:associatedWith`). |
| **B6** | Instead of Q6, `isMemberSimulationOf` is removed: it was a remnant of a previous version. |
| **B7** (Q7) | `productId ⊑ top:identifier`. |
| **C2, D1** | The header comment no longer lists coverage and resolution properties as CCSO features; it refers to the data ontology for them. The dead `dc:description` image link (and the then unused `dc:description` declaration and `dc:` prefix) are removed. The default namespace is now `https://w3id.org/hacid/onto/ccso/`. |
| **D2** | Comments were added to the 9 classes and the 18 object properties that had none. The comment of `usesModel` written from the model's point of view was moved to `isModelUsedBy`. |
| **D3** | Labels fixed: "Ensemble Projection Production", "is potential impact type of", "Greenhouse Gas Concentration Pathway", "Shared Socioeconomic Pathway". |
| **D4** | The 12 scenario individuals (RCPs and SSPs) are removed: they are now maintained in the corresponding knowledge graph. |

Not applied: A3 (axioms of `relatedWithPhenomenon`; only a comment was added, and the property was
removed afterwards, see below), A4 (input of
downscaling; applied afterwards, see below), B3 (scenarios as descriptions), B8 (process properties, which depend on data B1),
and Italian annotations. The `Aggregation` clash (C1) was resolved afterwards in the data module
(see below).

**Checks after the changes**, with the same method as section 5:
- No change in consistency or unsatisfiable classes, on the probe data and on all the test data of
  the other modules: the only problems are the known mdx ones.
- No new OWL 2 DL violation (the same 5, all from other modules).
- The new inferences are exactly those of Q1, Q2, Q3 and Q8 (section 5).
- The only lost inferences are the class memberships of the removed scenario individuals.

The added comments (in particular those of `Asset`, `ClimatePhenomenon`, `Impact` and the
type classes) were written from the class names, their axioms and the comments of related terms,
since there was no other documentation. They should be checked by the module's authors.

**C1, applied afterwards.** The clash is resolved on the data side: `data:Aggregation` is renamed
`data:AggregationSpecification` (label "Aggregation Specification"), the name already used by the
comments of its properties. `ccso:Aggregation` keeps its name. See the data review, section 13.

**A3, applied afterwards.** `relatedWithPhenomenon` is removed: it had no domain, range or use in
the module. The phenomenon relations it generalised in an earlier version are in
`doc/modules/PhenomenaAndHazards.owl`, which defines its own `relatedWithPhenomenon`.

**A4, applied afterwards.** `Downscaling ⊑ isDownscalingOf some ProjectionProduction` (instead of
`some ClimateSimulation`), so a downscaling can start from any climate projection production, not
only a simulation. For the change to take effect, the range of `isDownscalingOf` and the domain of
`hasDownscaling` are also widened from `ClimateSimulation` to `ProjectionProduction`; otherwise they
would still infer every source to be a simulation. The comments of `Downscaling`, `isDownscalingOf`
and `hasDownscaling` are updated accordingly. Checks: no change in consistency, unsatisfiable
classes, OWL 2 DL violations or inferences on the probe data.
