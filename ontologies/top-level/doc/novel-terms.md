# Top-level ontology: terms not derived from DUL

This document lists the terms of the HACID top-level ontology
(`ontologies/top-level/top-level.owl`, namespace `https://w3id.org/hacid/onto/top-level/`,
prefix `top:`) that have **no counterpart in DOLCE+DnS Ultralite (DUL)**
(`ontologies/ccso/doc/external-ontologies/DUL.owl`, prefix `dul:`).

The other 88 terms replicate a DUL term. They are declared equivalent to it (`owl:equivalentClass` / `owl:equivalentProperty`) in
[`../alignment/top-level-dul-alignment.ttl`](../alignment/top-level-dul-alignment.ttl), and
[`dul-consistency-review.md`](dul-consistency-review.md) reviews how closely they match DUL.
Four of those replicas have a local name that differs from DUL, so they are **not** listed here:

| top-level | DUL |
|---|---|
| `top:Location` | `dul:Place` |
| `top:isProperPartOf` | `dul:isPropertPartOf` (typo in DUL) |
| `top:parametrises` | `dul:parametrizes` |
| `top:isParametrisedBy` | `dul:isParametrizedBy` |

## Summary

| | Classes | Object properties | Datatype properties | Total |
|---|---:|---:|---:|---:|
| Terms in top-level | 48 | 111 | 15 | 174 |
| Replicas of DUL terms | 32 | 54 | 2 | 88 |
| **Novel terms (this document)** | **16** | **57** | **13** | **86** |

All novel terms are anchored in the DUL-derived backbone. Every novel class is a subclass of
a replicated class (`Entity`, `Region`, `Description`, `Situation`, `Role`, `Collection`, `Task`), and
every novel object property is a sub-property of `top:associatedWith` (the replica of
`dul:associatedWith`), directly or through another property. DUL's own root for datatype
properties, `hasDataValue`, is now replicated in top-level (with `hasRegionDataValue` as its
sub-property). Four of the 13 novel datatype properties are below it: `lowerBoundaryValue` and
`upperBoundaryValue` (sub-properties of `hasRegionDataValue`) and, through them, `startTime` and
`endTime`. The other nine have no common super-property; they could be declared sub-properties of
`hasDataValue` too.

"Used by" lists the other modules in `ontologies/` that reference the term, found by a text
search excluding tests and the DUL copy. Terms with no users are marked "–".

---

## 1. Characteristics, values and measurement

The top-level adds a **Characteristic** layer next to DUL's Quality/Region pattern. It gives
a lighter "entity → characteristic → value + unit" modelling style. It also refines
`hasRegion` into exact, approximate and nominal quantifications, and adds `Interval`, the
regions delimited by a lower and an upper boundary.

