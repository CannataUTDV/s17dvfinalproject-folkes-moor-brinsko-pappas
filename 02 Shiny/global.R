require(readr)
require(lubridate)
require(dplyr)
require(data.world)

online0 = TRUE

if(online0) {
  globals = query(
    data.world(propsfile = "www/.data.world"),
    dataset="hsfolkes/s-17-dv-final-project", type="sql",
    query="select Cost
    from states_boxplot
    order by 1"
  ) 
} else {}

