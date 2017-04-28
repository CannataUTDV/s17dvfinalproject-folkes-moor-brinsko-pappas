require(readr)
require(plyr)

file_path = "../00 Doc/PreETL_states.csv"
PreETL_states <- readr::read_csv(file_path)
names(PreETL_states)

df <- PreETL_states
names(df)
str(df)

measures <- c("Submission Year", "State Code", "Region Code", "Service Population", "Service Population without Duplicates", "State Population", "Central Libraries", "Branch Libraries", "Bookmobiles", "MLS Libraries", "Librarians", "Employees", "Total Staff", "Local Government Operating Revenue", "State Government Operating Revenue", "Federal Government Operating Revenue", "Other Operating Revenue", "Total Operating Revenue", "Salaries", "Benefits", "Benefits", "Total Staff Expenditures", "Print Collection Expenditures", "Digital Collection Expenditures", "Other Collection Expenditures", "Total Collection Expenditures", "Other Operating Expenditures", "Total Operating Expenditures", "Local Government Capital Revenue", "State Government Capital Revenue", "Federal Government Capital Revenue", "Other Capital Revenue", "Total Capital Revenue", "Total Capital Expenditures", "Print Collection", "Digital Collection", "Audio Collection", "Downloadable Audio", "Physical Video", "Downloadable Video", "Local Cooperative Agreements", "State Licensed Databases", "Total Licensed Databases", "Print Subscriptions", "Hours Open", "Library Visits", "Reference Transactions", "Registered Users", "Circulation Transactions", "Interlibrary Loans Provided", "Interlibrary Loans Received", "Library Programs", "Children's Programs", "Young Adult Programs", "Library Program Audience", "Children's Program Audience", "Young Adult Program Audience", "Public Internet Computers", "Internet Computer Use", "Wireless Internet Sessions")
measures

dimensions <- setdiff(names(df), measures)
dimensions

# The only "cleaning up" our data required was adding underscores to the column names, and removing apostrophes.

names(df) <- gsub(" ", "_", names(df))

write.csv(df, gsub("PreETL_", "", file_path), row.names=FALSE, na = "")

states <- gsub("PreETL_", "", gsub(" +", "_", gsub("[^A-z, 0-9, ]", "", gsub(".csv", "", file_path))))
sql <- paste("CREATE TABLE", states)
if( length(measures) > 0 || ! is.na(dimensions)) {
  for(d in dimensions) {
    sql <- paste(sql, paste(d, "varchar2(4000),\n"))
  }
}
if( length(measures) > 0 || ! is.na(measures)) {
  for(m in measures) {
    if(m != tail(measures, n=1)) sql <- paste(sql, paste(m, "number(38,4),\n"))
    else sql <- paste(sql, paste(m, "number(38,4)\n"))
  }
}
sql <- paste(sql, ");")
cat(sql)