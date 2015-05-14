{smcl}
{* 20july2014}{...}
{hline}
help for {hi: ecomplexity}
{hline}

{title: Creates Economic Complexity Variables}

{p 4 12}{cmd:ecomplexity}
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

{p 4 4}{cmd:ecomplexity} Calculates the economic complexity variables used in The Atlas of Economic Complexity. 


{title:Options:}

{p 4 8}{cmd:varlist} contains the values over which the calculations will be performed; see help {cmd:varlist}. {p_end}

{p 4 8}{cmd:i(}{it:variable1}{cmd:)}, (must be provided), specifies the name of the location variable. {it:variable1} could be either string or numeric. {p_end}
 
{p 4 8}{cmd:p(}{it:variable2}{cmd:)}, (must be provided), specifies the name of the product/industry variable. {it:variable2} could be either string or numeric. {p_end}


{title: Variables Created:}

Notice that some of the variables are calculated at different levels (location, industry or location-industry). 


{p 4 8}{cmd:eci:} Economic Complexity Index (Variable at the location level). Its  diversity weighted by the ubiquity of each industry, using the method of reflections. {p_end}

{p 4 8}{cmd:pci:} Product Complexity Index (Variable at the industry level). Its the ubiquity of the industry weighted by the diversity of its producers, using the method of reflections. {p_end} 

{p 4 8}{cmd:density:} Measures the density of the network around each industry. Its the average presence of industries around each industry, weighted by the product-space proximity matrix. The more dense, the closest is a given industry to the economic structure of the location. (Variable at the location-industry level). Distance is somewhat more intuitive concept, which can be defined as the inverse of Density (ie distance = as 1/density or 1-density). {p_end}

{p 4 8}{cmd:coi:} Complexity Outlook Index (Variable at the location level, formerly called Opportunity Value). Its the value of developing the remaining industries weighted by the distance (inverse of density) from the current economic structure. {p_end}

{p 4 8}{cmd:cog:} Complexity Outlook Gain (Variable at the Industry level, formerly called Opportunity Gain). Its the increase in the Complexity Outlook Index for the country that will result from developing a given industry. {p_end}

{p 4 8}{cmd:diversity:} Diversity is the number of industries produced in a given location (Variable at the location level).

{p 4 8}{cmd:ubiquity:} Number of locations where the industry is present (Variable at the industry level). {p_end}


{p 4 8}{cmd:rca:} Balassa's Revealed Comparative Advantage index. It is the share of the industry in the location's production, over the importance of the industry in the whole sample (Variable at the location-industry level. only provided if the RCA option is used). {p_end}

{p 4 8}{cmd:rpop:} Ratio of industry over population for a location, divided by the importance of the industry in the whole sample (Variable at the location-industry level. only provided if the RPOP option is used). {p_end}

{p 4 8}{cmd:M:} Presence-absence matrix. It is the result of thresholding either the RCA or RPOP variables. If the industry intensity is over the given threshold, the variable will show a 1, and zero otherwise (Variable at the location-industry level). {p_end}


{p 4 8} For a more detailed description of the variables please consult the following link: http://atlas.cid.harvard.edu/about/glossary/ {p_end}


Warning: If any of the previous variables are defined in the dataset, the program will automatically delete the variables. It would also delete “_merge” or “_fillin” variables if found in the dataset. {p_end}



{title:Options:}


{p 4 8}{cmd:t(}{it:variable3}{cmd:)}, specifies the name of the time variable. {it:variable3} could be either string or numeric. {p_end}

