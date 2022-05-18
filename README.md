# PhD-Research
PhD Research Files

## How to run

### Node embedding

The code to generate the node embedding is located in **generateGraphModels.m**.

**Inputs:**

* database: the index of the database to use. The paths for the databases are found in the paths variable.
* methodNum: the method to use. 1 - no embedding 2 - vectorial embedding 3 - quadratic embedding
* isTest: 0 or 1, if 1, the scene datasets are used with pretrained models
* useSVM: legacy value, should always be 1
* modelsOnly: if 1, it assumes that the embedding has already been computed and saved, trains SVM modely only

**Outputs:**

* opt: the 20% hold-out validation error
* plainloss: the train error
* kloss: the k-fold cross-validation error

To run all embeddings for all datasets, simply run **GetAllModels.m**

### Discriminant Analysis

The file **testDA.m** contains test script for the DA methods. Here, to set the dataset, you can modify the paths in the file. Also, the variable surfTest can be set to 1 in case of image datasets. The file simply returns the classification accuracies and the separation accuracies for the given methods.

To get the DA algorithm results, run **getPCA.m**. 

### Localization

The file **testLoc.m** can compute the localization results for a given dataset and method. It assumes that the embedding has been computed and the classifiers have been trained.

**Inputs:**

* dataset: the index of the database to use. The paths for the databases are found in the paths variable.
* vecType: the embedding method to use. 1 - no embedding 2 - vectorial embedding 3 - quadratic embedding
* method: the optimization method to use. 1 - Greedy 2 - Genetic Algorithm with custom operators 3 - Simulated Annealing 4 - Vanilla GA
* useSVMin: legacy value, should always be 1

**Outputs:**

* result: the final classification accuracy
* costFunGood: the cost function error
* optimFail: the ratio of optimization failures
* classLoss: the accuracy of SVM-only classification

To run the test for all dataset, embeddings and optimization methods, simply run **localizationTestScript.m**

## Dataset

The databases used for this research are avilable [here](https://deeplearning.iit.bme.hu/Public/locDatasets.zip).

### Dataset format:

Each dataset is located in its own detecated subfolder. The classification dataset files start with a prefix number indicating the category, whereas the scene data files start with 'scene'. The data files contain the following information:

* **[prefix]nodes.csv:** Every row of this file lists the node vectors of an objects/scene.
* **[prefix]edges.csv:** Every row of this file is the edge matrix of the corresponding object/scene (serialized in a row-major format).
* **[prefix]centers.csv:** Every row lists the center coordinates of the corresponding nodes.

The labels for the classification datasets are trivial. Label files are automatically created by the embedding method. For the scene datasets the following two files are provided:

* **sceneLabels.csv:** Each row contains the category label of the corresponding node.
* **sceneInstanceLabels.csv:** Contains the Id of the scene the node comes from.

## Graph-Attention baseline

The graph-attention baseline is implemented [here](https://github.com/szemenyeim/GraphAttention).




