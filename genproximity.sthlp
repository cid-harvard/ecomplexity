{smcl}
{* 20july2014}{...}
{hline}
help for {hi: genproximity}
{hline}

{title: Creates a proximity matrix}

{p 4 12}{cmd:genproximity}
{it:varlist}
[{cmd:if} {it:exp}]
{cmd:,} 
{cmdab:i(}{it:variable1}{cmd:)}
 {cmdab:p(}{it:variable2}{cmd:)}
[
 {cmdab:t(}{it:variable3}{cmd:)}
{cmdab:rca(}{it:#}{cmd:)}
{cmdab:rpop(}{it:#}{cmd:)}
{cmdab:pop(}{it:variable4}{cmd:)}
{cmdab:cont}
{cmdab:asym}
{cmdab:knn(}{it:#}{cmd:)}
]


{title:Description:}

{p 4 4}{cmd:genproximity} creates a dataset with the proximity between every combination of products, as used in The Atlas of Economic Complexity.

{p 4 4}{cmd:varlist} contains the values over which the calculations will be performed; see help {cmd:varlist}.



{title:Options:}

{p 4 8}{cmd:i(}{it:variable1}{cmd:)}, (must be provided), specifies the name of the location variable. {it:variable1} could be either string or numeric. {p_end}
 
{p 4 8}{cmd:p(}{it:variable2}{cmd:)}, (must be provided), specifies the name of the products variable. {it:variable2} could be either string or numeric. {p_end}

{p 4 8} {cmd: The following are optional features:} {p_end}

{p 4 8}{cmd:t(}{it:variable3}{cmd:)}, specifies the name of the time variable. {it:variable3} could be either string or numeric. {p_end}

{p 4 8}{cmd:rca(}#{cmd:)}, specifies the RCA threshold above which the calculations assume that a product is present in location i. If not specified, RCA>=1 is the default. If both {cmd:rca(}#{cmd:)} and {cmd:rpop(}#{cmd:)} are not specified, the program will asume the using RCA and a threshold of 1 by default {p_end}

{p 4 8}{cmd:rpop(}#{cmd:)}, specifies the Rpop threshold above which the calculations assume that a product is present in location i. If not specified, Rpop>=1 is the default. It requires specifying the population variable {p_end}

{p 4 8}{cmdab:pop(}{it:variable4}{cmd:)}, specifies name of the variable that will be used for the Rpop calculations. {p_end}

{p 8 8} Specifying both {cmd:rca(}#{cmd:)} and {cmd:rpop(}#{cmd:)},  will result in the combination the two criteria. ie the Mcp matrices used for calculations will consider that a product is present in a location if either measure is above the corresponding threshold. {p_end}

{p 4 8}{cmdab:cont}, This option tells the program to calculate the proximity matrix as the result of the Pearson Correlation of every pair of products.  By default the program uses the probability of product co-ocurrence to building the proximity matrices. {p_end}

{p 4 8}{cmdab:asym}, This option tells the program to calculate an asymmetric matrix of proximites. (i.e. the probability of observing product A and B is different from observing B and A. Obviously, it does not work with continuous (Pearson correlation) proximities, which by definition are symmetric.  {p_end}

{p 4 8}{cmd:knn(}#{cmd:)}, specifies the number of k-nearest neighbords used for calculating the Density variables. {p_end}

{title:Examples}

{p 8 8} Each of the following examples will result in a new dataset with every combination of the {cmdab:i(}{it:variable1}{cmd:)} provided by the user.  {p_end}

{p 4 8}{stata "genproximity export, i(iso) p(hs4)  t(year)" :.  genproximity export, i(iso) p(hs4)  t(year) } {p_end}
{p 8 8} Will assume by default that the calculations have to be done using RCA with threshold of 1. {p_end}

{p 4 8}{stata "genproximity export_value, i(iso) p(hs4)  rca(0.5) asym " :.  genproximity export_value, i(iso) p(hs4)  rca(0.5) asym }  {p_end}
{p 8 8} Specifies that threshold for the Mcp matrix should be 0.5, and that the calculations have to be done using a asymmetric proximity matrix  {p_end}

{p 4 8}{stata "genproximity export_value, i(iso) p(hs4) cont " :.  genproximity export_value, i(iso) p(hs4) cont }  {p_end}
{p 8 8} The option {cmdab:cont} specifies that instead of using a discrete Mcp matrix, the calculations are done using a continuous metric (Pearson correlation) between RCA vectors. Obviously, the asymmetric option would not work with a proximity matrix. {p_end}

{p 4 8}{stata "genproximity export_value, i(iso) p(hs4) cont knn(25) " :.  genproximity export_value, i(iso) p(hs4) cont knn(25) }  {p_end}
{p 8 8} Same as above, but specifying that the Density variable have to be calculated using the 25 (k-)nearest neighbors.  {p_end}

{p 4 8}{stata "genproximity export_value, i(iso) p(hs4)  pop(population) rpop(2)  " :. genproximity export_value, i(iso) p(hs4)  pop(population) rpop(2)  }  {p_end}
{p 8 8} Instead of using RCA, it uses the rpop with a threshold of 2. Additionally, it specifies that the population is the scaling variable.  {p_end}

{p 4 8}{stata "genproximity export_value, i(iso) p(hs4)  pop(population) rpop(2) rca(0.8)  " :. genproximity export_value, i(iso) p(hs4)  pop(population) rpop(2) rca(0.8)  }  {p_end}
{p 8 8} by specifying both the rca and rpop the program will combine the two criteria. Hence, the Mcp matrix used for calculations will reflect a presence if either rpop>=2 or rca>=0.8. {p_end}



{title:Authors}

{p 8 8} Sebastian Bustos, Harvard University, USA{break} 
        sebastian_bustos@hks.harvard.edu

{p 8 8} Muhammed Yildirim, Harvard University, USA{break} 
        muhammed_yildirim@hks.harvard.edu


{title:References}

{p} Hausmann, Hidalgo, PNAS (2009). The Building Blocks of Economic Complexity, 106, 10570-1057. {p_end}
{p} Hausmann, Hidalgo, Bustos, Coscia & Yildirim (2013). The Atlas of Economic Complexity. MIT Press {p_end}

{p} {p_end}

