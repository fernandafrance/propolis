# propolis

# Propolis Chemical Space and Epigenetic Target Prioritization

## Overview
This repository contains the scripts, workflows, and supplementary material used in the study  
**“Comprehensive mapping of the propolis chemical space reveals opportunities for epigenetic drug discovery”**.

The project presents a curated, compound-resolved dataset of propolis-derived small molecules and an integrated cheminformatics strategy to support hypothesis generation for epigenetic target engagement, with emphasis on chromatin-modifying enzymes.

The associated manuscript is currently **under submission**.

---

## Scientific Background
Propolis is widely used in traditional medicine, yet many reported biological and epigenetic effects are attributed to complex mixtures without clear compound-level attribution. This lack of resolution limits rational translation into drug discovery and increases the risk of false-positive findings.

To address this gap, we constructed a standardized dataset of propolis-derived compounds and applied a cheminformatics workflow combining literature mining, chemical taxonomy, similarity analysis, structural-alert filtering, and structure-based molecular docking.

---

## Dataset Construction
- Literature mining guided by an adapted **PRISMA 2020** framework  
- Databases queried: PubMed, SciELO, and Web of Science  
- Records retrieved: 4,220  
- Studies included after screening: 663  
- Compound-level annotations extracted: 43,745  
- Unique small molecules after de-duplication: 1,322  

Each compound is represented with standardized chemical identifiers and associated metadata.

---

## Chemical Space Analysis
The curated dataset was analyzed using structure-based chemical taxonomy, revealing:
- Predominance of **phenylpropanoids/polyketides**, **lipids and lipid-like molecules**, and **organoheterocyclic compounds**
- Flavonoids as the most frequent chemical class
- Geographic coverage across five continents, with region-associated compositional patterns

---

## Cheminformatics Workflow
The computational pipeline implemented in this repository includes:
- Structure standardization and de-duplication
- Chemical taxonomy assignment
- Similarity benchmarking against reference epigenetic inhibitors
- Structural-alert filtering (including PAINS-aware strategies)
- Drug-likeness assessment
- Hypothesis-generating molecular docking to the human **DNMT1 methyltransferase domain**

Docking simulations were performed using **AutoDock Vina**, including redocking validation and a positive ligand control.

---

## Candidate Prioritization
After structural-alert and drug-likeness filtering, a reduced set of candidates was prioritized for docking analysis. Docking results suggested plausible DNMT1-binding modes partially consistent with the S-adenosyl-L-homocysteine (SAH) interaction framework.

These findings are intended to support **testable hypotheses**, not to substitute for orthogonal biochemical or cellular validation.

---

## Repository Contents
- `scripts/` – Cheminformatics and data-processing scripts  
- `data/` – Curated datasets used for analysis  
- `docking/` – Input files and analysis related to molecular docking  
- `figures/` – Scripts used to generate figures reported in the manuscript  
- `supplementary/` – Supplementary tables and resources  

Each script is documented to support transparency and reproducibility.

---

## Reproducibility
All analyses were performed using openly available tools and documented workflows.  
Versioning, parameters, and filtering criteria are explicitly reported in the scripts and supplementary material.

---

## License
This repository is distributed under the **MIT License**.

Users are free to use, modify, and redistribute the code, provided that appropriate credit is given to the original authors.

---

## How to Cite
If you use this code or dataset, please cite:

> Author(s). *Comprehensive mapping of the propolis chemical space reveals opportunities for epigenetic drug discovery*.  
> Manuscript under submission.

A full citation and DOI will be added upon publication.

---

## Disclaimer
The results generated using this repository are intended for **research and hypothesis generation**.  
They do not constitute experimental validation or clinical evidence.

---

## Contact
For questions related to the code or data, please contact the corresponding author via GitHub.
