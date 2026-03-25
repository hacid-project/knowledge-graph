# knowledge-graph

This repository contains resources, data, and tooling for building and evaluating domain-specific knowledge graphs within the HACID project.

## Overview

The HACID project focuses on developing hybrid human–AI collective intelligence systems for decision support in complex, open-ended domains such as **medical diagnostics** and **climate services**. A core component of this approach is the construction of **case knowledge graphs (CKGs)** and **domain knowledge graphs (DKGs)**, which integrate heterogeneous data sources into a structured, semantically rich representation.

This repository provides materials related to the creation, population, and validation of such knowledge graphs.

## Contents

* **Ontology definitions** – schemas and vocabularies used to model domain knowledge
* **Data sources** – structured and semi-structured datasets used to populate the graph
* **RDF generation** – scripts and pipelines for transforming data into RDF triples
* **Evaluation artifacts** – test cases for assessing the ontologies wrt competency questions 

## Methodology

The knowledge graphs in this project rely on Semantic web standards (e.g., RDF, OWL), build on modular and reusable ontology components, and are developed using a combination of:

* Top-down ontology engineering and design patterns
* Bottom-up data integration from multiple sources

These approaches ensure consistency, interoperability, and scalability across domains.

## Ontologies

The `ontologies` folder contains the core semantic models used to define and structure HACID knowledge graphs.

### What’s inside

This folder includes:

* **Core / upper-level ontologies** – High-level, reusable concepts and properties that provide a common semantic foundation across the knowledge graph.

* **Cross-domain foundational modules** – Modular ontology components that capture specific subdomains or knowledge areas, designed to be reused and combined into larger ontology networks.

* **Domain ontologies** – Specialized models describing application domains (medical diagnostics and climate services), defining domain-specific entities, relationships, and constraints.
