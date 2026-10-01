# Top-level ontology: consistency review against DUL

**Subject:** `ontologies/top-level/top-level.owl` (namespace `https://w3id.org/hacid/onto/top-level/`, prefix `top:`)
**Reference:** DOLCE+DnS Ultralite, `ontologies/ccso/doc/external-ontologies/DUL.owl` (prefix `dul:`)
**Companion files:**
- [`../alignment/top-level-dul-alignment.ttl`](../alignment/top-level-dul-alignment.ttl): `owl:equivalentClass` / `owl:equivalentProperty` axioms from every replicated term to its DUL original, with the divergences recorded as axiom annotations.
- [`novel-terms.md`](novel-terms.md): the 91 top-level terms that have no DUL counterpart.

## 1. Scope and method

The top-level ontology is a project-scoped replica of part of DUL, re-minted in the HACID
namespace and extended with project-specific terms. This review checks that:

1. every term taken from DUL keeps **analogous annotations** (labels, comments);
2. every such term keeps **coherent relationships** (hierarchy, domain/range, inverses,
   property characteristics, restrictions, disjointness); and
3. the top-level ontology is **logically consistent** on its own, and remains so when
   combined with DUL through the alignment.

How it was done:

- **Term matching.** Terms were matched by local name (79 exact matches). Four more replicas
  were identified by label, definition and position: `Location`↔`Place`,
  `isProperPartOf`↔`isPropertPartOf`, `parametrises`↔`parametrizes`,
  `isParametrisedBy`↔`isParametrizedBy`. No other top-level term matches a DUL term by name
  or case-insensitive name.
- **Structural comparison.** For each pair, rdflib compared the labels (per language),
  comments, `rdfs:subClassOf` (named classes and restrictions), `owl:disjointWith`,
  `owl:equivalentClass`, `rdfs:domain`/`rdfs:range`, `rdfs:subPropertyOf`, `owl:inverseOf`
  (declared on either side) and property characteristics. DUL IRIs were translated to their
  top-level replicas before comparing.
- **Reasoning.** ROBOT 1.9.7 with HermiT. It ran on the top-level ontology alone, on small test
  ABoxes, and on top-level + DUL + the alignment file. The alignment declares each replica
  equivalent to its DUL term (`owl:equivalentClass` / `owl:equivalentProperty`), so all DUL
  axioms also apply to the top-level terms. The check therefore shows whether the top-level
  can be *semantically* identified with DUL. ROBOT
  `validate-profile --profile DL` was used for OWL 2 DL compliance.

## 2. Overview

> Sections 2–4 and the appendix describe the ontology **as reviewed**, before the changes
> listed in section 5. Section 5 gives the current state.

| | Count |
|---|---:|
| Terms in top-level (classes / object props / datatype props) | 174 (47 / 113 / 14) |
| Replicas of DUL terms | **83** (28 / 54 / 1) |
| of which identical to DUL in all compared axioms (annotations aside) | 50 |
| of which with at least one axiom-level divergence | 33 |
| Novel terms (see `novel-terms.md`) | 91 |
| DUL terms not replicated | 112 |

DUL terms that are not replicated but are referenced in the comments of replicated terms,
or that sit between replicated terms in the DUL hierarchy:
`Abstract`, `SocialAgent`, `Plan`, `EventType`, `InformationObject`, `InformationRealization`,
`PhysicalAttribute`, `SpaceRegion`, `LocalConcept`, `hasDataValue`, `isEventIncludedIn`,
`isObjectIncludedIn`, `isExpressedBy`, `overlaps`, `realizes`.

### Reasoning results

| Check | Result |
|---|---|
| top-level alone, OWL 2 DL profile | ❌ **Not OWL 2 DL**: reserved vocabulary (`rdfs:domain` used as an object property, `rdfs:Property` and `rdfs:Class` used as classes). See A2. |
| top-level alone, HermiT, datatype-strict mode (Protégé default) | ❌ **Refuses to load**: `xsd:gYear` (also `xsd:date`, `xsd:time`) is not in the OWL 2 datatype map. See A3. |
| top-level alone, HermiT, ignoring unsupported datatypes | ✅ Consistent, no unsatisfiable classes. |
| top-level + ABox `Year` with `year "…"^^xsd:string` | ❌ Inconsistent. This confirms that `TemporalEntity ⊑ time only xsd:dateTime` constrains every sub-property of `time`. See A3. |
| alignment file alone, OWL 2 DL profile | ✅ In profile. |
| top-level + DUL + alignment | ❌ **Rejected by HermiT / not OWL 2 DL**: "Non-simple property `top:isProperPartOf` or its inverse appears in asymmetric object property axiom". See A1. |
| same, with the two top-level `owl:AsymmetricProperty` axioms removed | ✅ Consistent, no unsatisfiable classes. |

**Reading.** Apart from the proper-parthood characteristics, the axioms of the top-level are
**compatible with DUL**. Adding all DUL axioms to the replicated terms introduces no
contradiction or unsatisfiable class. Most divergences are **weakenings** (DUL axioms that were
not copied) or **flattenings** (intermediate DUL classes skipped). A few are real changes of
meaning, listed in section B.

## 3. Findings

Severity: **A** = logical/technical problem (reasoning breaks, profile violation or latent
inconsistency). **B** = semantic divergence from DUL that changes the meaning of a
replicated term. **C** = weakening (DUL axioms not replicated). **D** = annotation divergence.

### A. Logical and technical problems

