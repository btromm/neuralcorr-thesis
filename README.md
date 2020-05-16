# Variability in Homeostatic Tuning Rules Produces Diverse Correlations Between Ion Channels
## An (undergraduate) Senior Thesis
---
`NEUR 99B: Senior Thesis`   
`Brandeis University, Fall 2019 - Spring 2020`

#### Author: Bobby Tromm
> btromm@brandeis.edu   
> B/S Neuroscience '20   
> Department of Biology, School of Arts and Sciences, Brandeis University   
> :telephone:  [github](https://github.com/btromm), [linkedin](https://www.linkedin.com/in/bobby-tromm-49ba61157/)

### Thesis Advisor
> Eve Marder, PhD   
> Professor of Biology, Member of US National Academy of Sciences   
> marder@brandeis.edu   
> Volen Center for Complex Systems, Department of Biology, Brandeis University

Code can be reproduced by following these instructions:
* Use pull_all_gbars.m to generate steady state maximal conductances for each experiment. (Note: This will take a while -- even in parallel, running 5000 simulations takes a few minutes!)
* Generate figures by loading saved .mat files into your MATLAB workspace and running full_figure.m (see code for input arguments)

Note that your results may look marginally different than mine! Running 1000 simulations per experiment does even things out quite a bit, but nonetheless each model is initialized to quasi-random values, so output may be a bit different.

You can compile the thesis from source if you wish, or you may download the PDF [here.](https://github.com/btromm/neuralcorr-thesis/raw/master/thesis/Thesis/BobbyTromm_Thesis2020.pdf)