| Term | Type | Placement | Meaning | Relation to DUL / notes | Used by |
|---|---|---|---|---|---|
| `Characteristic` | Class | ⊑ `Entity` | Any aspect, attribute or quality of an entity (size, aesthetic quality, colour…). | Overlaps `dul:Quality` (aspects) and `dul:Region` (values). Its subclasses mix social objects (`Parameter`, which is also a `Concept`) with value-like entities (`Value`), so it cuts across DUL's Object/Quality/Abstract split. Its intended ontological status should be documented. | core/judgement.owl |
| `Value` | Class | ⊑ `Characteristic`; `value exactly 1`; `hasUnitOfMeasure max 1 UnitOfMeasure`; key (`hasUnitOfMeasure`, `value`) | A value, typically with a unit of measure. | Close to `dul:Region`/`dul:Amount` combined with `dul:hasRegionDataValue` and `dul:UnitOfMeasure` (DUL: "units of measure are parameters on regions"). | core/naming.owl, core/judgement.owl |
| `Material` | Class | ⊑ `Characteristic` | The material (of something). | No DUL class. Materials are usually substances (cf. `dul:Substance`, a `PhysicalBody`), but here a material is a characteristic. The comment ("The material class") should say which reading is intended. | – |
| `hasCharacteristic` / `isCharacteristicOf` | OP | ⊑ `associatedWith`; `Entity` → `Characteristic` | An entity and one of its characteristics. | Generalises `dul:hasQuality`/`dul:hasRegion` in spirit, but is not declared as their super-property. | – |
| `hasValue` / `isValueOf` | OP | ⊑ `hasCharacteristic`; `Entity` → `Value` | An entity and its value. | Analogue of `dul:hasRegion` for `Value`. | core/judgement.owl (`hasValue`) |
| `value` | DP | `Entity` → `rdfs:Literal` | Literal representation of a value. | Analogue of `dul:hasDataValue`/`dul:hasRegionDataValue`. It could be declared a sub-property of the replicated `hasDataValue`. | core/judgement.owl |
| `hasUnitOfMeasure` / `isUnitOfMeasureOf` | OP | ⊑ `hasCharacteristic`; `Entity` → `UnitOfMeasure` | A measurable entity and its unit. | In DUL a unit is a `Parameter` that `parametrizes` a region. This property is effectively a specialisation of `top:isParametrisedBy`, but it is not declared as one. | – |
| `symbol` | DP | `Entity` → `rdf:PlainLiteral` | A symbol, e.g. of a unit of measure. | No DUL counterpart. | – |
| `hasExactRegion` / `isExactRegionFor` | OP | ⊑ `hasRegion` / `isRegionFor` | A region giving an exact quantification of an aspect of the entity. | Clean specialisation of `dul:hasRegion`. | data/data.owl |
| `hasApproximateRegion` / `isApproximateRegionFor` | OP | ⊑ `hasRegion` / `isRegionFor` | A region giving an approximate quantification. | Clean specialisation of `dul:hasRegion`. | data/data.owl |
| `hasNominalRegion` / `isNominalRegionFor` | OP | ⊑ `hasRegion` / `isRegionFor` | A region giving the nominal quantification (according to some specification). | Clean specialisation of `dul:hasRegion`. | – |
| `Interval` | Class | ⊑ `Region`; `hasLowerBoundary max 1 Region`, `hasUpperBoundary max 1 Region`, `lowerBoundaryValue max 1 rdfs:Literal`, `upperBoundaryValue max 1 rdfs:Literal` | A region delimited by a lower and an upper boundary. In the linear case (a totally ordered one-dimensional space), the points between the two boundaries. In general, in a (partially) ordered space, the points x with lower ≤ x ≤ upper: a box (hyperrectangle) in a multi-dimensional space ordered component-wise, e.g. a latitude-longitude bounding box; an arc from lower to upper in the positive direction in a cyclic space, e.g. longitude. Not defined for unordered (nominal) spaces. Open/closed boundaries are not specified. | No DUL counterpart; DUL has only `dul:TimeInterval` and `dul:SpaceRegion`. Super-class of the replicated `TimeInterval`. Comparable to the order intervals of mathematics and to the bounding regions of the data module (`data:hasBoundingRegion`). | – |
| `hasLowerBoundary` / `isLowerBoundaryOf` | OP | ⊑ `associatedWith`; `Interval` → `Region` | An interval and its lower boundary (its start in the linear case; the corner with all coordinates minimal in a multi-dimensional space). | No DUL counterpart. Boundaries are regions of the same space, typically points (cf. `data:Point`). | – |
| `hasUpperBoundary` / `isUpperBoundaryOf` | OP | ⊑ `associatedWith`; `Interval` → `Region` | An interval and its upper boundary (its end in the linear case; the corner with all coordinates maximal in a multi-dimensional space). | Same as above. | – |
| `lowerBoundaryValue`, `upperBoundaryValue` | DP | ⊑ `hasRegionDataValue`; `Interval` → `rdfs:Literal` | Literal values of the boundaries of an interval in a linear space. | Shortcut for `hasLowerBoundary`/`hasUpperBoundary` followed by `hasRegionDataValue`. Super-properties of `startTime`/`endTime`. | – |

## 2. Time

