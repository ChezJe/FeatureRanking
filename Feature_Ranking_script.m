%[text] # Feature ranking as a pre-screening method for QSP models
%[text] 
%[text:tableOfContents]{"heading":"Table of Contents"}
%[text] ## Preparation
try
    isOnline = matlab.internal.environment.context.isMATLABOnline;
    if ~isOnline && isempty(gcp("nocreate"))
        parpool("Processes");
    end
catch
end
%%
%[text] Load model from SimBiology project
sbioloadproject mPBPK_siRNA.sbproj m1

cs = m1.getconfigset();
cs.SolverType = "ode15s";
m1
%%
%[text] %[text:anchor:H_65515706] ## Determination of input parameters
%[text] To determine which parameters we should sample from to generate a variety of response values, we will first list all free parameters in the model. These parameters should be constant and not defined by any initial assignments. 
inputObj = getFreeParameters(m1);
inputObj = removeObjZeroValue(inputObj);
inputObj = removeObjByName(inputObj,"mw");        % Molecular Weight
inputObj = removeObjByName(inputObj,"dose_mgkg"); % Dose amount

inputPars = cell2table(get(inputObj,{'Type','Name','Value'}), VariableNames={'Type','Name','Value'});
inputPars = convertvars(inputPars,"Type","categorical")
%%
%[text] ## Generate parameter samples 
%[text] We will use uniform distribution and set the bounds so as to have one order of magnitude between lower and upper bound.
Nsamples = 10^4;

distObj = arrayfun(@(x) makedist("Uniform","lower",x*10^-0.5,"upper",x*10^0.5), inputPars.Value);
scen = SimBiology.Scenarios(inputPars.Name, distObj, Number=Nsamples, SamplingMethod='sobol');
scen = add(scen,'cartesian','dose_mgkg',1);
%%
%[text] ## Run simulations
%[text] Create SimFunction to return `Cmin` as output.
observableName = ["Protein","Cmin"]; 
dose = getdose(m1,"single dose");
variant = [];

simfun = createSimFunction(m1, scen, observableName, dose, variant, UseParallel=true);
accelerate(simfun);
%[text] Run simulations
inputs = scen.generate()
stopTimeHour = 200; % day
stopTime = sbiounitcalculator('day', simfun.TimeUnits, stopTimeHour); % in units specified in SimFunction
tic
data = simfun(inputs.Variables, stopTime, getTable(dose));
toc
%%
%[text] ## Format simulation results
%[text] Collect simulation results in one column vector. The results are provided in a table format.
output = vertcat(data.ScalarObservables)./1e4;
inputs = removevars(inputs,'dose_mgkg');
%[text] Remove failed simulations
[output, idxRemoved] = rmmissing(output);
inputs(idxRemoved,:) = [];
data(idxRemoved) = [];
%[text] Standardize inputs to have 0 mean and standard deviation of 1. This is strongly recommended for distance based methods like NCA.
normalizedinputs = varfun(@zscore,inputs);
normalizedinputs.Properties.VariableNames = erase(normalizedinputs.Properties.VariableNames, "zscore_");
%[text] Combine inputs and target into a table for training
simTable = [normalizedinputs, output];
%%
%[text] ## Check output variance
f = figure;
tl = tiledlayout(f,1,2);
ax = nexttile(tl);
sbiopercentileplot(data, Name="Cyto.Protein", Parent=ax, Legend="off");
grid(ax,'on');
ylabel(ax,"Protein concentration [nM]");
ax = nexttile(tl);
boxchart(ax,output,"Cmin");
grid(ax,'on');
ylabel(ax,"Cmin [nM]");
%%
%[text] ## Run feature ranking methods
%[text] Option 1: (interactive) Launch Regression Learner app with prepared table and target variable
%[text] ```matlabCodeExample
%[text] regressionLearner(simTable,"Cmin");
%[text] ```
%[text] Option 2: (programmatic) Run associated commands and summarize all scores and ranks in one figure.
names = string(simTable.Properties.VariableNames(1:end-1));
outputname = "Cmin";
%[text] Compute scores for all Feature Ranking methods (NCA, MRMR, F-test, ReliefF).
%[text] 
%[text] ### Neighborhood Component Analysis (NCA)
%[text] We will start with NCA while optimizing its regularization parameter.
N = height(simTable);
Nfold = 5;
cvp = cvpartition(N,'kfold',Nfold);
lambdavals = (20:15:80)/N;
lossvals = NaN(length(lambdavals),Nfold);
cvptrain = cvp.training("all");
cvptest = cvp.test("all");