**A1. Proper parthood: `hasProperPart` / `isProperPartOf` are asymmetric in top-level but transitive in DUL.**
DUL declares `hasProperPart` and `isPropertPartOf` (sic) as `owl:TransitiveProperty`. Its
documentation calls them asymmetric, but DUL cannot assert that: asymmetry on a transitive
(non-simple) property is outside OWL 2 DL. The top-level declares them `owl:AsymmetricProperty`
and **not** transitive. It also re-describes them in the comments as the relation between
objects and their *direct* components, which is what DUL's `hasComponent` is for. As a result:
- the top-level `hasProperPart` means something different from DUL's (non-transitive, "direct");
- top-level, DUL and the equivalence alignment together are outside OWL 2 DL, and HermiT
  rejects them (checked);
- `hasComponent`/`isComponentOf` (asymmetric, "without transitivity" by their comments) are now
  nearly indistinguishable from their super-properties.

*Recommendation:* realign with DUL. Make `hasProperPart`/`isProperPartOf` transitive, drop
`owl:AsymmetricProperty`, and restore the DUL comment ("Asymmetric (so including irreflexive)
parthood"). Keep `hasComponent` for direct, design-based parthood. If non-transitive direct
parthood is really wanted, introduce a new property rather than redefining the replica.

**A2. OWL 2 DL violations (meta-modelling with RDF/RDFS vocabulary).**
- `WorkflowRole ⊑ rdfs:Property` and `WorkflowRole ⊑ rdfs:domain only WorkflowExecution`.
  This declares `rdfs:domain` as an `owl:ObjectProperty`.
- `hasExpectedType` has range `rdfs:Class`, and `isExpectedTypeOf` has domain `rdfs:Class`.

The ontology is therefore OWL 2 Full. DL reasoners ignore or reject these axioms (ROBOT reports
them as dangling references). These are novel terms, so the problem is not about DUL
consistency, but it affects every module that imports the top-level.
*Recommendation:* model workflow-role properties with OWL 2 punning (declare the concrete
role IRIs both as `top:WorkflowRole` individuals and as object properties, and give each
property its own `rdfs:domain`), or with an annotation property. For expected types, use
`owl:Class` IRIs as punned individuals with an unconstrained range, or an annotation property.

**A3. Temporal datatypes: latent inconsistency and unsupported datatypes.**
- `TemporalEntity ⊑ time some xsd:dateTime` and `TemporalEntity ⊑ time only xsd:dateTime`.
- The sub-properties of `time` have other ranges: `year` → `xsd:gYear`, and
  `startTime`/`endTime` → `xsd:date ∪ xsd:dateTime ∪ xsd:time`.
- The value spaces of `xsd:gYear`, `xsd:date` and `xsd:time` are disjoint from that of
  `xsd:dateTime`. So any `Year` that has a `year` value, or any `TimeInterval` with a
  `startTime`/`endTime` of type `xsd:date` or `xsd:time`, is **inconsistent** under a reasoner
  that supports those datatypes. The `time some xsd:dateTime` restriction also forces every
  year or interval to carry an `xsd:dateTime` value.
- `xsd:date`, `xsd:time` and `xsd:gYear` are not part of the OWL 2 datatype map. HermiT in
  strict mode (the Protégé default) refuses to load the ontology. ROBOT's lenient mode treats
  them as opaque, which is why the clash is not detected there. With a non-`dateTime` literal
  the inconsistency shows up (see the table above).

*Recommendation:* remove the `time only/some xsd:dateTime` restrictions from `TemporalEntity`,
or move them to a subclass that really requires timestamps. Consider `xsd:dateTimeStamp`
(which is in the OWL 2 datatype map) for timestamps. Keep `gYear`/`date` for data-level use
only if all downstream tools accept non-OWL-2 datatypes. None of this comes from DUL:
`TemporalEntity`, `time`, `year`, `startTime`, `endTime` and `Year` are all novel.

### B. Semantic divergences in replicated terms

**B1. `TimeInterval` is not a `Region`.** In DUL, `TimeInterval ⊑ Region`. In the top-level,
`TimeInterval ⊑ TemporalEntity ⊑ Entity`. But the replicated `hasTimeInterval` is still
`⊑ hasRegion`, whose range is `Region`, so every time interval *used* with `hasTimeInterval`
is inferred to be a `Region` anyway. The asserted hierarchy and the property hierarchy
disagree. The `owl:disjointWith Amount` axiom that was kept only makes sense if
`TimeInterval` is a Region. *Recommendation:* assert `TimeInterval ⊑ Region` (it can also stay
under `TemporalEntity`).

**B2. `associatedWith` is neither symmetric nor transitive, but its comment says it is.**
DUL declares `associatedWith` `owl:SymmetricProperty` + `owl:TransitiveProperty`, with
domain/range `Entity`. The top-level copies the comment ("It is declared as both transitive and
symmetric…") but none of those axioms. *Recommendation:* restore the characteristics
(and domain/range `Entity`), or change the comment. Restoring them has consequences, because
`associatedWith` is the root of all object properties in `data.owl` and `ccso.owl`.
Transitivity combined with symmetry makes every pair of connected individuals associated.
That is DUL's intended "maximal closure", but it can be expensive for large knowledge graphs.
If performance is the reason for dropping the characteristics, say so in the comment.

**B3. `isRelatedToConcept` is not symmetric** (DUL: symmetric, and its own inverse).
*Recommendation:* restore `owl:SymmetricProperty`.

**B4. `includesEvent` / `includesObject` are detached from `isSettingFor`.** In DUL they are
sub-properties of `isSettingFor`, with domain `Situation`, ranges `Event`/`Object`, and
inverses `isEventIncludedIn`/`isObjectIncludedIn`. In the top-level they hang directly under
`associatedWith`, with no domain, range or inverse. So an `includesObject` assertion no longer
implies that the subject is a `Situation` or that it is the setting for the object.
*Recommendation:* restore `rdfs:subPropertyOf top:isSettingFor` and the domain/range.

**B5. `hasLocation` / `isLocationOf` are narrowed to `Location` (= `dul:Place`).** DUL's
`hasLocation` is a generic, *relative* location between any two entities ("the cat is on the
mat", "the wound is close to the femoral artery"). The top-level restricts the range to
`top:Location`, a `SocialObject`, and relabels it "has place" / "ha luogo". Every object of
`hasLocation` then becomes a social object, so "the cat is on the mat" would make the mat a
`SocialObject`. This is incompatible with DUL usage. *Recommendation:* keep DUL's `Entity`
range and labels. If the "place" reading is needed, add a sub-property (e.g. `hasPlace`) with
range `Location`.

**B6. Domain/range widenings:**
- `hasRole` domain and `isRoleOf` range are `Entity` in the top-level, `Object` in DUL.
- `parametrises` range and `isParametrisedBy` domain are `Entity` in the top-level, `Region` in DUL.

These are compatible when the ontologies are merged. Under the equivalence alignment the DUL
restrictions apply again, so any entity with a role is inferred to be an `Object`.
They are acceptable as deliberate generalisations, but they should be documented in the
comments. They currently are not.

**B7. Hierarchy flattening** (compatible with DUL, but it loses intermediate distinctions):

| top-level | DUL |
|---|---|
| `Organization ⊑ Agent` | `Organization ⊑ SocialAgent ⊑ Agent` |
| `Task ⊑ Concept` | `Task ⊑ EventType ⊑ Concept` |
| `Workflow ⊑ Description` | `Workflow ⊑ Plan ⊑ Description` |
| `FormalEntity ⊑ Entity`, `Region ⊑ FormalEntity` | `FormalEntity ⊑ Abstract`, `Region ⊑ Abstract` (siblings) |

The last row is a real restructuring: `Region` is placed *under* `FormalEntity`. This is
consistent with DUL (DUL has no disjointness between the two), but it goes beyond DUL. The
`Region` comment still refers to `SpaceRegion` and `PhysicalAttribute`, which are not
replicated.

**B8. Additions to replicated classes:**
- `Parameter ⊑ Characteristic` (novel class).
- `Collection ⊑ hasMember some Entity` (DUL allows empty collections).
- `Organization` disjoint with `Person`.
- `TimeInterval` gets `startTime`/`endTime` max-1 restrictions.
- `Event ⊑ hasPart some Event`. This is vacuous, because `hasPart` is reflexive, so every event
  is part of itself. It is probably meant to be DUL's `hasPart only Event`.

**B9. `Situation` has been given the definition of `d0:Eventuality`.** The top-level comment on
`Situation` reads "Any event, situation, activity, event type, etc. … This is the same concept
as defined in d0.owl", which is the d0 definition of *Eventuality*. DUL defines `Situation` as
"a view, consistent with ('satisfying') a Description, on a set of entities" (D&S reification
and n-ary relations). The axioms are still DUL's (`satisfies some Description`). The
comments of `satisfies` ("an eventuality satisfies a description") and of the novel
`hasEventuality` follow the same reading. This is the biggest *conceptual* change in the
replica. It should be either reverted to the DUL definition or stated explicitly as a
design decision.

### C. Weakenings (DUL axioms not replicated)

These do not cause inconsistency. They mean the top-level infers less and catches fewer
modelling errors than DUL. The most significant ones:

| Term | DUL axioms missing from the top-level |
|---|---|
| `Event` | `hasParticipant some Object`, `hasTimeInterval some TimeInterval`, `hasPart only Event`, `hasConstituent only Event`; **disjoint with `Object`, `Quality`** |
| `Object` | `isParticipantIn some Event`, `hasLocation some Entity`, `hasPart only Object`, `hasConstituent only Object`, `isClassifiedBy only Role`; **disjoint with `Quality`** |
| `Action` | `hasParticipant some Agent`, `executesTask min 1` |
| `PhysicalObject` | `hasPart only PhysicalObject`; **disjoint with `SocialObject`** |
| `Concept` | `isDefinedIn some Description`, `hasPart only Concept`; **disjoint with `Situation`** (and with non-replicated `InformationObject`, `SocialAgent`) |
| `Description` | disjoint with non-replicated `InformationObject`, `SocialAgent` (disjointness with `Situation` *is* kept) |
| `Role` | `classifies only Object`, `hasPart only Role` |
| `Parameter` | `classifies only Region`, `hasPart only Parameter`; disjoint with `Role` |
| `Task` | `isExecutedIn only Action`, `isTaskDefinedIn only Description`, `isTaskOf only Role`, `hasPart only Task` |
| `Region` | `hasPart/hasConstituent/precedes only Region`, `overlaps only Region` |
| `SocialObject` | `isExpressedBy some InformationObject`, `hasPart only SocialObject` |
| `UnitOfMeasure` | `parametrizes some Region` |
| `Workflow` | `definesRole some Role`, `definesTask some Task` |
| `Location` (`Place`) | `isLocationOf min 1` |
| `Amount` | disjoint with non-replicated `PhysicalAttribute`, `SpaceRegion` |
| `hasRegionDataValue` | sub-property of `hasDataValue` (not replicated) |
| `isDescribedBy` | explicit domain `Entity`, range `Description` (still inferable from `describes`) |

*Recommendation:* restore at least the **top-level disjointness axioms** (`Event ⊥ Object`,
`Event ⊥ Quality`, `Object ⊥ Quality`, `PhysicalObject ⊥ SocialObject`, `Concept ⊥ Situation`,
`Parameter ⊥ Role`). They are cheap for reasoners and catch the most common category errors,
especially since the downstream modules (`data`, `ccso`, `core`) are validated with OWLUnit.
Existential restrictions such as `Event ⊑ hasTimeInterval some TimeInterval` are a matter of
choice: they do not burden a lightweight replica, but they do generate anonymous individuals.

### D. Annotation divergences

**D1. Labels.** Labels match DUL for most replicas. The divergences are:

| Term | top-level | DUL | Note |
|---|---|---|---|
| `Organization` | "Organisation"@en | "Organization"@en | British spelling in label, US spelling in IRI |
| `hasLocation` | "has place"@en, "ha luogo"@it | "has location"@en, "ha localizzazione"@it | see B5 |
| `isLocationOf` | "è luogo di"@it | "è una localizzazione di"@it | see B5 |
| `hasRole` | "ha il ruolo"@it | "ha ruolo"@it | minor |
| `isRoleOf` | "è ruolo di"@it | "è un ruolo di"@it | minor |
| `isSatisfiedBy` | "è soddisfatto da"@it | "è soddisfatta da"@it | the subject is a *descrizione* (feminine), so DUL's form is correct |
| `describes` | "describe"@it | "descrive"@it | **typo** in top-level |
| `Workflow` | "Flusso di lavoro"@it | "Workflow"@it | translation, fine |
| `associatedWith` | "associated with"@en, "associato a"@it | "associatedWith" (no language tag) | improvement |
| `Person` | "Persona"@it | "Persona {it}" (malformed in DUL) | improvement |
| `InformationEntity` | "Information entity"@en, "Entità informativa"@it | none | improvement |
| `hasProperPart`, `isProperPartOf` | en + it | en only; DUL IRI and label have the typo "propert" | improvement |
| `parametrises`, `isParametrisedBy` | "parametrises", "is parametrised by" | "parametrizes", "is parametrized by" | spelling follows renamed IRI |
| `hasRegionDataValue` | "has region data value"@en only | + "regione ha valore"@it | Italian label missing |

**D2. Comments.** Of the 83 replicas:
- **Identical** (apart from the added `@en` tag): 46.
- **Abridged** (the first paragraph of DUL's comment is kept and the rest dropped): `Event`,
  `FormalEntity`, `Region`, `follows`, `precedes`. The dropped parts carry important modelling
  guidance: the event/situation discussion, formal vs social semantics, and the note on
  `hasDataValue`.
- **Replaced by a different, usually shorter, text**: `Collection`, `Concept`, `Description`,
  `Organization`, `Parameter`, `Person`, `Role`, `Situation` (see B9), `TimeInterval`,
  `UnitOfMeasure`, `Workflow`, `classifies`, `describes`, `isDescribedBy`, `hasLocation`,
  `isLocationOf`, `hasMember`, `isMemberOf`, `hasPart`, `isPartOf`, `hasRole`, `isRoleOf`,
  `isClassifiedBy`, `satisfies`, `hasProperPart`, `isProperPartOf`, `parametrises`,
  `isParametrisedBy`, `Location`. Several of these lose the defining statement:
  - `Role`: DUL says "A Concept that classifies an Object"; top-level says "The class for representing roles".
  - `Parameter`: DUL gives the Region/Parameter distinction; top-level says "The class of parameters".
  - `Organization`: DUL says "An internally structured, conventionally created SocialAgent…"; top-level says "An organisation".
  - `Workflow`: DUL says "A Plan that defines Role(s), Task(s)…"; top-level says "A workflow with tasks".
  - `TimeInterval`: DUL says "Any Region in a dimensional space that aims at representing time"; top-level says "…having a start and end time".
  - `hasPart`: top-level drops DUL's explanation of the reflexivity/asymmetry design, which is exactly what A1 is about.
- **Spelling only**: `InformationEntity` ("realised" instead of "realized").
- **Improved over DUL**: `directlyFollows` (DUL's example, "Wednesday directly precedes
  Thursday", is wrong for *follows*; top-level has "Tuesday directly follows Monday"), and
  `WorkflowExecution` (DUL has no comment).
- **Italian comments** were added to many replicas, which is an improvement. Where the English
  text was replaced, the Italian text follows the replacement, not DUL.

*Recommendation:* for replicas, keep DUL's `rdfs:comment` verbatim (tagged `@en`). Put
HACID-specific explanations in a separate annotation, such as `skos:scopeNote` or a second
`rdfs:comment`. That way the replica stays traceable and the local notes stay visible.

**D3. Provenance.** The ontology header has no annotations: no label, comment, version,
licence, or reference to DUL. The replicas use `rdfs:isDefinedBy <https://w3id.org/hacid/onto/top-level>`,
which hides their origin. *Recommendation:* add ontology metadata (`dcterms:title`,
`owl:versionInfo`/`owl:versionIRI`, `dcterms:license`, `prov:wasDerivedFrom <http://www.ontologydesignpatterns.org/ont/dul/DUL.owl>`)
and point to the alignment file. Optionally, add `rdfs:seeAlso dul:X` on each replica.

## 4. Prioritised recommendations

1. **Fix proper parthood** (A1): transitive, not asymmetric, DUL comment.
2. **Make the ontology OWL 2 DL** (A2): remodel `WorkflowRole`, `hasExpectedType` and `isExpectedTypeOf`.
3. **Fix the temporal datatypes** (A3): drop or relax `TemporalEntity ⊑ time some/only xsd:dateTime`, and review the use of `xsd:gYear`, `xsd:date` and `xsd:time`.
4. **Restore DUL relations that change meaning** (B1–B5): `TimeInterval ⊑ Region`; the characteristics of `associatedWith` (or fix its comment); `isRelatedToConcept` symmetric; `includesEvent`/`includesObject` under `isSettingFor`; the range of `hasLocation`.
5. **Revert or explicitly document the `Situation` redefinition** (B9).
6. **Restore the core disjointness axioms** (C).
7. **Align annotations** (D1–D3): fix "describe"@it, restore DUL comments for replicas, add ontology metadata.
8. **Resolve the duplicates among novel terms** (see `novel-terms.md`): `hasDescription`/`isDescribedBy`, `specialises`/`specializes`, `involves`/`hasEventuality`/`isSettingFor`, `isIssuedBy`/`hasCreator`, `hasCollection`/`isMemberOf`, and the `isSouceOf` typo.

Before changing any replicated term, check the modules that use it (`data`, `ccso`, `core`,
`medical-dx`). `associatedWith`, `hasPart`, `hasRegion`, `Concept`, `classifies` and `Situation`
are used extensively.

## 5. Implementation of the recommendations

### 5.1 Compatibility checks

Each recommendation of section 4 (B2 in a second round, see 5.2) was applied to a copy of the top-level ontology, **alone and all together**,
and checked against the local modules that depend on it:

- `data/data.owl`, `ccso/ccso.owl`, `medical-dx/mdx.owl`, and `core/agentrole.owl`,
  `core/evidence.owl`, `core/judgement.owl`, `core/naming.owl`. The medical-dx `pattern/`,
  `full/` and `alignment/` files use their own namespace and do not import the top-level.
- The test data of their OWLUnit tests: 23 top-level, 14 core and 1 medical-dx dataset.
  The four ccso usage examples (`ccso/doc/usage-examples/*.ttl`) could not be used, because
  they are not valid Turtle.

The checks were:

1. **Reasoning.** HermiT (ignoring unsupported datatypes) on the union of all the modules, and
   on that union plus each test dataset (39 runs per variant). Each run records whether the
   result is consistent and which classes are unsatisfiable.
2. **Profile.** The OWL 2 DL profile of the union (ROBOT `validate-profile`).
3. **Usage.** Every changed term was searched for in the modules, the test data and the SPARQL
   queries of the OWLUnit tests. This catches changes that are logically harmless but could
   change query results or break references.

**Result:** no recommendation, alone or combined, changes the outcome of any of the 39 runs.
No new inconsistency, no new unsatisfiable class, no new OWL 2 DL violation. The combined
change removes 21 OWL 2 DL violations from the union. No OWLUnit query uses a term whose
inferences change: only `top7` and `top8` query parthood, and they use `hasPart`/`isPartOf`
directly. All recommendations were therefore applied.

After the changes:
- The top-level ontology alone is **in OWL 2 DL** and is consistent and coherent.
- Top-level + DUL + the equivalence alignment is **in OWL 2 DL, consistent and coherent**.

### 5.2 Changes applied

| Rec. | Change in `top-level.owl` | Compatibility notes |
|---|---|---|
| **A1** | `hasProperPart` / `isProperPartOf`: `owl:AsymmetricProperty` replaced by `owl:TransitiveProperty`. DUL comment restored. Asymmetry is stated in the comment as a constraint that OWL 2 DL cannot express for a transitive property. The former "direct components" comments were removed; direct parthood is `hasComponent`. | Not used by any dependent module. The `hasComponent`/`isComponentOf` tests (`top9`, `top10`) are unaffected. |
| **A2** | Removed `WorkflowRole ⊑ rdfs:Property`, `WorkflowRole ⊑ rdfs:domain only WorkflowExecution`, the `rdfs:Class` range of `hasExpectedType` and domain of `isExpectedTypeOf`, and the declarations of `rdfs:domain`, `rdfs:Class`, `rdfs:Property`. The constraints that cannot be expressed in OWL 2 DL are now stated in the `rdfs:comment` of `WorkflowRole`, `hasExpectedType` and `isExpectedTypeOf`. | Terms not used by any dependent module. |
| **A3** | Removed `TemporalEntity ⊑ time some xsd:dateTime` and `⊑ time only xsd:dateTime`. The comment of `TemporalEntity` now says that the datatype follows the granularity (e.g. `xsd:dateTime`, `xsd:date`, `xsd:gYearMonth`, `xsd:gYear`). | **Fixes a latent inconsistency in the core tests.** `ar1`–`ar3` test data assert `top:time "2024-01"^^xsd:gYearMonth` on a `TemporalEntity`, which contradicts `time only xsd:dateTime`. Replacing the literal with a non-`dateTime` value that HermiT supports gives *inconsistent* before the change and *consistent* after. **Second round:** `time` now has range `xsd:dateTime` (instead of `rdfs:Literal`). Its sub-property `year` (range `xsd:gYear`) was removed, together with the restriction `Year ⊑ year max 1 xsd:gYear`. `startTime`/`endTime` and the `TimeInterval` restrictions on them now use `xsd:dateTime` instead of `xsd:date ∪ xsd:dateTime ∪ xsd:time`; under the new range of `time` they could only take `xsd:dateTime` values anyway. The top-level now uses only OWL 2 datatypes and **HermiT in strict mode accepts it**; before, it refused to load it. Same checks as above, with no result changes. After the core `ar1`–`ar3` test data were updated (see 5.3), all 39 runs load in strict mode (before: none), with only the pre-existing issues of 5.3. |
| B1 | `TimeInterval ⊑ Region` added (it stays under `TemporalEntity` too). | `TimeInterval` not used by any dependent module. |
| B2 | `associatedWith` now has DUL's axioms: `owl:SymmetricProperty`, `owl:TransitiveProperty`, domain and range `Entity`, inverse of itself. Its comment, which already described these characteristics, is unchanged. | Applied in a second round, after the same checks. **No change** in any of the 39 runs or in the DL profile. The dependent modules use `associatedWith` only as a super-property (plus one plain declaration in `data.owl`), so the restrictions that OWL 2 DL places on transitive properties are not violated. **Performance:** HermiT time per run rose from about 0.5–1 s to about 3 s on the test data, so the whole suite took 101 s instead of 50 s. With a forward-chaining (materialising) triple store, every connected group of n individuals yields n² `associatedWith` triples. On the test data the closure is 6.5 times the asserted links, and in a large, connected knowledge graph it grows quadratically. The repository's Fuseki configuration (`ontologies/integrate/fuseki-conf.ttl`) is a plain TDB2 dataset without a reasoner, so it is not affected. Any deployment that enables OWL RL or OWL materialisation should exclude this property or use backward chaining. |
| B3 | `isRelatedToConcept` declared `owl:SymmetricProperty`. | Sub-properties `hasTask`/`isTaskOf` only; no dependent module uses them. |
| B4 | `includesEvent` / `includesObject`: now `⊑ isSettingFor`, domain `Situation`, range `Event` / `Object`. The DUL inverses `isEventIncludedIn` / `isObjectIncludedIn` were not added. | Not used by any dependent module. |
| B5 | `hasLocation` range and `isLocationOf` domain restored to `Entity`. Labels ("has location" / "ha localizzazione", "è una localizzazione di") and comments (DUL, plus Italian translation) restored. | `mdx.owl` uses `HeatlhcareProfessional ⊑ hasLocation some Location`, which names `Location` explicitly, so nothing is lost. |
| B9 | `Situation`: `rdfs:comment` is now DUL's definition. The HACID reading as a catch-all for d0 eventualities is documented in a `skos:scopeNote` (en, it). | Annotation only. |
| C | Disjointness added: `Event ⊥ Object`, `Event ⊥ Quality`, `Object ⊥ Quality`, `PhysicalObject ⊥ SocialObject`, `Concept ⊥ Situation`, `Parameter ⊥ Role`. | No new unsatisfiable class or inconsistency in any module or test dataset. |
| D1 | Labels: "descrive"@it (`describes`), "è soddisfatta da"@it (`isSatisfiedBy`), "regione ha valore"@it (`hasRegionDataValue`), "Organization"@en, "ha ruolo"@it (`hasRole`), "è un ruolo di"@it (`isRoleOf`). | Annotation only. |
| D2 | For the 24 remaining replicas whose comment had been replaced, `rdfs:comment` is now DUL's text. The former HACID comments (en and it) are kept as `skos:scopeNote`. Deliberate divergences get an extra scope note: widened domain/range of `hasRole`, `isRoleOf`, `parametrises`, `isParametrisedBy`; flattened hierarchy of `Organization`, `Workflow`; `Parameter ⊑ Characteristic`; `TimeInterval ⊑ TemporalEntity`; `Location` = `dul:Place`. The 5 abridged comments (`Event`, `FormalEntity`, `Region`, `follows`, `precedes`) now carry DUL's full text. | Annotation only. `skos:scopeNote` is declared as an annotation property. |
| D3 | Ontology header: `rdfs:label`, `rdfs:comment` (pointing to the alignment file), `dcterms:license` CC BY 4.0 (the repository licence), `prov:wasDerivedFrom` DUL. | Annotation only. No version IRI was added. |
| 8 | `hasDescription`/`isDescriptionOf` ≡ `isDescribedBy`/`describes`. `specializes`/`isSpecializedBy` ⊑ `specialises`/`isSpecialisedBy`. `involves`, `isEventualityOf` ⊑ `isSettingFor`. `isInvolvedIn`, `hasEventuality` ⊑ `hasSetting`. `isMemberOf` ⊑ `hasCollection`, `hasMember` ⊑ `isCollectionOf`. `isIssuedBy`/`issues` get their own labels and comments ("is issued by" / "issues"). `isSouceOf` renamed `isSourceOf`, with `isSouceOf` kept as a deprecated equivalent alias. | No IRI was removed, because `involves`, `isInvolvedIn`, `hasEventuality` and `hasDescription` are used by core, medical-dx and ccso documentation. |

The alignment file was regenerated: its divergence annotations now describe the current state.

### 5.3 Pre-existing issues found in the dependent modules

These were present before any change. The changes neither cause nor fix them, except the last one, which was fixed. They are reported here because they surfaced during the checks.

- **`mdx:HeatlhcareProfessionalRole` is unsatisfiable.** It is `⊑ mdx:worksFor some top:Organization`
  and `⊑ ar:involvesAgent only mdx:HeatlhcareProfessional` (a `Person`). `mdx:worksFor` is a
  sub-property of `ar:involvesAgent`, so the organisation must also be a `Person`, while top-level
  declares `Organization ⊥ Person`. Either `worksFor` should not specialise `involvesAgent`, or
  the restriction should be qualified differently.
- **`medical-dx/test/mdx4-test-data.ttl` is inconsistent.** The mdx property chain
  `isInScopeOfDiagnosis ∘ hasDiagnosis⁻ ∘ forClinicalCase ⊑ top:satisfies` makes
  `test-data:description`, a `Description` (it `describes` something), the subject of
  `satisfies`, hence a `Situation`, while `Description ⊥ Situation`. With the chain removed, the
  dataset is consistent both before and after the changes.
- **`data.owl`** declares `hasStartDateTime`/`hasEndDateTime` both as object and datatype
  properties, with object range `xsd:dateTime`. This is outside OWL 2 DL, and in a merge it turns
  `xsd:dateTime` into a class.
- **`core/evidence.owl`** uses `rdf:Property` as a class (outside OWL 2 DL).
  **`core/agentrole.owl`** uses `ar:hasEventuality` without declaring it.
- The four **ccso usage examples** are not valid Turtle.
- The **core `ar1`–`ar3` test data** asserted `top:time "2024-01"^^xsd:gYearMonth`, and the `ar3`
  query matched that literal. This contradicted `TemporalEntity ⊑ time only xsd:dateTime` and the
  later range `xsd:dateTime` of `time`, and `xsd:gYearMonth` is outside the OWL 2 datatype map.
  **Fixed:** the role assignments are now situated in ten-year `TimeInterval`s, with
  `startTime`/`endTime` as `xsd:dateTime`. John is a cardiologist from 2015 to 2024, and a second
  agent, Mary, from 1990 to 1999. The `ar3` query now asks for an instant (2020-06-15) and uses a
  `FILTER` to keep only the agents whose interval contains it, so it returns John and not Mary.
  The expected result of `ar2` was updated to the new interval IRI.

### 5.4 Still open

- Items not in the prioritised list: B6 (document or revert the widenings; they are now
  documented in scope notes), B7/B8 (flattening and additions, including the vacuous
  `Event ⊑ hasPart some Event`), the non-replicated DUL restrictions of section C, and the
  Italian comments of replicas that never had one.

## 6. Reproducing the checks

With [ROBOT](https://robot.obolibrary.org/), from the repository root:

```bash
T=ontologies/top-level/top-level.owl
D=ontologies/ccso/doc/external-ontologies/DUL.owl
A=ontologies/top-level/alignment/top-level-dul-alignment.ttl

robot validate-profile --input $T --profile DL --output top-dl.txt
robot reason --reasoner hermit --input $T --output /tmp/out.owl
robot validate-profile --input $A --profile DL --output alignment-dl.txt
robot merge --input $T --input $D --input $A \
      reason --reasoner hermit --output /tmp/out.owl
```

## Appendix: per-term comparison of the replicas (as reviewed, before section 5)

"=" means no difference in the compared axioms. Annotation differences are covered in D1/D2.
Names of DUL terms that are not replicated in the top-level are prefixed with `dul:`.

| top-level | DUL | Type | Axiom differences (top-level only / DUL only) | Label | Comment |
|---|---|---|---|---|---|
| `Action` | `dul:Action` | C | superclasses/restrictions: −`executesTask min 1`, `hasParticipant some Agent` | = | = |
| `Agent` | `dul:Agent` | C | = | = | = |
| `Amount` | `dul:Amount` | C | disjoint with: −`dul:PhysicalAttribute`, `dul:SpaceRegion` | = | = |
| `Collection` | `dul:Collection` | C | superclasses/restrictions: +`hasMember some Entity` | = | replaced |
| `Concept` | `dul:Concept` | C | superclasses/restrictions: −`hasPart only Concept`, `isDefinedIn some Description`<br>disjoint with: −`dul:InformationObject`, `dul:SocialAgent`, `Situation` | = | replaced |
| `Description` | `dul:Description` | C | disjoint with: −`dul:InformationObject`, `dul:SocialAgent` | = | replaced |
| `Entity` | `dul:Entity` | C | = | = | = |
| `Event` | `dul:Event` | C | superclasses/restrictions: +`hasPart some Event` / −`hasConstituent only Event`, `hasPart only Event`, `hasParticipant some Object`, `hasTimeInterval some TimeInterval`<br>disjoint with: −`Object`, `Quality` | = | abridged |
| `FormalEntity` | `dul:FormalEntity` | C | superclasses/restrictions: +`Entity` / −`dul:Abstract` | = | abridged |
| `Goal` | `dul:Goal` | C | = | = | = |
| `InformationEntity` | `dul:InformationEntity` | C | = | differs | replaced |
| `Location` | `dul:Place` | C | superclasses/restrictions: −`isLocationOf min 1` | = | replaced |
| `Method` | `dul:Method` | C | = | = | = |
| `Object` | `dul:Object` | C | superclasses/restrictions: −`hasConstituent only Object`, `hasLocation some Entity`, `hasPart only Object`, `isClassifiedBy only Role`, `isParticipantIn some Event`<br>disjoint with: −`Quality` | = | = |
| `Organization` | `dul:Organization` | C | superclasses/restrictions: +`Agent` / −`dul:SocialAgent`<br>disjoint with: +`Person` | differs | replaced |
| `Parameter` | `dul:Parameter` | C | superclasses/restrictions: +`Characteristic` / −`classifies only Region`, `hasPart only Parameter`<br>disjoint with: −`Role` | = | replaced |
| `Person` | `dul:Person` | C | = | differs | replaced |
| `PhysicalObject` | `dul:PhysicalObject` | C | superclasses/restrictions: −`hasPart only PhysicalObject`<br>disjoint with: −`SocialObject` | = | = |
| `Quality` | `dul:Quality` | C | = | = | = |
| `Region` | `dul:Region` | C | superclasses/restrictions: +`FormalEntity` / −`dul:Abstract`, `dul:overlaps only Region`, `hasConstituent only Region`, `hasPart only Region`, `precedes only Region` | = | abridged |
| `Role` | `dul:Role` | C | superclasses/restrictions: −`classifies only Object`, `hasPart only Role` | = | replaced |
| `Situation` | `dul:Situation` | C | = | = | replaced |
| `SocialObject` | `dul:SocialObject` | C | superclasses/restrictions: −`dul:isExpressedBy some dul:InformationObject`, `hasPart only SocialObject` | = | = |
| `Task` | `dul:Task` | C | superclasses/restrictions: +`Concept` / −`dul:EventType`, `hasPart only Task`, `isExecutedIn only Action`, `isTaskDefinedIn only Description`, `isTaskOf only Role` | = | = |
| `TimeInterval` | `dul:TimeInterval` | C | superclasses/restrictions: +`TemporalEntity`, `endTime max 1 (xsd:date or xsd:dateTime or xsd:time)`, `startTime max 1 (xsd:date or xsd:dateTime or xsd:time)` / −`Region` | = | replaced |
| `UnitOfMeasure` | `dul:UnitOfMeasure` | C | superclasses/restrictions: −`parametrises some Region` | = | replaced |
| `Workflow` | `dul:Workflow` | C | superclasses/restrictions: +`Description` / −`dul:Plan`, `definesRole some Role`, `definesTask some Task` | differs | replaced |
| `WorkflowExecution` | `dul:WorkflowExecution` | C | = | = | added |
| `associatedWith` | `dul:associatedWith` | OP | domain: −`Entity`<br>range: −`Entity`<br>inverse: −`associatedWith`<br>characteristics: −`owl:SymmetricProperty`, `owl:TransitiveProperty` | differs | = |
| `classifies` | `dul:classifies` | OP | = | = | replaced |
| `defines` | `dul:defines` | OP | = | = | = |
| `definesRole` | `dul:definesRole` | OP | = | = | = |
| `definesTask` | `dul:definesTask` | OP | = | = | = |
| `describes` | `dul:describes` | OP | = | differs | replaced |
| `directlyFollows` | `dul:directlyFollows` | OP | = | = | replaced |
| `directlyPrecedes` | `dul:directlyPrecedes` | OP | = | = | = |
| `executesTask` | `dul:executesTask` | OP | = | = | = |
| `follows` | `dul:follows` | OP | = | = | abridged |
| `hasComponent` | `dul:hasComponent` | OP | = | = | = |
| `hasConstituent` | `dul:hasConstituent` | OP | = | = | = |
| `hasLocation` | `dul:hasLocation` | OP | range: +`Location` / −`Entity` | differs | replaced |
| `hasMember` | `dul:hasMember` | OP | = | = | replaced |
| `hasPart` | `dul:hasPart` | OP | = | = | replaced |
| `hasParticipant` | `dul:hasParticipant` | OP | = | = | = |
| `hasProperPart` | `dul:hasProperPart` | OP | domain: +`Entity`<br>range: +`Entity`<br>characteristics: +`owl:AsymmetricProperty` / −`owl:TransitiveProperty` | differs | replaced |
| `hasQuality` | `dul:hasQuality` | OP | = | = | = |
| `hasRegion` | `dul:hasRegion` | OP | = | = | = |
| `hasRegionDataValue` | `dul:hasRegionDataValue` | DP | super-properties: −`dul:hasDataValue` | differs | = |
| `hasRole` | `dul:hasRole` | OP | domain: +`Entity` / −`Object` | differs | replaced |
| `hasSetting` | `dul:hasSetting` | OP | = | = | = |
| `hasTask` | `dul:hasTask` | OP | = | = | = |
| `hasTimeInterval` | `dul:hasTimeInterval` | OP | = | = | = |
| `includesEvent` | `dul:includesEvent` | OP | domain: −`Situation`<br>range: −`Event`<br>super-properties: +`associatedWith` / −`isSettingFor`<br>inverse: −`dul:isEventIncludedIn` | = | = |
| `includesObject` | `dul:includesObject` | OP | domain: −`Situation`<br>range: −`Object`<br>super-properties: +`associatedWith` / −`isSettingFor`<br>inverse: −`dul:isObjectIncludedIn` | = | = |
| `isClassifiedBy` | `dul:isClassifiedBy` | OP | = | = | replaced |
| `isComponentOf` | `dul:isComponentOf` | OP | = | = | = |
| `isConceptUsedIn` | `dul:isConceptUsedIn` | OP | = | = | = |
| `isConstituentOf` | `dul:isConstituentOf` | OP | = | = | = |
| `isDefinedIn` | `dul:isDefinedIn` | OP | = | = | = |
| `isDescribedBy` | `dul:isDescribedBy` | OP | domain: −`Entity`<br>range: −`Description` | = | replaced |
| `isExecutedIn` | `dul:isExecutedIn` | OP | = | = | = |
| `isLocationOf` | `dul:isLocationOf` | OP | domain: +`Location` / −`Entity` | differs | replaced |
| `isMemberOf` | `dul:isMemberOf` | OP | = | = | replaced |
| `isParametrisedBy` | `dul:isParametrizedBy` | OP | domain: +`Entity` / −`Region` | differs | replaced |
| `isParticipantIn` | `dul:isParticipantIn` | OP | = | = | = |
| `isPartOf` | `dul:isPartOf` | OP | = | = | replaced |
| `isProperPartOf` | `dul:isPropertPartOf` | OP | domain: +`Entity`<br>range: +`Entity`<br>characteristics: +`owl:AsymmetricProperty` / −`owl:TransitiveProperty` | differs | replaced |
| `isQualityOf` | `dul:isQualityOf` | OP | = | = | = |
| `isRegionFor` | `dul:isRegionFor` | OP | = | = | = |
| `isRelatedToConcept` | `dul:isRelatedToConcept` | OP | inverse: −`isRelatedToConcept`<br>characteristics: −`owl:SymmetricProperty` | = | = |
| `isRoleDefinedIn` | `dul:isRoleDefinedIn` | OP | = | = | = |
| `isRoleOf` | `dul:isRoleOf` | OP | range: +`Entity` / −`Object` | differs | replaced |
| `isSatisfiedBy` | `dul:isSatisfiedBy` | OP | = | differs | = |
| `isSettingFor` | `dul:isSettingFor` | OP | = | = | = |
| `isSpecializedBy` | `dul:isSpecializedBy` | OP | = | = | = |
| `isTaskDefinedIn` | `dul:isTaskDefinedIn` | OP | = | = | = |
| `isTaskOf` | `dul:isTaskOf` | OP | = | = | = |
| `isTimeIntervalOf` | `dul:isTimeIntervalOf` | OP | = | = | = |
| `parametrises` | `dul:parametrizes` | OP | range: +`Entity` / −`Region` | differs | replaced |
| `precedes` | `dul:precedes` | OP | = | = | abridged |
| `satisfies` | `dul:satisfies` | OP | = | = | replaced |
| `specializes` | `dul:specializes` | OP | = | = | = |
| `usesConcept` | `dul:usesConcept` | OP | = | = | = |

"+" = present only in the top-level; "−" = present only in DUL. For comments: "=" identical, "replaced" different text, "abridged" DUL text truncated, "added" DUL has none.
