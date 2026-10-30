source('scripts/check-dois.R')
doi <- '10.example/test'
stopifnot(classify_handle(200,list(responseCode=1),doi)=='registered',
          classify_handle(403,list(responseCode=1),doi)=='unknown',
          classify_handle(500,NULL,doi)=='unknown',
          classify_handle(200,NULL,doi)=='unknown',
          classify_handle(200,list(responseCode='bad'),doi)=='unknown',
          classify_handle(404,NULL,doi)=='unregistered',
          classify_handle(200,list(responseCode=100),doi,doi)=='documented-unregistered',
          classify_handle(999,NULL,doi,doi)=='unknown')
cat('DOI registration, definitive absence, denial, malformed payload and outage classifications passed\n')
