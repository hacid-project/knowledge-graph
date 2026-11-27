# Review of the diagrams against the current ontologies

Checked on 2026-11-27, on `main` at `a2a058f`. The labels of the 66 diagram sources of the repository (yEd
`.graphml` and draw.io `.drawio` under `ontologies/`) were compared with the terms declared by the ontology files of
the repository (every `.owl` and `.ttl` under `ontologies/`, but the external ones). Only names with the prefixes of
the HACID ontologies are checked: `top`, `data`, `ccso`, `jdg`, `ar`, `mdx`, `ev`, `nm`.

A name is reported if it is **deprecated** (it has an `owl:deprecated` replacement) or **not declared** under its
namespace. "Legacy module" means that the name is declared only in `ccso/doc/modules/Models.owl` or
`ccso/doc/modules/PhenomenaAndHazards.owl`, the modules that CCSO replaced. The suggested terms are those of the
current ontologies; "none" means that the current ontologies have no counterpart.

## 1. Renamed in this change

Two names were replaced in the labels, with no other change to the diagrams (17 labels in 11 files):

| Old name | Current name | Files |
|:--|:--|:--|
| `data:hasDiscretization` (deprecated) | `data:adoptsQuantization` | `ccso/doc/visual/src/`: `dimensional-space.graphml`, `variable-example2.graphml`, `variable-example3.graphml`, `sales.graphml`, `example_claude.graphml`, `variable_example.drawio`, `variable_example_compact.drawio`, `variable_example_const_space.drawio`, `variable_example_wop.drawio` |
| `hasSubdimensionalSpace`, `data:hasSubdimensionalSpace` (misspelt) | `data:hasSubDimensionalSpace` | `ccso/doc/visual/src/`: `variable-example.graphml`, `variable-example2.graphml`, `variable_example_wop.drawio`; `ccso/doc/visual/non-final/dataset_v2.graphml` |

The other deprecated names of the ontologies (`data:Sampling`, `data:IntervalSampling`,
`data:isDiscretizationFor`, `top:isSouceOf`) are in no diagram source.

## 2. Images to export again

The images are not generated here (yEd has no command line). Two images of `ccso/doc/visual/img/` were already behind
their sources before this change, and are now further behind:

- `dimensional-space.png` shows `data:hasDiscretization`, `data:Sampling` and `data:IntervalSampling`; its source has
  `data:adoptsQuantization`, `data:PointSampling` and `data:RegularPointSampling`.
- `variable-example.png` shows `data:hasDiscretization`; its source has `data:adoptsQuantization` (and now
  `data:hasSubDimensionalSpace`).

Several other images of `img/` show the names listed in section 3 (`case-overview-simple`, `general`,
`general+ensemble`, `general+stat`, `model`, `phenomena_and_risk`, `phenomena_properties`, `simulation`,
`workflow_example`, `workflow_object`): export them again once their sources are decided. No image of `img/` is
referenced by the documents of the repository.

## 3. Names not in the current ontologies

These need a decision for each diagram: update it to the current terms, move it to an archive folder (as an earlier
design), or delete it.

### CCSO: models, simulations, projections (`ccso/doc/visual/`)

| Diagram | Names | Current terms | Suggestion |
|:--|:--|:--|:--|
| `src/projection-production.graphml`, `img/projection-production-ext.graphml` | `ccso:SingleProjProd`, `ccso:EnsembleProjProd`, `ccso:ProbabilisticProjProd`, `ccso:StatisticalProjTransf`, `ccso:PPESimulation`, `ccso:CMIPExperiment` | abbreviations of `ccso:SingleProjectionProduction`, `ccso:EnsembleProjectionProduction`, `ccso:ProbabilisticProjectionProduction`, `ccso:StatisticalProjectionTransformation`, `ccso:PerturbedParameterClimateEnsembleSimulation`, `ccso:ClimateModelIntercomparisonExperiment` | Keep: the abbreviations are deliberate, to fit the figure of the data descriptor (`-ext`). A legend could give the full names |
| `src/general.graphml`, `src/general+ensemble.graphml`, `src/general+stat.graphml` | `ccso:hasAdoptedModel`; `ccso:SingleProj.Prod`, `ccso:Proj.EnsembleProd`, `ccso:ProbabilisticProj.Prod`, `ccso:StatisticalProj.Transform`, `ccso:PerturbedParameterEnsembleSimulation` | `ccso:usesModel`; the full names above | Update (`hasAdoptedModel` is an earlier name); the abbreviations can stay |
| `src/model.graphml` | `ccso:Model`, `ccso:NonGlobalClimateModel`, `ccso:ConvectionPermittingModel`, `ccso:IntegratedAssessmentModel` (legacy module) | `ccso:ClimateModel`; `ccso:RegionalClimateModel` and `ccso:LocalClimateModel`; `ccso:ConvectionPermittingClimateModel`; none | Update, or archive as the design of the legacy module |
| `src/simulation.graphml` | `ccso:Model` (legacy module), `ccso:hasAdoptedModel`, `ccso:hasMemberSimulation`, `ccso:hasOutput`, `ccso:DataGeneratingProcess`, `top:InformationObject`, `top:SocialAttribute` | `ccso:ClimateModel`, `ccso:usesModel`, `top:hasComponent` (as in the KG), `data:hasOutput`, `data:DataGeneratingProcess`, `top:InformationEntity`, none | Update or archive |
| `non-final/simulation.graphml` | `data:SpatioTemporalDataCube` | none | Archive (already in `non-final/`) |

