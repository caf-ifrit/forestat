# <div align="center"><strong>使用 Forestat 评估森林质量</strong></div>

<p align="right"><strong>Forestat version:</strong> 0.1.0</p>
<p align="right"><strong>Date:</strong> 04/22/2023 </p>
<br>

*`forestat`* 是基于中国林业科学研究院资源信息研究所（Institute of Forest Resource Information Techniques, Chinese Academy of Forestry）的`天然林立地质量评价方法`[<sup>[1]</sup>](#citation)开发的R包。实现的功能包括天然林立地树高分级的划分，树高模型、断面积生长模型、蓄积生长模型的建立，森林现实生产力与潜在生产力的计算。使用 *`forestat`* 包可以为精准提升森林质量提供可靠依据。

<div align="center">

[English](README.en-US.md) | [简体中文](README.md)
<br>

</div>

## <div align="center">1 概述</div>

*`forestat`* 包实现了天然林立地树高分级的划分，树高模型、断面积生长模型、蓄积生长模型的建立，森林现实生产力与潜在生产力的计算。其中，树高模型可用Richard模型、Logistic模型、korf模型、Gompertz模型、Weibull模型和Schumacher模型构建，断面积生长模型和蓄积生长模型仅可用Richard模型构建。*`forestat`* 包依赖于天然林立地的数据，包中带有一份样例数据。

### 1.1 *forestat* 流程图

<div align="center">
  <img width="70%" src="forestat/vignettes/img/flowchart.png">
  <p>图 1. <i>forestat</i>工作流程图</p>
</div>

### 1.2 *forestat* 依赖的R包

| **Package** | **Download Link**                          |
| ----------- | ------------------------------------------ |
| dplyr       | https://CRAN.R-project.org/package=dplyr   |
| ggplot2     | https://CRAN.R-project.org/package=ggplot2 |
| nlme        | https://CRAN.R-project.org/package=nlme    |


## <div align="center">2 安装</div>

### 2.1 从CRAN或GitHub安装
在 R 中使用以下命令从 [CRAN](https://CRAN.R-project.org/package=forestat) 安装 *`forestat`*  ：

```R
# 安装依赖的R包
install.packages(c("dplyr", "ggplot2", "nlme"))

# 安装forestat
install.packages("forest")
```

当然，你也可以在 R 中使用以下命令从 [GitHub](https://github.com/caf-ifrit/forestat) 安装 *`forestat`*  ：

```R
# 安装依赖的R包
install.packages(c("dplyr", "ggplot2", "nlme"))

# 安装devtools
install.packages("devtools")

# 安装forestat
devtools::install_github("caf-ifrit/forestat/forestat")
```

### 2.2 加载  *forestat*

```R
library(forestat)
```

## <div align="center">3 快速开始</div>

本节展示的是快速完成天然林立地质量评估的完整步骤，使用的数据是包中自带的`forestData`样例数据。

```R
# 加载包中 forestData 样例数据
data("forestData")

# 基于 forestData 数据建立模型，返回一个 forestData 类对象
forestData <- class.plot(forestData,model="Richards",
                         interval=5,number=5,a=19,b=0.1,c=0.8)

# 绘制断面积生长模型散点图
plot(forestData,model.type = "BA",plot.type = "Scatter",
     xlab = "AGE",ylab = "BA",legend.lab = "LastGroup",
     title = "Forest")

# 计算 forestData 对象的潜在生产力
forestData <- potential.productivity(forestData)

# 计算 forestData 对象的现实生产力
forestData <- reality.productivity(forestData)

# 获取 forestData 对象的汇总数据
summary(forestData)
```

## <div align="center">4 详细教程</div>

<details>
<summary style="font-size:21px;"><strong>4.1 建立模型</strong></summary>

<br>
<details>
<summary style="font-size:18px;"><strong>4.1.1 自定义数据</strong></summary>

为了建立一个准确的模型，好的数据是不可或缺的，在 *`forestat`* 包中内置了一个经过清洗的样例数据，可以通过如下命令加载查看样例数据：

```R
# 加载包中 forestData 样例数据
data("forestData")

# 或者读取包中 forestat.csv 样例数据
forestData <- read.csv(system.file("extdata", "forestData.csv", package = "forestat"))

# 筛选 forestData 样例数据中ID、code、AGE、H、S、BA 和 Bio字段，并查看前6行数据
head(dplyr::select(forestData,ID,code,AGE,H,S,BA,Bio))

# 输出
          ID code AGE    H        S       BA      Bio
1 6100005337    1  45 11.9 1508.468 50.13462 474.4957
2  410001607    1  42 16.7 1490.493 47.22381 444.5069
3 6100005337    1  35 11.0 1401.944 46.64877 435.8741
4 6100005337    1  40 12.8 1303.489 44.15220 415.9098
5  410001607    1  38 15.2 1350.941 42.37152 400.3925
6 6220002848    1  88 11.2 1631.235 50.43886 395.2503
```

当然，你也可以选择加载自定义数据：

```R
# 加载自定义数据
forestData <- read.csv("/path/to/your/folder/your_file.csv")
```

自定义数据要求为`csv`格式，数据中`ID（样地ID）`、`code（样地林类型代码）`、`AGE（林分平均年龄）`、`H（林分平均高）`是必须字段，用以建立`树高模型（H Model）`，并绘制相关示例图。

`S（林分密度指数）`、`BA（林面积）`、`Bio（林生物量）`是可选的字段，用以建立`断面积生长模型（BA Model）`与`蓄积生长模型（Bio Model）`。

在后续的潜在生产力和现实生产力计算中，断面积生长模型与蓄积生长模型是必须的。也就是自定义数据如果缺少`S`、`BA`和`Bio`字段将无法计算潜在生产力和现实生产力。

<div align="center">
  <img width="70%" src="forestat/vignettes/img/forestData.png">
  <p>图 2. 自定义数据格式要求</p>
</div>

</details>

<br>
<details>
<summary style="font-size:18px;"><strong>4.1.2 构建林分生长模型</strong></summary>
<div id="4.1.2"></div>

数据加载后，*`forestat`* 将使用`class.plot()`函数构建林分生长模型，如果自定义数据中同时包含`ID、code、AGE、H、S、BA、Bio`字段，则会同时构建`树高模型、断面积生长模型、蓄积生长模型`，如果只包含`ID、code、AGE、H`字段，则只会构建`树高模型`。

```R
# 选用 Richards 模型构建林分生长模型
# interval=5表示初始树高分类的林分年龄区间设置为5，number=5表示初始树高分类数最多为5
# 拟合模型的初始参数a=19, b=0.1, c=0.8
forestData <- class.plot(forestData,model="Richards",
                         interval=5,number=5,a=19,b=0.1,c=0.8)
```

其中，`model`为构建树高模型时选用的模型，可在`"Logistic"、"Richards"、"Korf"、"Gompertz"、"Weibull"、"Schumacher"`模型中任选一个，断面积生长模型和蓄积生长模型默认使用Richard模型构建。`interval`为初始树高分类的林分年龄区间，number为初始树高分类数的最大值。`a, b, c` 是拟合模型的初始参数，当拟合出现错误时，可以多尝试一些初始参数作为尝试。

由`class.plot()`函数返回的结果为`forestData` 对象，包括`Input（输入数据和树高分级结果）`、`H model（树高模型）`、`BA model（断面积生长模型）`、`Bio model（蓄积生长模型）`以及`output（模型参数）`。

<div align="center">
  <img width="70%" src="forestat/vignettes/img/forestDataObj.png">
  <p>图 3. forestData对象结构</p>
</div>

</details>

<br>
<details>
<summary style="font-size:18px;"><strong>4.1.3 获取汇总数据</strong></summary>
<div id="4.1.3"></div>

为了解模型的建立情况，可以使用`summary(forestData)`函数获取`forestData`对象汇总数据。该函数返回`summary.forestData`对象并将相关数据输出至屏幕。

输出的第一段为输入数据的汇总，第二、三、四段分别为`H model（树高模型）`、`BA model（断面积生长模型）`、`Bio model（蓄积生长模型）`的参数及其精简报告。

```R
summary(forestData)
```

```R
# 输出
# 第一段
       H               S                 BA               Bio         
 Min.   : 2.00   Min.   :  15.94   Min.   : 0.3017   Min.   :  1.224  
 1st Qu.: 7.70   1st Qu.: 360.38   1st Qu.: 9.3241   1st Qu.: 53.233  
 Median : 9.40   Median : 557.25   Median :14.9777   Median : 95.002  
 Mean   : 9.83   Mean   : 583.88   Mean   :16.2648   Mean   :109.322  
 3rd Qu.:11.90   3rd Qu.: 764.38   3rd Qu.:21.6455   3rd Qu.:147.737  
 Max.   :17.70   Max.   :1772.26   Max.   :52.6455   Max.   :474.496  

# 第二段
Hmodel Parameters:

Nonlinear mixed-effects model fit by maximum likelihood
  Model: H ~ 1.3 + a * (1 - exp(-b * AGE))^c 
  Data: data 
       AIC      BIC    logLik
  2720.209 2746.159 -1355.105

Random effects:
 Formula: a ~ 1 | LASTGROUP
             a  Residual
StdDev: 3.6513 0.6616545

Fixed effects:  a + b + c ~ 1 
      Value Std.Error   DF   t-value p-value
a 11.226213 1.6509803 1319  6.799726       0
b  0.020457 0.0029541 1319  6.924853       0
c  0.370395 0.0228807 1319 16.188147       0
 Correlation: 
  a      b     
b -0.137       
c -0.122  0.949

Standardized Within-Group Residuals:
        Min          Q1         Med          Q3         Max 
-4.13170023 -0.75823758 -0.03968202  0.74727148  4.97834758 

Number of Observations: 1326
Number of Groups: 5 

Concise Parameter Report:
Model Coefficients:
       a1       a2       a3       a4       a5         b         c
 6.331338 8.578689 10.91438 13.61481 16.69184 0.0204566 0.3703953

Model Evaluations:
           pe      RMSE        R2       Var       TRE      AIC      BIC
 -0.001864527 0.6604061 0.9455896 0.4364619 0.4185215 2720.209 2746.159
    logLik
 -1355.105

Model Formulas:
                                       Func                  Spe
 model1:H ~ 1.3 + a * (1 - exp(-b * AGE))^c model1:pdDiag(a ~ 1)
 
# 第三段（与第二段数据格式相似）
BAmodel Parameters:

# 此处省略
......

# 第四段（与第二段数据格式相似）
Biomodel Parameters:

# 此处省略
......
```

</details>
</details>

<br>
<details>
<summary style="font-size:21px;"><strong>4.2 绘制图像</strong></summary>

经过[4.1.2](#4.1.2) `class.plot()`函数构建林分生长模型后，就可以使用`plot()`函数绘制图像。

其中，`model.type`为绘图使用的模型，可以选择`H`（树高模型）、`BA`（断面积生长模型）或者`Bio`（蓄积生长模型）。`plot.type`为绘图的类型，可以选择`Curve`（曲线图）、`Scatter_Curve`（散点曲线图）、`residual`（残差图）、`Scatter`（散点图）或者。`xlab`、`ylab`、`legend.lab`、`title`分别为`x轴标题`、`y轴标题`、`图例`、`图像标题`。

```R
# 绘制树高模型的曲线图
plot(forestData,model.type="H",
     plot.type="Curve",
     xlab="Stand age (year)",ylab="Height (m)",legend.lab="Site class",
     title="橡阔叶树高模型曲线图")

# 绘制断面积生长模型散点图
plot(forestData,model.type="BA",
     plot.type="Scatter",
     xlab="Stand age (year)",ylab="Height (m)",legend.lab="Site class",
     title="橡阔叶断面积生长模型散点图")
```

不同的`plot.type`绘制的样图如图4所示：

<div align="center">
  <img width="100%" src="forestat/vignettes/img/plot-1.png">
  <img width="100%" src="forestat/vignettes/img/plot-2.png">
  <p>图 4. 不同的plot.type绘制的样图</p>
</div>

</details>

<br>
<details>
<summary style="font-size:21px;"><strong>4.3 计算森林的潜在生产力</strong></summary>

经过[4.1.2](#4.1.2) `class.plot()`函数构建林分生长模型后，就可以使用`potential.productivity()`函数计算森林的潜在生产力。在计算之前，要求`forestData` 对象中`BA model`和`Bio model`已经建立。

```R
forestData <- potential.productivity(forestData, code=1,
                                     age.min=5,age.max=150,
                                     left=0.05, right=100,
                                     e=1e-05, maxiter = 50) 
```

其中，参数`code`为计算潜在生产力使用的森林类型代码。`age.min`和`age.max`分别为林分年龄的最小值和最大值，潜在生产力的计算会在最小值和最大值的区间中进行。`left`和`right`为拟合模型的初始参数，当拟合出现错误时，可以多尝试一些初始参数作为尝试。`e`为拟合模型的精度，当残差低于`e`时，认为模型收敛并停止拟合。`maxiter`为拟合模型的最大次数，当拟合次数等于`maxiter`时，认为模型收敛并停止拟合。

<br>
<details>
<summary style="font-size:18px;"><strong>4.3.1 潜在生产力输出数据说明</strong></summary>

计算结束后，可以使用如下命令查看并输出结果：

```R
library(dplyr)
forestData$potential.productivity %>% head(.)
```

```R
# 输出
    Max_GI   Max_MI       N1       D1       S0       S1       G0       G1
1 3.432031 25.28960 7314.484 7.871238 1509.526 1637.494 32.16056 35.59259
2 2.905191 21.52146 6715.212 8.179387 1492.373 1598.908 32.37989 35.28508
3 2.518421 18.74017 6241.259 8.455917 1476.469 1567.516 32.53121 35.04963
4 2.222457 16.60206 5854.617 8.707564 1461.918 1541.273 32.64190 34.86436
5 1.988672 14.90643 5530.422 8.938955 1448.291 1518.519 32.71869 34.70736
6 1.799336 13.52842 5253.364 9.153519 1435.503 1498.419 32.77100 34.57033
        M0       M1 LASTGROUP AGE
1 196.4822 221.7718         1   5
2 199.6247 221.1461         1   6
3 202.0687 220.8089         1   7
4 204.0589 220.6610         1   8
5 205.6789 220.5854         1   9
6 207.0203 220.5487         1  10
```

输出结果中，各字段含义如下：

`Max_GI`：最大林分断面积

`Max_MI`：蓄积最大生长量

`N1`：达到潜在生长量对应的林分株数

`D1`：达到潜在生长里对应的林分平均直径

`S0`： 初始林分密度指数

`S1`：达到潜在生长里对应的林分最佳密度指数

G0：初始林分每公顷断面积

`G1`：达到潜在生长量对应的林分每公项断面积(1年以后)

`M0`：初始林分每公项蓄积

`M1`：达到潜在生长量对应的林分每公项蓄积

</details>
</details>

<br>
<details>
<summary style="font-size:20px;"><strong>4.4 计算森林的现实生产力</strong></summary>

经过[4.1.2](#4.1.2) `class.plot()`函数构建林分生长模型后，可以使用`reality.productivity()`函数计算森林的现实生产力。在计算之前，要求`forestData` 对象中`BA model`和`Bio model`已经建立。

```R
forestData <- reality.productivity(forestData, 
                                   left=0.05, right=100)
```

其中，参数`left`与`right`是拟合模型的初始参数，当拟合出现错误时，可以多尝试一些初始参数作为尝试。

<br>
<details>
<summary style="font-size:18px;"><strong>4.4.1 现实生产力输出数据说明</strong></summary>

计算结束后，可以使用如下命令查看并输出结果：

```R
library(dplyr)
forestData$reality.productivity %>% head(.)
```

```R
# 输出
  code         ID AGE    H class0 LASTGROUP       BA        S      Bio
1    1 6100005337  45 11.9      4         4 50.13462 1508.468 474.4957
2    1  410001607  42 16.7      5         5 47.22381 1490.493 444.5069
3    1 6100005337  35 11.0      3         4 46.64877 1401.944 435.8741
4    1 6100005337  40 12.8      4         4 44.15220 1303.489 415.9098
5    1  410001607  38 15.2      5         5 42.37152 1350.941 400.3925
6    1 6220002848  88 11.2      3         3 50.43886 1631.235 395.2503
         BAI        VI
1 0.36488249 2.8670220
2 0.42883352 3.6013437
3 0.57137875 4.7817218
4 0.51822786 4.4346054
5 0.55925908 4.9739993
6 0.07333166 0.3845029
```

输出结果中，各字段含义如下：

`BAI`：蓄积现实生产力

`VI`：蓄积潜在生产力

</details>
</details>

<br>
<details>
<summary style="font-size:20px;"><strong>4.5 潜在生产力和现实生产力数据详情</strong></summary>

在得到森林潜在生产力与现实生产力后，可以使用`summary(forestData)`函数获取`forestData`对象汇总数据。该函数返回`summary.forestData`对象并将相关数据输出至屏幕。

输出的前四段在[4.1.3](#4.1.3)中已经介绍，第五段为潜在生产力与现实生产力数据详情。

```R
summary(forestData)
```

```R
# 输出
# 第一段
       H               S                 BA               Bio         
 Min.   : 2.00   Min.   :  15.94   Min.   : 0.3017   Min.   :  1.224  
 
# 此处省略
......

# 第五段
     Max_GI           Max_MI      
 Min.   :0.1244   Min.   : 1.009  
 1st Qu.:0.1757   1st Qu.: 1.517  
 Median :0.2591   Median : 2.206  
 Mean   :0.4715   Mean   : 3.909  
 3rd Qu.:0.4878   3rd Qu.: 4.086  
 Max.   :3.9588   Max.   :33.858  
      BAI               VI       
 Min.   :0.0000   Min.   :0.000  
 1st Qu.:0.1388   1st Qu.:1.028  
 Median :0.2077   Median :1.597  
 Mean   :0.2353   Mean   :1.846  
 3rd Qu.:0.3116   3rd Qu.:2.558  
 Max.   :0.8562   Max.   :7.309  
```

</details>

## <div align="center">5 引用</div>

<div id="citation"></div>

```txt
@article{lei2018methodology,
  title={Methodology and applications of site quality assessment based on potential mean annual increment.},
  author={Lei Xiangdong, Fu Liyong, Li Haikui, Li Yutang, Tang Shouzheng},
  journal={Scientia Silvae Sinicae},
  volume={54},
  number={12},
  pages={116-126},
  year={2018},
  publisher={The Chinese Society of Forestry}
}
```
