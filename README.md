# Feature Ranking for QSP Models

This repository contains a MATLAB workflow for using feature-ranking techniques as a pre-screening method for quantitative systems pharmacology (QSP) models. The main script simulates a SimBiology model across sampled parameter values, computes response summaries, ranks input parameters with multiple machine learning feature-ranking methods, and compares the rankings with saved global sensitivity analysis results.

## Repository Contents

- `Feature_Ranking_script.m` - main MATLAB script exported from a live script. It loads the SimBiology model, generates parameter scenarios, runs simulations, computes feature-ranking scores, and plots summary results.
- `Feature_Ranking.prj` - MATLAB project file.
- `mPBPK_siRNA.sbproj` - SimBiology project containing the model used by the workflow.
- `helper/` - helper functions for selecting free model parameters, filtering parameter objects, plotting feature-ranking summaries, plotting sensitivity convergence, and setting plot defaults.
- `results/resultsGSA.mat` - saved global sensitivity analysis results used for comparison.
- `results/resultsMorris.mat` - saved Morris screening results.
- `resources/` - MATLAB project metadata.


## Requirements

The workflow is intended for MATLAB with the following products:

- SimBiology
- Statistics and Machine Learning Toolbox
- Parallel Computing Toolbox (optional)

The script uses parallel execution for simulations and some ranking/modeling steps, but can also run as is if the Parallel Computing Toolbox is not available.


## Running the Analysis

Open the MATLAB project from the repository root by double clicking on `Feature_Ranking.prj` or typing:

```matlab
openProject("Feature_Ranking.prj")
```


The full simulation uses `Nsamples = 10^4`, so runtime may vary depending on local CPU and available parallel workers. 


