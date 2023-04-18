# **Evaluating forest quality with Forestat**

R包`forestat`是基于中国林业科学研究院资源信息研究所（Institute of Forest Resource Information Techniques, Chinese Academy of Forestry）的符利勇博士的天然林立地质量评价方法。实现的功能有，天然林立地树高分级的划分，树高模型、断面积生长模型、蓄积生长模型的建立，森林现实生产力与潜在生产力的计算。

## Introduction

### Package dependencies

| **Package** | **Download Link**                          |
| ----------- | ------------------------------------------ |
| dplyr       | https://CRAN.R-project.org/package=dplyr   |
| ggplot2     | https://CRAN.R-project.org/package=ggplot2 |
| nlme        | https://CRAN.R-project.org/package=nlme    |

### Supported OS

Windows, Linux and Mac OS are currently supported.

### Package installation

You can install the released version of *forestat* package from Cran or GitHub with the following command in R:

```R
#install package dependencie
install.packages(c("dplyr", "ggplot2", "nlme"))

#install package
install.packages("forestat")

#install.packages("devtools")

devtools::install_github("caf-ifrit/forestat")
```

To ensure you have successfully installed *forestat*, try loading it into your R session.

`library(forestat)`

## Standard workflow

### Quick start

这里我们展示的是林立地质量评估的完整步骤。在class.plot的上游有一些步骤，在获得了AGE(Stand age of the tree)，H(Height of the tree)，S(Forest density index)，BA(Basal area of the tree)，Bio(Biomass of the tree)之后，应当自定义ID(Unique identifier for each tree)以及code(Codes for forest types)。这个代码块假设你有拥有了以上所述的数据。

```R
data("forestData")
#使用包中自带的forestData数据
forestData <- class.plot(forestData,model="Richards",
                         interval=5,number=5,a=19,b=0.1,c=0.8)

plot(forestData,model.type = "BA",plot.type = "Scatter",
     xlab = "AGE",ylab = "BA",legend.lab = "LastGroup",
     title = "Forest")

forestData <- potential.productivity(forestData)
#计算forestData的潜在生产力
forestData <- reality.productivity(forestData)
#计算forestData的现实生产力
summary(forestData)
#获得forestData的summary
```

### 建立模型

class.plot函数，至少需要"ID","code"，"AGE","H"四列数据作为输入，以建立树高模型，同时会创造一个forestData类S3 method数据。如果输入数据中还有S，BA与Bio列的话，那么同时也会建立BA和Bio模型。

```R
forestData <- class.plot(forestData,model="Richards",
                         interval=5,number=5,a=19,b=0.1,c=0.8)
```

其中参数model可以选择"Logistic"、"Richards"、"Korf"、"Gompertz"、"Weibull"、"Schumacher "这六个中的一个，这会使用对应的model形式建立H model；interval 是树高分类的区间，interval=5就是创建一个以5 stand ages作为区间的初始树高分类；number是树高分类区间的最大值，number=5即初始树高分类数最多为5；a,b,c 是拟合模型的初始参数，当拟合出现错误时，可以多尝试一些初始参数作为尝试。

### 用forestData绘制示例图

forestData类的plot函数，使用经过class.plot函数处理过后的数据，可以分别绘制H Model,BA Model,Bio Model的Curve图，residual图，数据Scatter图，数据Scatter与模型拟合曲线图。

```R
plot.forestData(x,model.type="H",
                plot.type="Curve",
                xlab=NA,ylab=NA,legend.lab="Site class",
                title="Oak broadleaf mixed",...)
```

以上为使用默认参数与样本数据绘制的示例图

其中参数model.type可以选择H,BA或Bio，对应绘制的图使用的模型；plot.type可以选择Curve,residual,Scatter或Scatter_Curve，对应绘制图的类型；xlab,ylab,legend.lab,title分别可以进行x轴，y轴，图例，标题上文字的更改。

### 用forestData得到森林的潜在生产力与现实生产力

potential.productivity函数与reality.productivity函数，需要forestData类数据作为输入，同时BA model与Bio model必须已经建立，以获得森林的潜在生产力与现实生产力，并将得到的结果存储在forestData类数据中。

```R
forestData <- potential.productivity(forestData, code=1,
                                     age.min=5,age.max=150,
                                     left=0.05, right=100,
                                     e=1e-05, maxiter = 50) 
forestData <- reality.productivity(forestData, 
                                   left=0.05, right=100)
```

其中参数code对应forestData中的code，这会使用对应code的森林数据计算其现实生产力或潜在生产力。age.min与age.max即森林stand age的最小值与最大值，潜在生产力的计算会在这最小值与最大值的区间中进行。left与right是拟合模型的初始参数，当拟合出现错误时，可以多尝试一些初始参数作为尝试。e为拟合模型的精度，当残差低于e时，认为模型收敛并停止拟合。maxiter为拟合模型的最大次数，当拟合次数等于maxiter时，认为模型收敛并停止拟合

### 得到forestData的summary

forestData类的summary函数，使用经过class.plot函数处理过后的数据，可以得到存储于forestData类的各类数据的summary。

```R
summary(forestData)
```
