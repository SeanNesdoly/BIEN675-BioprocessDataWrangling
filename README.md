# BIEN675 Bioprocess Data Wrangling Workshop

> [BIEN675: Process Analytical Technologies and Data Sciences, Fall 2023](https://www.mcgill.ca/study/2023-2024/courses/bien-675)  
>  
> Sean Nesdoly  
> Viral Vectors and Vaccines Bioprocessing Group  
> [amine-kamen.lab.mcgill.ca](https://amine-kamen.lab.mcgill.ca/)  
> Department of Bioengineering  
> McGill University, Montréal QC  
> 2023-11-21T0830

On November 21st, we have organized a hands-on workshop on 'Bioprocess Data
Wrangling' during lecture hours (90 mins). The purpose is to (reproducibly)
analyze bioprocess data using the `R` programming language. To follow along,
please complete the [Setup section](#Setup) below to download and install `R`
(the programming language), `RStudio` (an Integrated Development Environment),
and the `tidyverse` set of packages.

If you have trouble installing any of these, please contact Sean @
<sean.nesdoly@mcgill.ca>. If everything is configured correctly, you will
receive NO error messages after running the command `library(tidyverse)`.

## Setup
1. Install `R` (the programming language) **and** `RStudio` (an Integrated
   Development Environment) from: https://posit.co/download/rstudio-desktop

   - For Apple machines, please check your CPU type and download the correct
     version of `R`. To do so, click the Apple logo (top left), then 'About This
     Mac'. Choose `R` according to below:

     + If `Chip` == `Apple M[1,2]`, select `R` for `Apple silicon`
       (R-4.3.2-arm64.pkg)

     + If `Processor` contains the word `Intel`, select `R` for `Intel`
       (R-4.3.2-x86_64.pkg).

2. Open `RStudio` and install the `tidyverse` packages by executing the
   following code in your Console (located at bottom of window):

   ``` R
   # Installation will take some time
   install.packages("tidyverse")
   library(tidyverse) # no errors should be printed out in your Console
   ```

3. [McGill SharePoint link to bioprocess dataset](https://mcgill.sharepoint.com/:x:/s/DigitalTwin_Group/EVuf3-KN_iZKmV5SbsQKwXMB62FphjT3LvzEOIFKDhtMSQ?e=ZiuhX5).
   Please keep data private.