### CCSO: phenomena and risk (`ccso/doc/visual/src/`)

| Diagram | Names | Current terms | Suggestion |
|:--|:--|:--|:--|
| `phenomena_and_risk.graphml` | `ccso:relatedWithPhenomenon` (legacy module), `ccso:hasImpactOnAsset`, `ccso:hasPotentialImpactOnAssetType` | none; `ccso:hasImpact`, `ccso:sufferedImpact`; `ccso:hasPotentialImpactType`, `ccso:potentiallySuffersImpactType` | Update: the risk part of CCSO was remodelled (impacts, impact types, vulnerabilities) |
| `phenomena_properties.graphml` | `ccso:relatedWithPhenomenon`, `ccso:causedPhenomenon`, `ccso:influencesPhenomenon`, `ccso:influencedPhenomenon`, `ccso:featuresPhenomenon` (all legacy module) | `ccso:causesPhenomenaOfType`, `ccso:isCausedByPhenomenaOfType` (between types); none for the others | Archive as the design of the legacy module, unless the relations among phenomena are to be added to CCSO |

### Data module: variables, spaces, examples (`ccso/doc/visual/src/`)

| Diagram | Names | Current terms | Suggestion |
|:--|:--|:--|:--|
| `dimensional-space.graphml` | `data:TimePoint`, `data:containsDimensionalSpace`, `data:hasReferencePointValue`, `data:hasRegion` | none (`data:Point`, `data:GeodeticPoint`); `data:hasSubDimensionalSpace` or `data:basedOnDimensionalSpace`; none (`data:hasReferencePoint`, `data:hasPointValue`); `top:hasRegion` | Update, then export the image (section 2) |
| `variable-example.graphml` | `data:DatasetSource`, `data:RollingRegularGrid`, `data:containsDimensionalSpace`, `data:hasGridStep` | `data:DataSource`; none (`data:SimpleRegularBinning` in the KG); as above; `data:hasResolutionValue` | Update, then export the image (section 2) |
| `variable-example2.graphml`, `variable-example3.graphml` | `data:DatasetSource`; `data:containsDimensionalSpace` (2 only) | `data:DataSource`; as above | Update, or archive in favour of the draw.io versions |
| `variable_example*.drawio` (4 files) | `data:hasAvailableFormat` (`hasAvailabl` and `eFormat` in two spans of the label) | `data:hasAvailableDataFormat` | Update (one label each) |
| `sales.graphml`, `example_claude.graphml` | `data:DatasetSource` | `data:DataSource` | Look like scratch files: delete, or update |

### Workflow and operations (`ccso/doc/visual/src/`)