The top-level adds a temporal-entity layer with literal timestamps, in the style of OWL-Time.
The replicated `TimeInterval` is both an `Interval` (hence a `Region`, as in DUL) and a `TemporalEntity`.

| Term | Type | Placement | Meaning | Relation to DUL / notes | Used by |
|---|---|---|---|---|---|
| `TemporalEntity` | Class | ⊑ `Entity` | Any temporal entity (intervals, months, days…). Its literal representation is given with `time` or its sub-properties, as an `xsd:dateTime`. | Comparable to `time:TemporalEntity` (OWL-Time). The DUL counterpart would be `dul:TimeInterval` or `dul:Region`. The former restrictions `time some/only xsd:dateTime` were removed (review, finding A3); `time` now has range `xsd:dateTime`. | core/agentrole.owl |
| `Year` | Class | ⊑ `TemporalEntity` | A calendar year. | No DUL counterpart. Its former restriction `year max 1 xsd:gYear` was removed together with the `year` property. | – |
| `atTime` / `isTimeOf` | OP | ⊑ `associatedWith`; `Entity` → `TemporalEntity` | Any entity and a temporal entity. | Generalises `dul:hasTimeInterval` (which is limited to events). Candidate super-property of `hasTimeInterval`. | core/agentrole.owl (`atTime`) |
| `time` | DP | `Entity` → `xsd:dateTime` | Literal representation of time. | Analogue of `dul:hasDataValue` for time. DUL has `dul:hasEventDate`, `dul:hasIntervalDate` (not replicated). | – |
| `startTime`, `endTime` | DP | ⊑ `time`, ⊑ `lowerBoundaryValue` / `upperBoundaryValue`; `TimeInterval` → `xsd:dateTime` | Start and end of a time interval, i.e. its lower and upper boundary. | Analogue of `dul:hasIntervalDate`. The range was `xsd:date ∪ xsd:dateTime ∪ xsd:time`; it is now `xsd:dateTime`, like `time`. | – |

## 3. Identifiers and sources

These terms are metadata-oriented and resemble Dublin Core and PROV. DUL covers this area only
abstractly, through `InformationObject`/`InformationRealization`, and those classes are not
replicated.

The top-level used to define datasets and their distributions as well (`Dataset`, `DataSchema`,
`SchemaAttribute`, `Media`, and the properties `hasDataSchema`, `hasSchemaAttribute`, `hasMedia`,
`hasDownloadURL`, `mediaType` with their inverses). They duplicated the richer model of the data
module (`data:Dataset`, `data:DataSource`, `data:DataFormat`, `data:hasURL`, …), and no module used
them, so they were removed. See `../../data/doc/top-level-alignment-review.md`, section 9.

| Term | Type | Placement | Meaning | Relation to DUL / notes | Used by |
|---|---|---|---|---|---|
| `IdentifierSchema` | Class | ⊑ `Description` | A scheme for identifiers. | Specialises `dul:Description`. | – |
| `hasIdentifierSchema` / `isIdentifierSchemaOf` | OP | ⊑ `hasDescription` / `isDescriptionOf`; range `IdentifierSchema` | A unique identifier and its schema. | `hasIdentifierSchema` has no domain and `isIdentifierSchemaOf` no range. Presumably this is the object of `hasUniqueIdentifier`. | – |
| `hasUniqueIdentifier` / `isUniqueIdentifierOf` | OP | ⊑ `hasCharacteristic` / `isCharacteristicOf`; domain `Entity` | An entity and its unique identifier. | No range (only `Characteristic`, inherited). The Italian comment of `isUniqueIdentifierOf` is tagged `@en`. | – |
| `identifier` | DP | domain `Entity` | Literal value of an identifier (e.g. WMO code). | Comparable to `dcterms:identifier`. No range. | – |
| `componentIdentifier` | DP | ⊑ `identifier`; domain `Entity` | Identifier local to the parent in a `hasComponent` hierarchy. | Builds on `dul:hasComponent`. No range. | – |
| `hasSource` / `isSourceOf` | OP | ⊑ `associatedWith`; `Entity` → `Entity` | An entity and its source. | Comparable to `prov:wasDerivedFrom`/`dcterms:source`. The inverse was originally minted with a typo, `isSouceOf`. That IRI is kept as a deprecated alias (`owl:deprecated true`, `owl:equivalentProperty isSourceOf`); it was not used by other modules. | – |

