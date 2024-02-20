# forestat Rscript 

## Carbon Sequestration Potential Productivity Calculation 

### Train Model

You need to supply two arguments: [1] input CSV filename, [2] output RData filename.

```R
Rscript train_model.R input.csv model.rda
```

### Use Model

You need to supply three arguments: [1] productivity_type (potential or realized), [2] trained model file name (rda file), [3] output txt file name.

```R
Rscript use_model.R potential model.rda output_potential.txt
```

```R
Rscript use_model.R realized model.rda output_realized.txt
```