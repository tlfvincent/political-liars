# political_liars
A lightweight app to visualize the truth of statements in Politifact

## Collecting the data
```
python scrape_politifact.py
```

## Running the app
If you are working locally, you can simply type the following into your R console:
```
library(shiny)
runApp('/app')
```

If you are working on a remote machine and would like to reproduce the app on a host, make sure you have `Docker` installed on your system and type the following:

```
docker build -t name_of_your_image .
```

followed by

```
docker run -p 3838:3838 -ti name_of_your_image
```

The app should then be publicly visible at the following URL `http://your_machine_ip:3838/app/`