tic
parfor k = 1:Nfold
    disp("Fold " + k)
    dataT = simTable;
    Ttrain = dataT(cvptrain(:,k),:);
    Ttest  = dataT(cvptest(:,k),:);
    losstemp = NaN(length(lambdavals),1);
    
    for i=1:numel(lambdavals)
        nca = fsrnca(Ttrain,outputname, Standardize=false, Lambda=lambdavals(i),...
            Solver="sgd", LossFunction="epsiloninsensitive", FitMethod="exact");

        losstemp(i) = loss(nca,Ttest,outputname,LossFunction='mse');
    end
    lossvals(:,k) = losstemp;
end
toc
meanloss = mean(lossvals,2);
[~,idx] = min(meanloss);
bestlambda = lambdavals(idx)
figure
plot(lambdavals,meanloss,'o-', LineWidth=2)
xlabel('Lambda')
ylabel('Loss (MSE)')
axis padded
grid on
tic
mdlNCA = fsrnca(simTable, outputname, Standardize=false, Lambda=bestlambda, ...
    Solver="sgd", LossFunction="epsiloninsensitive", FitMethod="exact");
toc
scoreNCA = mdlNCA.FeatureWeights';
%%
%[text] ### Minimum Redundancy Maximum Relevance (MRMR)
[~, scoreMRMR] = fsrmrmr(simTable,outputname);
%[text] ### F-Test
[~, scoreFTest] = fsrftest(simTable,outputname, NumBins=100);
idxInf = isinf(scoreFTest);
scoreFTest(idxInf) = max(scoreFTest(~idxInf));
%[text] ### RReliefF 
k = 10; % same value as in regressionLearner App
[~, scoreReliefF] = relieff(simTable{:,1:end-1},simTable.(outputname), k);
%[text] ### Predictor importance on trained decision tree
%[text] Compute scores by training a regression model and computing the predictor importance score.
opts = hyperparameterOptimizationOptions(KFold=5, Verbose=0, ShowPlots=true, UseParallel="auto");
treeMdl = fitrtree(simTable,outputname,OptimizeHyperparameters="all",HyperparameterOptimizationOptions=opts);
grid on;
bestEstimatedPoint = bestPoint(treeMdl.HyperparameterOptimizationResults)
%[text] Compute predictor importance on tree. This metric takes into account changes in the mean squared error due to splits on every predictor.
scoreTree = predictorImportance(treeMdl);
%[text] ### 
%[text] ### Shapley values
%[text] We can also compute the mean of Shapley values across all simulation results to rank parameters. This method is model-agnostic and can be applied to every regression model including decision trees.
%[text] See [https://www.mathworks.com/help/stats/shapley-values-for-machine-learning-model.html](https://www.mathworks.com/help/stats/shapley-values-for-machine-learning-model.html)
explainer = shapley(treeMdl, QueryPoints=simTable, UseParallel="auto");
swarmchart(explainer,ColorMap="nebula");
scoreShapley = explainer.MeanAbsoluteShapley.Value;
%%
%[text] ## Results summary
%[text] Summarize the results in tables.
methodnames = ["MRMR","NCA","F-Test","RReliefF","Tree - PI", "Tree - Shapley"];
scoreTable = table(names', scoreMRMR', scoreNCA', scoreFTest', scoreReliefF', scoreTree', scoreShapley, VariableNames=["Parameter",methodnames])
%[text] 
plotsummary(scoreTable,"Parameter");
%%
%[text] ## Compare with GSA
load resultsGSA.mat 
scoreGSA = results5000P{1};
plotsummary(scoreGSA,"Parameter");
%%
%[text] Convergence of GSA results
plotconvergence
%%
%[text] Install `gramm` toolbox: [https://github.com/piermorel/gramm](https://github.com/piermorel/gramm)
%[text] Add fit
% websave("gramm.mltbx","https://github.com/piermorel/gramm/releases/download/v3.1.2/gramm_3.1.2.mltbx");
% matlab.addons.toolbox.installToolbox("gramm.mltbx");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
