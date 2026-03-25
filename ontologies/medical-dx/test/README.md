# Running OWLUnit Test Cases

This folder includes ontology test cases defined according to the OWLUnit specification. [OWLUnit](https://github.com/luigi-asprino/owl-unit) provides a framework for validating ontologies through executable test cases expressed in RDF format.

## 1. Clone or download this repository

First, obtain a local copy of this repository:

```bash
git clone https://github.com/hacid-project/knowledge-graph.git
cd knowledge-graph/ontologies/medical-dx
```

## 2. Download OWLUnit

Download OWLUnit from its [official repository](https://github.com/luigi-asprino/owl-unit):

After downloading, place the OWLUnit `.jar` file inside the `test` folder:

```
ontologies/medical-dx/
└── test/
    ├── OWLUnit-<VERSION>.jar
    ├── <test_file_name_1>.ttl
    ├── <test_file_name_2>.ttl
    ├── ....
    └── <test_file_name_n>.ttl
```

---

Make sure you have Java installed (Java 17 or higher recommended) before running the tests.

## 3. Run a test case

To execute a specific test case, run the following command from within the `test` directory (or adjust paths accordingly):

```bash
java -jar OWLUnit-<VERSION>.jar -c <test_case_uri> -f ./<test_file_name_x>.ttl
```

### Parameters

* `-c <test_case_uri>`: The URI identifying the OWLUnit test case to run.
* `-f <file>`: The Turtle (`.ttl`) file containing the test case definition.

### Output

You will get an output similar to:
```
INFO 2025-03-24 14:53:18,438 [main] (OWLUnit.java:89) - Test case URI https://w3id.org/hacid/data/testcase/mdx1.ttl
CQ Verification test PASSED
```