| Diagram | Names | Current terms | Suggestion |
|:--|:--|:--|:--|
| `case-overview.graphml`, `df-overview.graphml`, `case-overview-simple.graphml` | `top:OperationInformationRole`, `top:PlanInformationRole`, `top:OperationRoleAssignment`, `top:OperationRoleAssignmentFromPlanRole`, `top:OperationRoleConstantAssignment`, `top:forOperationRole`, `top:fromPlanRole`, `top:forTask`, `top:executedThroughOperation`, `top:hasInternalRole`, `top:getsDefaultInputFromPlanRole`, `top:sendsDefaultOutputToPlanRole`, `top:hasConstantDefaultInput`, `top:hasConstantDefaultOutput`; `top:Assessment`, `top:Request` | `top:InformationRole`, `top:InputInformationRole`, `top:OutputInformationRole`, `top:WorkflowRole`, `top:ObjectRoleAssignment`, `top:hasInputRole`, `top:hasOutputRole`, `top:hasAssignedRole`, `top:hasAssigneeObject`, `top:Operation`, `top:Task`, `top:Plan`, `top:executesTask`; none for the constant and default assignments; `ccso:Assessment`, `ccso:Request` | Decide whether the design of plans with default inputs and outputs is still intended: if so, the top-level lacks it; if not, update or archive |
| `workflow_entity.graphml` | `top:EntityRole`, `top:EntityRoleAssignment`, `top:assignedRole`, `top:definesEntityRole`, `top:involvedEntity`, `top:context`, `top:includes` | `top:Role`, `top:ObjectRoleAssignment`, `top:hasAssignedRole`, `top:definesRole`, `top:hasAssigneeObject`, none, `top:includesEvent` or `top:includesObject` | Update or archive (the current pattern is in `workflow_object`) |
| `workflow_example.graphml`, `workflow_object.graphml` | `top:includes` | `top:includesEvent` or `top:includesObject` | Update (one label each) |

### Core modules (`core/`, `top-level/`)

| Diagram | Names | Current terms | Suggestion |
|:--|:--|:--|:--|
| `core/judgement-pattern.graphml`, `top-level/judgement-pattern.graphml` (identical files) | `top:Judgment`, `top:MetaJudgement`, `top:hasJudge`, `top:judgesOn`, `top:Result`, `top:hasResult`; `mdx:DiagnosisResult`, `mdx:MedicalDescription` | `jdg:Judgement` (or `top:Judgement`), `jdg:MetaJudgement`, `jdg:hasJudge`, `jdg:isJudgementOn`, `jdg:JudgementResult`, `jdg:hasJudgmentResult`; `mdx:Diagnosis`, `mdx:Description` | Update one copy and delete the other |
| `core/judgement.graphml` | `top:Judgment`, `top:judgesOn`, `jdg:Result` | as above | Update |
| `core/examples/judgement-example1.graphml`, `core/examples/metajudgement-example.graphml` | `jdg:judgesOn`, `jdg:Result`, `jdg:hasJudgementResult` | `jdg:isJudgementOn`, `jdg:JudgementResult`, `jdg:hasJudgmentResult` (the ontology spells it without the "e") | Update |
| `core/naming.graphml` | `nm:hasAltName`, `nm:hasPrefName` | `nm:hasAlternativeName`, `nm:hasPreferredName` | Update |
| `core/evidence.graphml` | `ev:InformatioEntity`, `ev:Relation` | `top:InformationEntity`; `ev:Statement` | Update |
| `top-level/top-level.graphml` | `top:parametrizes` | `top:parametrises` | Update (one label) |

### Medical diagnosis (`medical-dx/graphical representations/`)

| Diagram | Names | Current terms | Suggestion |
|:--|:--|:--|:--|
| `DnS.graphml` | `top:satisfy`, `top:hasResult`, `jdg:judgesOn` | `top:satisfies`, `jdg:hasJudgmentResult`, `jdg:isJudgementOn` | Update |
| `MDXExample.graphml`, `diagnostic-attempt.graphml` | `mdx:HealthcareProfessional`; `mdx:Rank`, `mdx:ranks`, `mdx:withRank`, `top:hasResult` (first); `mdx:DiagnosticAttempt`, `mdx:RankedClinicalEvaluationCollection`, `mdx:hasRankedClinicalEvaluations`, `mdx:numberOfFindings` (second) | `mdx:HeatlhcareProfessional`, misspelt in the ontology: better corrected there; none for the ranking and the diagnostic attempt | Decide whether the ranking pattern is to be added to `mdx.owl` |
| `RankedDiagnoses.graphml` | `mdx:Rank`, `mdx:ranks`, `mdx:withRank`, `mdx:RankedClinicalEvaluation`, `mdx:RankedClinicalEvaluationCollection`, `mdx:hasRankedClinicalEvaluations` | none | As above |
| `finding.graphml` | `mdx:FindingSequence`, `mdx:hasFindingSequence`, `mdx:detail`, `top:hasFirstItem`, `top:hasLastItem` | none | Decide whether the sequence pattern is to be added |
| `mdx-core.graphml` | `mdx:Seniority`, `mdx:hasSeniority` | none | As above |

The other 26 diagram sources use only declared terms.