## 4. Vocabularies and naming

These terms replicate part of SKOS and simple naming annotations as DUL-anchored properties.

| Term | Type | Placement | Meaning | Relation to DUL / notes | Used by |
|---|---|---|---|---|---|
| `ConceptScheme` | Class | ⊑ `Description` | A set of concepts, optionally with relationships between them. | Specialises `dul:Description` (a description that `defines`/`usesConcept` concepts). Definition from `skos:ConceptScheme`. No Italian label. | – |
| `inScheme` / `includesInScheme` | OP | ⊑ `associatedWith`; `Entity` → `ConceptScheme` | Membership of a resource in a concept scheme. | Corresponds to `skos:inScheme`. For concepts it overlaps `dul:isConceptUsedIn`/`isDefinedIn`, so it could be a sub-property of `isConceptUsedIn` if restricted to concepts. | – |
| `hasBroader` / `hasNarrower` | OP, transitive | ⊑ `associatedWith`; `Concept` → `Concept` | Concept hierarchies. | Overlaps `dul:specializes`/`isSpecializedBy` (the replicas `top:specializes`/`isSpecializedBy`) and SKOS `broaderTransitive`/`narrowerTransitive` (not `broader`, which is not transitive). Could be declared sub-properties of `specializes`/`isSpecializedBy`, or of `isRelatedToConcept`. | – |
| `definition` | DP | `Concept` → `rdfs:Literal` | Definition of a concept. | Corresponds to `skos:definition`. | – |
| `name` | DP | `Entity` → `rdfs:Literal` | Name of an entity. | No DUL counterpart. See also `core/naming.owl`. | core/naming.owl |
| `altLabel` | DP | `Entity` → `xsd:string` | An alternative label. | Corresponds to `skos:altLabel`. Its range `xsd:string` forbids language tags, which `skos:altLabel` allows. | – |
| `acronym` | DP | `Entity` → `rdfs:Literal` | An acronym. | No DUL counterpart. | ccso/ccso.owl |

## 5. Tasks, workflows and roles

These terms extend the DUL Description & Situation (D&S) plan and workflow pattern with
input/output roles and explicit role assignments.

