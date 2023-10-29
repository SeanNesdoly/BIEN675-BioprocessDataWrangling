# BIEN675 Bioprocess Data Wrangling

> Week 12: Process Data Management, Storage, and Security  
> [BIEN675: Process Analytical Technologies and Data Sciences, Winter 2023](https://www.mcgill.ca/study/2022-2023/courses/bien-675)  
>  
> Sean Nesdoly  
> Viral Vectors and Vaccines Bioprocessing Group  
> https://amine-kamen.lab.mcgill.ca/  
> Department of Bioengineering  
> McGill University, Montréal QC  
> 2023-03-28

## Setup
1. Install `R` (the programming language) **and** `RStudio` (an Integrated
   Development Environment) from:
   [https://posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop)

   - For Apple machines, please check your CPU type and download the correct
     version of `R`. To do so, click the Apple logo (top left), then 'About This
     Mac'. Choose `R` according to below:

     + If `Chip` == `Apple M1/2`, select `R` for `Apple silicon arm64`
       (R-4.2.3-arm64.pkg)

     + If `Processor` contains the word `Intel`, select `R` for `Intel 64-bit`
       (R-4.2.3.pkg).

2. Open `RStudio` and install the `tidyverse` packages by executing the
   following code in your Console (located at bottom of window):

   ``` R
   # Installation will take some time
   install.packages("tidyverse")
   library(tidyverse)
   ```

3. [McGill SharePoint link to bioprocess dataset](https://mcgill.sharepoint.com/:x:/s/DigitalTwin_Group/EVuf3-KN_iZKmV5SbsQKwXMB62FphjT3LvzEOIFKDhtMSQ?e=ZiuhX5).
   Please keep data private.

