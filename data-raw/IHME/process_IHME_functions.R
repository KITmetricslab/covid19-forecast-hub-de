# Author: Konstantin Görgen
# Date: Fri May 08 14:51:21 2020
# --------------
# Modification:
# Author:
# Date:
# --------------

##Functions to process IHME files

get_date<-function(path)
{
  temp_path<-dirname(path)
  slashes<-unlist(gregexpr("/",temp_path))
  last_slash<-slashes[length(slashes)]
  date.1<-gsub("_", "-",substring(dirname(path),first=last_slash+1))
  if(coerceable_to_date(date.1))
  {return(as.Date(date.1))} else
  {
    date.2<-substr(date.1,start=1,end=10)
    if(coerceable_to_date(date.2))
    {
      return(as.Date(date.2))
    } else 
    {
      stop("Path cannot be coerced to date. Please rename folders")
    }
    }
  }

coerceable_to_date<-function(x)
{
  !is.na(as.Date(as.character(x), tz = 'UTC', format = '%Y-%m-%d'))
}