| Term | Type | Placement | Meaning | Relation to DUL / notes | Used by |
|---|---|---|---|---|---|
| `Operation` | Class | ⊑ `Description` ⊓ `Task` | A self-described task, not specific to a plan. | Combines `dul:Description` and `dul:Task` (compatible: they are not disjoint in DUL). No Italian label. | – |
| `InformationRole` | Class | ⊑ `Role` | A role classifying information. | Specialises `dul:Role`. Note that `dul:Role` classifies only `dul:Object`, while "information" can be an `InformationEntity`. The top-level does not replicate that restriction. | – |
| `InputInformationRole`, `OutputInformationRole` | Class | ⊑ `InformationRole` | Information roles for process inputs and outputs. | Specialise `dul:Role`. | – |
| `WorkflowRole` | Class | ⊑ `Role` | A role that is also a property on `WorkflowExecution`. | The axioms `⊑ rdfs:Property` and `rdfs:domain only WorkflowExecution` were outside OWL 2 DL (review, finding A2). They were removed and are now stated in the `rdfs:comment`: each workflow role is also a property whose domain is `WorkflowExecution`; to use it this way, declare the role IRI also as an `owl:ObjectProperty` with that domain (OWL 2 punning). | – |
| `ObjectRoleAssignment` | Class | ⊑ `Situation` | Assignment of an object to a role, in a situation. | Situation-based reification of `dul:hasRole`, similar to DUL's time-indexed classification pattern. | – |
| `hasAssignedRole` / `isAssignedRoleIn` | OP | ⊑ `associatedWith`; `ObjectRoleAssignment` → `Role` | The role of an assignment. | Natural sub-property of `dul:isSettingFor`/`hasSetting` (the situation "is setting for" its role), but it is not declared as one. | – |
| `hasAssigneeObject` / `isAssigneeObjectIn` | OP | ⊑ `associatedWith`; `ObjectRoleAssignment` → `Object` | The object of an assignment. | Natural sub-property of `dul:includesObject`/`isSettingFor`. | – |
| `hasInputRole` / `isInputRoleOf` | OP | ⊑ `associatedWith`; `Task` → `Role` | Roles to be filled by objects consumed by actions executing the task. | Natural sub-property of `dul:isRelatedToConcept`, like `dul:isTaskOf` (the inverse direction of `dul:hasTask`). | – |
| `hasOutputRole` / `isOutputRoleOf` | OP | ⊑ `associatedWith`; `Task` → `Role` | Roles to be filled by objects produced by actions executing the task. | Same as above. | – |
| `hasOutput` | OP | ⊑ `associatedWith`; `Action` → `Object` | An action and an object it produces. | Arguably a sub-property of `dul:hasParticipant`. No inverse. | – |
| `hasExpectedType` / `isExpectedTypeOf` | OP | ⊑ `associatedWith`; domain / range `InformationRole` | Expected RDFS/OWL class of the information filling a role. | The `rdfs:Class` range/domain was outside OWL 2 DL (finding A2). It was removed and is now stated in the `rdfs:comment`: the class end of the relation is a class, used as an individual through OWL 2 punning. | – |

## 6. Situations and eventualities (d0-style)

These properties come from the d0 / "eventuality" pattern (cf. the comment on `top:Situation`)
and connect a situation with its arguments.