{p 4 8}{cmd:rca(}#{cmd:)}, specifies the {cmd:RCA(}#{cmd:)} threshold above which the calculations assume that a industry is present in location i. If not specified, RCA>=1 is the default. If both {cmd:rca(}#{cmd:)} and {cmd:rpop(}#{cmd:)} are not specified, the program will asume the using RCA and a threshold of 1 by default. {p_end}

{p 4 8}{cmd:rpop(}#{cmd:)}, specifies the {cmd:rpop(}#{cmd:)} threshold above which the calculations assume that a industry is present in location i. If not specified, Rpop>=1 is the default. It requires specifying the population variable {p_end}

{p 4 8}{cmdab:pop(}{it:variable4}{cmd:)}, specifies name of the variable that will be used for the {cmd:rpop(}#{cmd:)} calculations. {p_end}

{p 8 8} Specifying both {cmd:rca(}#{cmd:)} and {cmd:rpop(}#{cmd:)},  will result in the combination of the two criteria. This is,  the Mcp matrices used in the calculations will consider that a industry is present in a location if either measure is above the corresponding threshold. {p_end}

{p 4 8}{cmdab:cont}, This option requires the program to calculate the industry-proximity matrix as the result of the Pearson Correlation of every pair of industrys.  By default, the program uses the probability of industry co-ocurrence to build the proximity matrices. {p_end}

{p 4 8}{cmdab:asym}, This option requires the program to calculate an asymmetric matrix of proximites. (i.e. the probability of observing industry A and B is different from observing B and A. Obviously, it does not work with continuous (Pearson correlation) proximities, which by definition are symmetric.  {p_end}

{p 4 8}{cmd:knn(}#{cmd:)}, specifies the number of k-nearest neighbors used to calculate the Density variables (instead of using all industries present in the sample). {p_end}

{title:Examples}

{p 4 8}{stata "ecomplexity export, i(iso) p(hs4)  t(year)" :.  ecomplexity export, i(iso) p(hs4)  t(year) } {p_end}
{p 8 8} Will assume by default that the calculations have to be done using RCA with threshold of 1. {p_end}

{p 4 8}{stata "ecomplexity export_value, i(iso) p(hs4)  rca(0.5) asym " :.  ecomplexity export_value, i(iso) p(hs4)  rca(0.5) asym }  {p_end}
{p 8 8} Specifies that threshold for the Mcp matrix should be 0.5, and that the calculations have to be done using a asymmetric proximity matrix  {p_end}

{p 4 8}{stata "ecomplexity export_value, i(iso) p(hs4) cont " :.  ecomplexity export_value, i(iso) p(hs4) cont }  {p_end}
{p 8 8} The option {cmdab:cont} specifies that instead of using a discrete Mcp matrix, the calculations are done using a continuous metric (Pearson correlation) between RCA vectors. Obviously, the asymmetric option would not work with a proximity matrix. {p_end}

{p 4 8}{stata "ecomplexity export_value, i(iso) p(hs4) cont knn(25) " :.  ecomplexity export_value, i(iso) p(hs4) cont knn(25) }  {p_end}
{p 8 8} Same as above, but specifying that the Density variable have to be calculated using the 25 (k-)nearest neighbors.  {p_end}

{p 4 8}{stata "ecomplexity export_value, i(iso) p(hs4)  pop(population) rpop(2)  " :. ecomplexity export_value, i(iso) p(hs4)  pop(population) rpop(2)  }  {p_end}
{p 8 8} Instead of using RCA, it uses the rpop with a threshold of 2. Additionally, it specifies that the population is the scaling variable.  {p_end}

{p 4 8}{stata "ecomplexity export_value, i(iso) p(hs4)  pop(population) rpop(2) rca(0.8)  " :. ecomplexity export_value, i(iso) p(hs4)  pop(population) rpop(2) rca(0.8)  }  {p_end}
{p 8 8} by specifying both the rca and rpop the program will combine the two criteria. Hence, the Mcp matrix used for calculations will reflect a presence if either rpop>=2 or rca>=0.8. {p_end}



{title:Authors}

{p 8 8} Sebastian Bustos, Harvard University, USA {break} 
        sebastian_bustos@hks.harvard.edu

{p 8 8} Muhammed Yildirim, Harvard University, USA {break} 
        muhammed_yildirim@hks.harvard.edu


{title:References}

{p} Hausmann, Hidalgo, PNAS (2009). The Building Blocks of Economic Complexity, 106, 10570-1057. {p_end}
{p} Hausmann, Hidalgo, Bustos, Coscia & Yildirim (2013). The Atlas of Economic Complexity. MIT Press {p_end}

{p} {p_end}