| Term | Type | Placement | Meaning | Relation to DUL / notes | Used by |
|---|---|---|---|---|---|
| `involves` / `isInvolvedIn` | OP | ⊑ `isSettingFor` / `hasSetting`; `Situation` → `Entity` | A situation and the entities that are its arguments. | Same domain and range as the replicated `isSettingFor` / `hasSetting` (= DUL). Now declared as their sub-properties, so the arguments of a situation are also entities it is the setting for. Widely used (core/agentrole, core/judgement, core/naming, medical-dx, ccso doc). | core/*, medical-dx/mdx.owl, ccso doc |
| `hasEventuality` / `isEventualityOf` | OP | ⊑ `hasSetting` / `isSettingFor`; `Entity` → `Situation` | An entity and an eventuality (situation). | Same signature as `hasSetting` and `isInvolvedIn`; now declared a sub-property of `hasSetting`. The comments speak of an "Eventuality", i.e. `Situation` in its d0 reading (see the `skos:scopeNote` of `Situation`). | core/agentrole.owl |
| `isRoleInvolvedIn` | OP | ⊑ `hasEventuality`; domain `Role` | A role and the agent-role situation it is involved in. | No range, no inverse. | – |

## 7. Other general-purpose terms

| Term | Type | Placement | Meaning | Relation to DUL / notes | Used by |
|---|---|---|---|---|---|
| `System` | Class | ⊑ `Entity` | Any kind of system. | No DUL class. DUL talks of systems in the comments of `hasComponent` ("an Object (the system)") and `hasConstituent`, which suggests `System ⊑ Object`. | – |
| `hasSystem` / `isSystemOf` | OP | ⊑ `associatedWith`; `Entity` → `System` | Any entity and a system. | Relationship to `isComponentOf` is not stated. | – |
| `Judgement` | Class | ⊑ `Entity` | The process of forming an opinion by discerning and comparing. | The comment describes a *process*, which in DUL would be an `Event`/`Action`. Placing it directly under `Entity` loses this. See `core/judgement.owl` for the full pattern. | ccso/Constraint.owl |
| `hasCollection` / `isCollectionOf` | OP | ⊑ `associatedWith`; `Entity` → `Collection` | An entity and a collection. | Same signature as the replicated `isMemberOf` / `hasMember`, with a more generic comment. Membership is now declared as a specialisation: `isMemberOf ⊑ hasCollection`, `hasMember ⊑ isCollectionOf`. | – |
| `hasDescription` / `isDescriptionOf` | OP | ⊑ `associatedWith`; `Entity` → `Description`; ≡ `isDescribedBy` / `describes` | An entity and its description. | Duplicate of the replicated `isDescribedBy` / `describes` (= DUL), with the same domain, range and meaning. Now declared equivalent to them; both IRIs remain usable. `hasIdentifierSchema` is a sub-property of it. | ccso doc (CSW case) |
| `hasCreator` / `isCreatorOf` | OP | ⊑ `associatedWith`; domain `Entity` | An entity and its creating agent. | No range (should be `Agent`). Comparable to `dcterms:creator`. | – |
| `isIssuedBy` / `issues` | OP | ⊑ `associatedWith`; domain `Entity` | An entity and the agent that issued it. | Its labels and comments were copied from `hasCreator` / `isCreatorOf`. They now follow the IRI: "is issued by" / "issues", "è emesso da" / "emette". Issuing (cf. `dcterms:publisher`) and creating (cf. `dcterms:creator`) are kept as distinct relations. | – |
| `specialises` / `isSpecialisedBy` | OP, transitive | ⊑ `associatedWith`; `Entity` → `Entity` | Specialisation relations. | Same relation as the replicated `specializes` / `isSpecializedBy` (= DUL), with a wider domain/range (`Entity` instead of `SocialObject`). The DUL replicas are now declared sub-properties of these. They still share the Italian labels "specializza" / "è specializzato da". | – |

---

## Observations

1. **Overlap with replicated DUL terms.** Several novel properties restated relations that the
   top-level already takes from DUL. They are now linked to their DUL counterparts without
   removing any IRI, because several are used by other modules:
   `hasDescription`/`isDescriptionOf` ≡ `isDescribedBy`/`describes`;
   `specializes`/`isSpecializedBy` ⊑ `specialises`/`isSpecialisedBy`;
   `involves`/`isInvolvedIn` and `hasEventuality`/`isEventualityOf` ⊑ `isSettingFor`/`hasSetting`;
   `isMemberOf`/`hasMember` ⊑ `hasCollection`/`isCollectionOf`. The labels of `isIssuedBy`/`issues`,
   which duplicated those of `hasCreator`/`isCreatorOf`, were fixed.
2. **Flat property hierarchy.** Most novel object properties hang directly under
   `associatedWith`, even where a more specific DUL parent exists (`isSettingFor`,
   `isRelatedToConcept`, `hasParticipant`, `hasRegion`, `isParametrisedBy`). Declaring the
   specific parent would let DUL-aware tools and queries interpret them.
3. **External vocabularies.** Many novel terms re-create SKOS, DCAT, Dublin Core, PROV or
   OWL-Time terms. These links are not formalised anywhere. A separate alignment file (like
   the DUL one) could record them with `rdfs:subPropertyOf`/`owl:equivalentProperty` or
   `skos:closeMatch`.
4. **Annotation gaps** (whole ontology, including replicas): 30 terms have no Italian
   label (mostly the more recent additions: roles, workflow, region refinements, SKOS-like
   terms). `startTime` and `endTime` have no comment. 11 terms have comments with no
   language tag.
5. **OWL 2 DL.** The OWL 2 DL issues introduced by novel terms (`WorkflowRole`,
   `hasExpectedType`/`isExpectedTypeOf`, the `TemporalEntity` restrictions) were removed; the
   top-level is now in OWL 2 DL. The constraints that OWL 2 DL cannot express are stated in the
   `rdfs:comment` of the terms concerned. All temporal literals now use `xsd:dateTime` (`time`,
   `startTime`, `endTime`; the `year` property was removed), so the top-level only uses datatypes
   of the OWL 2 datatype map and is accepted by HermiT in strict mode.
